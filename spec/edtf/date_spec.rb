describe 'Date/DateTime' do

  describe 'class methods' do
    it 'responds to edtf' do
      expect(Date).to respond_to(:edtf)
    end

    describe 'edtf and edtf!' do
      around do |example|
        original = Warning[:deprecated]
        Warning[:deprecated] = true
        example.run
      ensure
        Warning[:deprecated] = original
      end

      it 'are deprecated' do
        expect { Date.edtf('2004') }.to output(/`Date.edtf` is deprecated/).to_stderr
        expect { Date.edtf!('2004') }.to output(/`Date.edtf!` is deprecated/).to_stderr
      end

      it 'still parse' do
        Warning[:deprecated] = false
        expect(Date.edtf('2004?')).to eql(EDTF.parse('2004?'))
        expect(Date.edtf('xyz')).to be_nil
      end

      it 'are not used by EDTF.parse' do
        expect { EDTF.parse('2004') }.not_to output.to_stderr
      end
    end

    describe 'gregorian' do
      it 'returns a proleptic Gregorian date for pre-Gregorian dates' do
        date = Date.gregorian(1582, 9, 30)
        expect(date).to be_gregorian
        expect(date).to eq(Date.new(1582, 9, 30, Date::GREGORIAN))
      end

      it 'returns a Gregorian date for valid Gregorian dates' do
        date = Date.gregorian(1582, 10, 30)
        expect(date).to be_gregorian
        expect(date).to eq(Date.new(1582, 10, 30))
      end

      it 'is used for parsed dates across the 10-day correction' do
        (4..15).each do |mday|
          date = EDTF.parse('1582-10-%02d' % mday)
          expect(date).to be_gregorian
          expect([date.year, date.month, date.mday]).to eq([1582, 10, mday])
        end
      end
    end
  end

  describe 'instance methods' do
    [:uncertain?, :approximate?, :unspecified?, :uncertain, :approximate, :unspecified].each do |method|
      it "responds to #{method}" do
        expect(Date.new.respond_to?(method)).to eq(true)
      end
    end
  end

  describe '#dup' do
    let(:date) { EDTF.parse('2004-09%') }

    it 'copies all date values' do
      expect(date.dup.to_s).to eq('2004-09-01')
    end

    it 'copies uncertainty' do
      expect(date.dup).to be_uncertain
    end

    it 'copies approximate' do
      expect(date.dup).to be_approximate
    end

    it 'copies precision' do
      expect(date.dup.precision).to eq(:month)
    end

    it 'copies uncertainty by value' do
      expect { date.dup.certain! }.not_to change { date.uncertain? }
    end
  end

  describe 'precisions' do
    let(:date) { Date.today }

    it 'has day precision by default' do
      expect(date).to be_day_precision
    end

    it '#day_precision returns a new date object' do
      expect(date.day_precision).not_to equal(date)
      expect(date.day_precision).to eq(date)
    end
  end

  describe '#negate' do
    let(:date) { EDTF.parse('2004?') }

    it 'returns a new date with the negated year' do
      expect(date.negate.year).to eq(date.year * -1)
    end

    it 'returns a new date with the same month' do
      expect(date.negate.month).to eq(date.month)
    end

    it 'returns a new date with the same day' do
      expect(date.negate.day).to eq(date.day)
    end

    it 'returns a new date with the same precision' do
      expect(date.negate.precision).to eq(date.precision)
    end
  end

  describe '#succ' do
    it 'the successor of 2004 is 2005' do
      expect(EDTF.parse('2004').succ.year).to eq(2005)
    end

    it 'the successor of 2004-03 is 2004-04' do
      expect(EDTF.parse('2004-03').succ.strftime('%Y-%m')).to eq('2004-04')
    end

    it 'the successor of 2004-03-01 is 2004-03-02' do
      expect(EDTF.parse('2004-03-01').succ.strftime('%Y-%m-%d')).to eq('2004-03-02')
    end

    it 'the successor of 1999 has year precision' do
      expect(EDTF.parse('1999').succ).to be_year_precision
    end
  end

  describe '#next' do
    it 'returns the successor when given no argument' do
      expect(EDTF.parse('1999').next[0].year).to eq(2000)
    end

    it 'returns an array of the next 3 elements when passed 3 as an argument' do
      expect(EDTF.parse('1999').next(3).map(&:year)).to eq([2000, 2001, 2002])
    end
  end

  describe '#change' do
    let(:date) { EDTF.parse('2004-09%') }

    it 'returns a copy of the date if given empty option hash' do
      expect(date.change({})).to eq(date)
    end

    it 'the returned copy is not identical at object level' do
      expect(date.change({})).not_to equal(date)
    end

    describe 'when given a new year' do
      let(:changeset) { { :year => 1999 } }

      it 'returns a new date instance with the changed year' do
        expect(date.change(changeset).year).to eq(1999)
      end
    end

    describe 'when given a new precision' do
      let(:changeset) { { :precision => :year } }

      it 'returns a new date instance with the changed precision' do
        expect(date.change(changeset).precision).to eq(:year)
      end
    end

    it 'copies extended values by value' do
      expect { date.change({}).approximate! }.not_to change { date.approximate? }
    end
  end

  describe '#uncertain?' do
    let(:date) { Date.new }

    it { expect(Date.new).not_to be_uncertain }

    [:year, :month, :day].each do |part|
      it "should not be uncertain by default (#{part})" do
        expect(Date.new.uncertain?(part)).to eq(false)
      end

      it "should be uncertain if set to uncertain (#{part})" do
        date.uncertain.send("#{part}=", true)
        expect(date.uncertain?(part)).to eq(true)
      end

      ([:year, :month, :day] - [part]).each do |other|
        it "#{other} should not be uncertain if #{part} is uncertain" do
          date.uncertain.send("#{part}=", true)
          expect(date.uncertain?(other)).to eq(false)
        end
      end
    end
  end

  describe '#with' do
    let(:date) { EDTF.parse('2004-06?-11') }

    def parts(date, predicate)
      Date::PRECISION.select { |part| date.public_send(predicate, part) }
    end

    it 'returns a copy' do
      expect(date.with).to eql(date)
      expect(date.with).not_to equal(date)
    end

    it 'replaces the precision' do
      expect(date.with(precision: :month)).to be_month_precision
    end

    it 'replaces the uncertain parts' do
      expect(parts(date.with(uncertain: :day), :uncertain?)).to eq([:day])
      expect(parts(date.with(uncertain: [:year, :day]), :uncertain?)).to eq([:year, :day])
      expect(date.with(uncertain: [])).not_to be_uncertain
    end

    it 'replaces the approximate parts' do
      copy = date.with(approximate: [:year, :month])
      expect(parts(copy, :approximate?)).to eq([:year, :month])
      expect(parts(copy, :uncertain?)).to eq([:year, :month])
    end

    it 'keeps the attributes not given' do
      copy = date.with(approximate: :day)
      expect(copy.precision).to eq(:day)
      expect(parts(copy, :uncertain?)).to eq([:year, :month])
    end

    it 'does not change the original' do
      expect { date.with(uncertain: [], precision: :year) }.not_to change { date.edtf }
    end

    it 'rejects unknown attributes' do
      expect { date.with(year: 2005) }.to raise_error(ArgumentError)
    end

    it 'rejects invalid precisions' do
      expect { date.with(precision: :week) }.to raise_error(ArgumentError)
    end
  end

  describe 'uncertain/approximate hash' do
    it 'is 0 by default' do
      expect(Date.new().send(:ua_hash)).to eq(0)
    end

    it 'is 8 for approximate year' do
      expect(Date.new.approximate!(:year).send(:ua_hash)).to eq(8)
    end
  end

  describe 'sorting and comparisons' do
    let(:xmas) { Date.new(2011, 12, 24) }
    let(:new_years_eve) { Date.new(2011, 12, 31) }

    describe '#values' do
      it 'returns [2011,12,24] for christmas' do
        expect(xmas.values).to eq([2011, 12, 24])
      end

      it 'returns [2011,12] for christmas with month precision' do
        expect(xmas.month_precision!.values).to eq([2011, 12])
      end

      it 'returns [2011] for christmas with year precision' do
        expect(xmas.year_precision!.values).to eq([2011])
      end
    end

    describe '#<=>' do
      it '2009-12-24 should be less than 2011-12-31' do
        expect(Date.new(2009, 12, 24)).to be < Date.new(2011, 12, 31)
      end

      it '2009-12-24 should be less than 2011-12' do
        expect(Date.new(2009, 12, 24)).to be < EDTF.parse('2011-12')
      end

      it '2009-12-24 should be less than 2011' do
        expect(Date.new(2009, 12, 24)).to be < EDTF.parse('2011')
      end
    end

    describe '#eql? and #hash' do
      it 'distinguishes dates with different EDTF attributes (#49)' do
        a = EDTF.parse!('1972%')
        b = EDTF.parse!('1972-XX-XX')
        h = { a => 1, b => 2 }

        expect(a).not_to eql(b)
        expect(h.size).to eq(2)
        expect(h[a]).to eq(1)
      end

      it 'distinguishes precision' do
        expect(Date.new(1972)).not_to eql(Date.new(1972).year_precision!)
      end

      it 'distinguishes uncertain and approximate dates' do
        expect(EDTF.parse('1972')).not_to eql(EDTF.parse('1972?'))
        expect(EDTF.parse('1972?')).not_to eql(EDTF.parse('1972~'))
      end

      it 'distinguishes unspecified dates' do
        expect(EDTF.parse('1972-01-01')).not_to eql(EDTF.parse('1972-01-XX'))
      end

      it 'distinguishes calendars', legacy: true do
        expect(EDTF.parse('2001-02-03^xyz')).not_to eql(EDTF.parse('2001-02-03'))
      end

      it 'treats dates with the same EDTF attributes as equal' do
        a, b = EDTF.parse('1972?-XX~'), EDTF.parse('1972?-XX~')
        expect(a).to eql(b)
        expect(a.hash).to eq(b.hash)
      end

      it 'ignores unset or cleared EDTF attributes' do
        a = Date.new(1972, 1, 1)
        b = Date.new(1972, 1, 1).day_precision!.uncertain!.certain!

        expect(a).to eql(b)
        expect(a.hash).to eq(b.hash)
      end

      it 'uses the original hash for regular dates' do
        d = Date.new(1972, 1, 1)
        expect(d.hash).to eq(d.original_hash)
      end
    end

    describe '#==' do
      it "xmas and new year's eve are not equal" do
        expect(xmas).not_to eq(new_years_eve)
      end

      it "xmas and new year's eve are equal using month precision" do
        expect(xmas.month_precision!).to eq(new_years_eve.month_precision!)
      end

      it 'xmas and january 24 are not equal using month precision' do
        expect(xmas.month_precision!).not_to eq(xmas.month_precision!.next)
      end

      it "xmas and new year's eve are equal using year precision" do
        expect(xmas.year_precision!).to eq(new_years_eve.year_precision!)
      end
    end
  end
end
