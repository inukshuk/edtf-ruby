# Largely ported from edtf.js test/date.js; months are 1-based here.
module EDTF
  describe Date do
    def date(*values, **qualifiers)
      Date.new(*values, **qualifiers)
    end

    # A date from a mask like "2X1X-0X-15": X digits are unspecified
    # and hold the lowest value.
    def masked(string)
      digits = string.delete_prefix('-').delete('-')
      mask = Bitmask.new(Bitmask.compute(digits))
      values = mask.min(Bitmask.values(digits, normalize: false))
      values[0] = -values[0] if string.start_with?('-')
      Date.new(*values, unspecified: mask)
    end

    it_behaves_like 'a period' do
      let(:period) { date(2004, 6, 11) }
    end

    it_behaves_like 'a period' do
      let(:period) { EDTF.parse('2004-06?') }
    end

    it_behaves_like 'a period' do
      let(:period) { EDTF.parse('-199X') }
    end

    describe '.new' do
      it 'is a frozen, proleptic Gregorian Ruby date' do
        d = date(1582, 10, 10)
        expect(d).to be_a(::Date).and be_frozen.and be_gregorian
        expect([d.year, d.month, d.day]).to eq([1582, 10, 10])
      end

      it 'takes the precision from the number of values' do
        expect([date(1980), date(1980, 2), date(1980, 2, 23)].map(&:precision))
          .to eq(%i[year month day])
      end

      it 'accepts qualified parts as Symbols, Arrays, masks or true' do
        expect(date(2004, 6, 11, uncertain: :month).uncertain).to eq(Bitmask.new(:month))
        expect(date(2004, 6, 11, uncertain: [:year, :day]).uncertain).to eq(Bitmask.new(Bitmask::YEAR | Bitmask::DAY))
        expect(date(2004, 6, 11, uncertain: Bitmask::YM).uncertain).to eq(Bitmask.new(Bitmask::YM))
        expect(date(2004, 6, uncertain: true).uncertain).to eq(Bitmask.new(Bitmask::YM))
      end

      it 'drops qualified parts beyond the precision' do
        expect(date(2004, uncertain: [:year, :month]).uncertain).to eq(Bitmask.new(:year))
      end

      it 'rejects invalid dates' do
        expect { date(2015, 2, 29) }.to raise_error(ArgumentError)
        expect { date(2015, nil, 2) }.to raise_error(ArgumentError)
      end

      it 'is used for parsed dates across the 10-day correction' do
        (4..15).each do |mday|
          d = EDTF.parse('1582-10-%02d' % mday)
          expect(d).to be_gregorian
          expect([d.year, d.month, d.mday]).to eq([1582, 10, mday])
        end
      end
    end

    describe '#values' do
      it 'has as many values as the precision' do
        expect(date(2016).values).to eq([2016])
        expect(date(2016, 2).values).to eq([2016, 2])
        expect(date(2016, 2, 3).values).to eq([2016, 2, 3])
      end

      it 'holds the lowest values of unspecified digits' do
        expect(EDTF.parse('2016-XX').values).to eq([2016, 1])
        expect(EDTF.parse('20XX').values).to eq([2000])
        expect(EDTF.parse('-20XX').values).to eq([-2000])
        expect(EDTF.parse('-201X').values).to eq([-2010])
      end
    end

    describe '#edtf' do
      {
        [2014] => '2014', [123] => '0123', [14] => '0014', [0] => '0000',
        [-2] => '-0002', [-42] => '-0042', [-9999] => '-9999',
        [2014, 4] => '2014-04', [123, 1] => '0123-01', [14, 9] => '0014-09',
        [0, 1] => '0000-01', [-2, 12] => '-0002-12',
        [2014, 4, 15] => '2014-04-15', [2016, 2, 29] => '2016-02-29'
      }.each do |values, edtf|
        it "is #{edtf} for #{values}" do
          expect(date(*values).edtf).to eq(edtf)
        end
      end

      {
        [[2014, 4, 15], :day] => '2014-04-XX',
        [[2014, 4, 15], :month] => '2014-XX-15',
        [[2014, 4, 15], :year] => 'XXXX-04-15',
        [[2014, 4, 15], 'xxxxxxdd'] => 'XXXX-XX-15',
        [[-300, 4, 15], 'yyxxmmdd'] => '-03XX-04-15',
        [[2014, 4, 15], 'yxyxmxdd'] => '2X1X-0X-15'
      }.each do |(values, mask), edtf|
        it "masks unspecified digits: #{edtf}" do
          expect(date(*values, unspecified: mask).edtf).to eq(edtf)
        end
      end

      {
        { uncertain: true } => '2014-04-15?',
        { uncertain: :day } => '2014-04-?15',
        { uncertain: 'xxxxxxdd' } => '2014-04?-15',
        { uncertain: :month } => '2014-?04-15',
        { uncertain: :year } => '2014?-04-15',
        { uncertain: 'xxxxxxdd', approximate: :day } => '2014-04?-~15',
        { uncertain: :month, approximate: :month } => '2014-%04-15',
        { uncertain: :year, approximate: :year } => '2014%-04-15',
        { uncertain: :year, approximate: 'xxxxxxdd' } => '2014?-04~-15',
        { uncertain: 'xxxxmmxx' } => '2014?-04-?15',
        { uncertain: 'yyyyxxxx' } => '2014-?04-?15'
      }.each do |qualifiers, edtf|
        it "marks qualified parts: #{edtf}" do
          expect(date(2014, 4, 15, **qualifiers).edtf).to eq(edtf)
        end
      end

      it 'is also the string representation' do
        d = EDTF.parse('2004-06?')
        expect(d.to_s).to eq('2004-06?')
        expect(d.inspect).to eq('#<EDTF::Date 2004-06?>')
        expect(d.iso8601).to eq('2004-06-01')
      end
    end

    describe '#begin and #end' do
      {
        '2016' => %w[2016-01-01 2016-12-31],
        '2016-02' => %w[2016-02-01 2016-02-29],
        '2017-02' => %w[2017-02-01 2017-02-28],
        '2016-02-01' => %w[2016-02-01 2016-02-01],
        '2016-01-XX' => %w[2016-01-01 2016-01-31],
        '2016-02-XX' => %w[2016-02-01 2016-02-29],
        '2017-02-XX' => %w[2017-02-01 2017-02-28],
        '2016-09-XX' => %w[2016-09-01 2016-09-30],
        '2016-XX' => %w[2016-01-01 2016-12-31],
        '20XX' => %w[2000-01-01 2099-12-31],
        '201X' => %w[2010-01-01 2019-12-31],
        'XXXX' => %w[0000-01-01 9999-12-31],
        '-201X' => %w[-2019-01-01 -2010-12-31],
        '-1999-XX' => %w[-1999-01-01 -1999-12-31]
      }.each do |string, bounds|
        it "are #{bounds.join(' and ')} for #{string}" do
          d = EDTF.parse(string)
          expect([d.begin, d.end].map(&:iso8601)).to eq(bounds)
        end
      end

      {
        '20XX-01-XX' => %w[2000-01-01 2099-01-31],
        '2016-01-0X' => %w[2016-01-01 2016-01-09],
        '2016-01-1X' => %w[2016-01-10 2016-01-19],
        '2016-01-3X' => %w[2016-01-30 2016-01-31],
        '2016-02-2X' => %w[2016-02-20 2016-02-29],
        '2017-02-2X' => %w[2017-02-20 2017-02-28],
        '2016-01-X1' => %w[2016-01-01 2016-01-31],
        '2016-01-X2' => %w[2016-01-02 2016-01-22],
        '2016-02-X9' => %w[2016-02-09 2016-02-29],
        '2017-02-X9' => %w[2017-02-09 2017-02-19],
        '2016-0X' => %w[2016-01-01 2016-09-30],
        '2016-1X' => %w[2016-10-01 2016-12-31],
        '2016-X1' => %w[2016-01-01 2016-11-30],
        '2016-X2' => %w[2016-02-01 2016-12-31],
        '2016-01-X0' => %w[2016-01-10 2016-01-30],
        '20X3' => %w[2003-01-01 2093-12-31],
        '2X1X' => %w[2010-01-01 2919-12-31],
        'X0X6' => %w[0006-01-01 9096-12-31],
        'XXX6' => %w[0006-01-01 9996-12-31],
        '201X-02-04' => %w[2010-02-04 2019-02-04],
        '20XX-XX-04' => %w[2000-01-04 2099-12-04],
        '2X12-1X-X4' => %w[2012-10-04 2912-12-24],
        '1XXX' => %w[1000-01-01 1999-12-31],
        '-1XXX' => %w[-1999-01-01 -1000-12-31]
      }.each do |string, bounds|
        it "are #{bounds.join(' and ')} for #{string} (level 2)" do
          d = masked(string)
          expect([d.begin, d.end].map(&:iso8601)).to eq(bounds)
        end
      end

      it 'are plain dates' do
        expect(EDTF.parse('2004-06-11').begin).to be_instance_of(::Date)
      end
    end

    describe '#succ and #prev' do
      {
        '1980' => '1981', '-0001' => '0000', '-2019' => '-2018',
        '1980-08' => '1980-09', '-0001-12' => '0000-01', '2015-12' => '2016-01',
        '1980-08-24' => '1980-08-25', '-0001-12-31' => '0000-01-01',
        '2016-02-28' => '2016-02-29', '2015-02-28' => '2015-03-01'
      }.each do |string, succ|
        it "steps from #{string} to #{succ}" do
          expect(EDTF.parse(string).succ.edtf).to eq(succ)
          expect(EDTF.parse(succ).prev.edtf).to eq(string)
        end
      end

      it 'steps over unspecified digits' do
        d = EDTF.parse('201X')
        expect([d.succ, d.succ.succ, d.succ.prev].map(&:edtf)).to eq(%w[202X 203X 201X])
        expect([d.prev, d.prev.prev, d.prev.succ].map(&:edtf)).to eq(%w[200X 199X 201X])
        expect(d.prev).to eql(EDTF.parse('200X'))
        expect(d.succ).to eql(EDTF.parse('202X'))
      end

      it 'steps over unspecified digits of negative years' do
        d = EDTF.parse('-201X')
        expect([d.succ, d.succ.succ, d.succ.prev].map(&:edtf)).to eq(%w[-200X -199X -201X])
        expect([d.prev, d.prev.prev, d.prev.succ].map(&:edtf)).to eq(%w[-202X -203X -201X])
        expect(d.succ).to eql(EDTF.parse('-200X'))
      end

      it 'keeps the qualifiers' do
        expect(EDTF.parse('2004-06?').succ.edtf).to eq('2004-07?')
      end

      it 'is also #next' do
        expect(EDTF.parse('2004').next.edtf).to eq('2005')
      end

      it 'steps ranges and #upto/#downto by precision' do
        expect((EDTF.parse('2001')..EDTF.parse('2003')).map(&:edtf)).to eq(%w[2001 2002 2003])
        expect(EDTF.parse('2001-11').upto(EDTF.parse('2002-01')).map(&:edtf))
          .to eq(%w[2001-11 2001-12 2002-01])
        expect(EDTF.parse('2003').downto(EDTF.parse('2001')).map(&:edtf)).to eq(%w[2003 2002 2001])
      end

      it 'steps #upto and #downto plain dates by the units that reach them' do
        expect(EDTF.parse('2016').upto(::Date.new(2018, 1, 1)).map(&:edtf)).to eq(%w[2016 2017 2018])
        expect(EDTF.parse('2018').downto(::Date.new(2016, 12, 31)).map(&:edtf)).to eq(%w[2018 2017 2016])
      end
    end

    # Partly ported from edtf.js test/year.js; edtf.js needs a Year
    # class because JavaScript dates end at +275760.
    describe 'long years and significant digits' do
      it_behaves_like 'a period' do
        let(:period) { date(170000002) }
      end

      it_behaves_like 'a period' do
        let(:period) { date(-170000002) }
      end

      it 'are what Y-years parse to' do
        expect(EDTF.parse('Y170000002')).to eql(date(170000002))
        expect(EDTF.parse('Y-17E7')).to eql(date(-170000000))
      end

      it 'use the Y prefix beyond four digits' do
        expect(date(12015).edtf).to eq('Y12015')
        expect(date(-10001).edtf).to eq('Y-10001')
      end

      it 'add significant digits' do
        expect(date(2015, significant: 2).edtf).to eq('2015S2')
        expect(date(-24, significant: 2).edtf).to eq('-0024S2')
        expect(date(12345, significant: 1).edtf).to eq('Y12345S1')
      end

      {
        [1950, 2] => %w[1900-01-01 1999-12-31],
        [1950, 4] => %w[1950-01-01 1950-12-31],
        [1950, 5] => %w[1950-01-01 1950-12-31],
        [171010000, 3] => %w[171000000-01-01 171999999-12-31],
        [338800, 3] => %w[338000-01-01 338999-12-31],
        [-1950, 2] => %w[-1999-01-01 -1900-12-31]
      }.each do |(year, significant), bounds|
        it "cover the significant range: #{year}S#{significant}" do
          d = date(year, significant: significant)
          expect([d.begin, d.end].map(&:iso8601)).to eq(bounds)
        end
      end

      it 'compare by period; eql? includes significant digits' do
        expect(date(1950, significant: 2)).to eq(date(1999, significant: 2))
        expect(date(1950, significant: 2)).not_to eql(date(1999, significant: 2))
        expect(date(1950, significant: 2)).not_to eq(Century.new(19))
        expect(date(170000002)).to be > date(10000)
      end

      it 'step by year' do
        expect(date(10000).succ.edtf).to eq('Y10001')
        expect(date(10000).prev.edtf).to eq('9999')
        expect(date(1950, significant: 2).succ.edtf).to eq('1951S2')
      end

      it 'cannot be qualified or unspecified' do
        expect { date(12345, uncertain: :year) }.to raise_error(ArgumentError)
        expect { date(12345, unspecified: Bitmask::YYYX) }.to raise_error(ArgumentError)
        expect { date(1950, significant: 2).with(approximate: true) }.to raise_error(ArgumentError)
      end

      it 'need year precision beyond four digits' do
        expect { date(10000, 1) }.to raise_error(ArgumentError, /year precision/)
        expect { date(-10000, 1, 1) }.to raise_error(ArgumentError, /year precision/)
      end

      it 'need at least one significant digit' do
        expect { date(1950, significant: 0) }.to raise_error(ArgumentError)
      end

      it 'need year precision for significant digits' do
        expect { date(1950, 6, significant: 2) }.to raise_error(ArgumentError)
        expect(date(1950, significant: 2).with(significant: nil, precision: :month).edtf).to eq('1950-01')
      end
    end

    describe 'date math' do
      let(:d) { EDTF.parse('2004-06?') }

      it 'returns plain dates' do
        expect(d + 1).to be_instance_of(::Date).and eq(::Date.new(2004, 6, 2))
        expect(d - 1).to be_instance_of(::Date).and eq(::Date.new(2004, 5, 31))
        expect(d >> 1).to be_instance_of(::Date).and eq(::Date.new(2004, 7, 1))
        expect(d << 1).to be_instance_of(::Date).and eq(::Date.new(2004, 5, 1))
      end

      it 'subtracts dates' do
        expect(d - ::Date.new(2004, 5, 1)).to eq(31)
      end

      it 'returns plain dates from next_day, next_month and friends' do
        expect(d.next_day).to be_instance_of(::Date).and eq(::Date.new(2004, 6, 2))
        expect(d.prev_month(2)).to be_instance_of(::Date).and eq(::Date.new(2004, 4, 1))
        expect(d.next_year).to be_instance_of(::Date).and eq(::Date.new(2005, 6, 1))
      end
    end

    describe '#with' do
      let(:d) { EDTF.parse('2004-06?-11') }

      it 'returns self without changes' do
        expect(d.with).to equal(d)
      end

      it 'replaces the given attributes' do
        expect(d.with(uncertain: :day).edtf).to eq('2004-06-?11')
        expect(d.with(uncertain: []).edtf).to eq('2004-06-11')
        expect(d.with(approximate: true).edtf).to eq('2004-06?-11~')
        expect(d.with(unspecified: :day).edtf).to eq('2004-06-XX')
      end

      it 'changes the precision' do
        expect(d.with(precision: :month).edtf).to eq('2004-06?')
        expect(d.with(precision: :year).edtf).to eq('2004?')
        expect(EDTF.parse('2004').with(precision: :day).edtf).to eq('2004-01-01')
      end

      it 'returns a frozen copy and leaves the original unchanged' do
        expect(d.with(uncertain: [])).to be_frozen
        expect(d.edtf).to eq('2004-06?-11')
      end

      it 'replaces year, month and day' do
        expect(d.with(year: 2005, day: 12).edtf).to eq('2005-06?-12')
      end

      it 'rejects values beyond the precision' do
        expect { EDTF.parse('2016').with(month: 3) }.to raise_error(ArgumentError, /month beyond year/)
        expect(EDTF.parse('2016').with(month: 3, precision: :month).edtf).to eq('2016-03')
      end

      it 'rejects unknown attributes and precisions' do
        expect { d.with(week: 5) }.to raise_error(ArgumentError)
        expect { d.with(precision: :week) }.to raise_error(ArgumentError)
      end
    end

    describe 'construction and copies' do
      let(:d) { EDTF.parse('2016-05?') }

      it 'hides Ruby constructors that would skip initialize' do
        %i[today parse jd civil iso8601 strptime].each do |name|
          expect { Date.public_send(name) }.to raise_error(NoMethodError)
        end
      end

      it 'stays frozen through dup and Marshal' do
        expect(d.dup).to be_frozen.and eql(d)
        expect(Marshal.load(Marshal.dump(d))).to be_frozen.and eql(d)
      end

      it 'returns plain dates from calendar conversions' do
        expect(d.julian).to be_instance_of(::Date).and eq(::Date.new(2016, 5, 1))
        expect(d.new_start(::Date::ITALY)).to be_instance_of(::Date)
      end

      it 'has no ActiveSupport methods of its own' do
        expect(d).not_to respond_to(:advance)
        expect(d).not_to respond_to(:change)
      end
    end

    describe 'qualifier predicates' do
      let(:d) { EDTF.parse('2004?-06~') }

      it 'test the whole date or a part' do
        expect([d.uncertain?, d.uncertain?(:year), d.uncertain?(:month)]).to eq([true, true, false])
        expect([d.approximate?, d.approximate?(:year), d.approximate?(:month)]).to eq([true, true, true])
        expect([d.unspecified?, EDTF.parse('199X').unspecified?(:year)]).to eq([false, true])
      end
    end

    describe 'comparison' do
      it 'orders by begin, then end, then precision' do
        expect(date(1980)).to be < date(1980, 7)
        expect(EDTF.parse('198X')).to be > EDTF.parse('196X')
        expect(date(2004)).to be > date(2004, 1, 1)
        expect(date(2004) <=> EDTF.parse('2004-XX')).to eq(-1)
      end

      it 'compares with plain dates and times' do
        expect(date(2004, 6, 11) <=> ::Date.new(2004, 6, 11)).to eq(0)
        expect(date(2004) <=> ::Date.new(2004, 6, 11)).to eq(-1)
        expect(date(2004) <=> 2004).to be_nil
      end

      it 'sorts a time after the day it falls on, in its own offset' do
        expect(date(2004, 6, 11) <=> Time.new(2004, 6, 11, 23, 0, 0, '-05:00')).to eq(-1)
        expect(Time.new(2004, 6, 11, 23, 0, 0, '-05:00') <=> date(2004, 6, 11)).to eq(1)
        expect(date(2004, 6, 12) <=> Time.new(2004, 6, 11, 23, 0, 0, '-05:00')).to eq(1)
      end

      it '== means the same period, ignoring qualifiers' do
        expect(EDTF.parse('1906')).to eq(EDTF.parse('1906?'))
        expect(EDTF.parse('1906')).not_to eq(EDTF.parse('1906-01'))
        expect(EDTF.parse('2004-06-11?')).to eq(::Date.new(2004, 6, 11))
      end

      it 'eql? and hash include everything' do
        expect(EDTF.parse('1972')).not_to eql(EDTF.parse('1972?'))
        expect(EDTF.parse('1972?')).not_to eql(EDTF.parse('1972~'))
        expect(EDTF.parse('1972-01-01')).not_to eql(EDTF.parse('1972-01-XX'))
        expect(EDTF.parse('1972%')).not_to eql(EDTF.parse('1972-XX-XX'))

        a = date(1972, 1, uncertain: :year, approximate: :month, unspecified: :month)
        b = date(1972, 1, uncertain: :year, approximate: :month, unspecified: :month)
        expect(a).to eql(b)
        expect(a.hash).to eq(b.hash)
        expect({ EDTF.parse('1972') => 1, EDTF.parse('1972?') => 2 }.size).to eq(2)
      end

      it 'an unqualified day eql?s a plain date, with the same hash' do
        d = EDTF.parse('2004-06-11')
        expect(d).to eql(::Date.new(2004, 6, 11))
        expect(::Date.new(2004, 6, 11)).to eql(d)
        expect(d.hash).to eq(::Date.new(2004, 6, 11).hash)
        expect(EDTF.parse('2004-06-11?')).not_to eql(::Date.new(2004, 6, 11))
      end
    end

    describe 'coverage' do
      let(:d) { EDTF.parse('201X') }

      it 'covers dates, times and periods within its bounds' do
        expect(d).to be_cover(::Date.new(2015, 6, 1))
        expect(d).to be_cover(EDTF.parse('2015-06'))
        expect(d).to be_cover(Time.new(2019, 12, 31, 23, 0, 0, '-05:00'))
        expect(d).not_to be_cover(::Date.new(2020, 1, 1))
        expect(d === ::Date.new(2015, 6, 1)).to be true
      end

      it 'has no include?, like Ruby dates' do
        expect(d).not_to respond_to(:include?)
      end
    end
  end
end
