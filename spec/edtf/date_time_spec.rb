module EDTF
  describe DateTime do
    def time(*values, **options)
      DateTime.new(*values, **options)
    end

    it_behaves_like 'a period' do
      let(:period) { EDTF.parse('2004-01-01T10:10:10+05:00') }
    end

    it_behaves_like 'a period' do
      let(:period) { EDTF.parse('2001-02-03T09:30:01') }
    end

    describe '.new' do
      it 'is a frozen Ruby time' do
        t = time(2004, 1, 1, 10, 10, 10, offset: 300)
        expect(t).to be_a(::Time).and be_frozen
        expect([t.year, t.month, t.day, t.hour, t.min, t.sec, t.utc_offset]).to eq([2004, 1, 1, 10, 10, 10, 18000])
      end

      it 'takes the offset in minutes' do
        expect(time(2004, 1, 1, offset: -720).offset).to eq(-720)
        expect(time(2004, 1, 1, offset: 0)).to be_utc
      end

      it 'is floating without an offset, on the UTC clock' do
        t = time(2004, 1, 1, 10)
        expect(t).to be_floating
        expect([t.offset, t.utc_offset, t.hour]).to eq([nil, 0, 10])
        expect(time(2004, 1, 1, 10, offset: 0)).not_to be_floating
      end

      it 'keeps fractional seconds' do
        expect(time(2016, 5, 2, 16, 54, Rational(59042, 1000)).subsec).to eq(Rational(42, 1000))
      end

      it 'rolls 24:00 over to the next day' do
        expect(EDTF.parse('2016-05-02T24:00:00').edtf).to eq('2016-05-03T00:00:00')
      end
    end

    describe '#edtf' do
      {
        '2001-02-03T09:30:01' => '2001-02-03T09:30:01',
        '2004-01-01T10:10:10Z' => '2004-01-01T10:10:10Z',
        '2004-01-01T10:10:10+00:00' => '2004-01-01T10:10:10Z',
        '2004-01-01T10:10:10+05:00' => '2004-01-01T10:10:10+05:00',
        '1985-04-12T23:20:30+04:30' => '1985-04-12T23:20:30+04:30',
        '2016-05-02T16:54:59-12:00' => '2016-05-02T16:54:59-12:00'
      }.each do |string, edtf|
        it "is #{edtf} for #{string}" do
          expect(EDTF.parse(string).edtf).to eq(edtf)
        end
      end

      it 'writes fractional seconds without trailing zeros' do
        expect(time(2016, 5, 2, 16, 54, Rational(59042, 1000), offset: 0).edtf).to eq('2016-05-02T16:54:59.042Z')
        expect(time(2016, 5, 2, 16, 54, Rational(594, 10)).edtf).to eq('2016-05-02T16:54:59.4')
      end

      it 'pads and signs years' do
        expect(time(-300, 8, 12).edtf).to eq('-0300-08-12T00:00:00')
        expect(time(14, 1, 1).edtf).to eq('0014-01-01T00:00:00')
      end

      it 'is also the string representation' do
        t = EDTF.parse('2004-01-01T10:10:10Z')
        expect(t.to_s).to eq('2004-01-01T10:10:10Z')
        expect(t.inspect).to eq('#<EDTF::DateTime 2004-01-01T10:10:10Z>')
        expect(t.iso8601).to eq('2004-01-01T10:10:10Z')
      end
    end

    describe 'bounds' do
      it 'are the calendar date in the time\'s own offset' do
        t = EDTF.parse('2004-01-01T02:10:10+05:00')
        expect(t.to_range).to eq(::Date.new(2004, 1, 1)..::Date.new(2004, 1, 1))
        expect(t.getutc.day).to eq(31)
      end

      it 'have a precision finer than a day' do
        expect(EDTF.parse('2004-01-01T02:10:10').precision).to eq(:second)
      end
    end

    describe 'comparison' do
      let(:a) { EDTF.parse('2004-01-01T10:00:00Z') }
      let(:b) { EDTF.parse('2004-01-01T15:00:00+05:00') }

      it 'compares times as instants' do
        expect(a).to eq(b)
        expect(a).to eq(::Time.utc(2004, 1, 1, 10))
        expect(a).to be < EDTF.parse('2004-01-01T10:00:01Z')
      end

      it 'eql? includes the offset and floating' do
        expect(a).not_to eql(b)
        expect(a).to eql(EDTF.parse('2004-01-01T10:00:00Z'))
        expect(a).to eql(::Time.utc(2004, 1, 1, 10))
        expect(EDTF.parse('2004-01-01T10:00:00')).not_to eql(a)
        expect(EDTF.parse('2004-01-01T10:00:00').hash).not_to eq(a.hash)
      end

      it 'compares with dates and periods by its own calendar date, after the day' do
        expect(a <=> EDTF.parse('2004-01-01')).to eq(1)
        expect(EDTF.parse('2004-01-01') <=> a).to eq(-1)
        expect(a <=> EDTF.parse('2004-01-02')).to eq(-1)
        expect(a <=> ::Date.new(2003, 12, 31)).to eq(1)
        expect(EDTF.parse('2004')).to be_cover(a)
        expect(EDTF.parse('2004-01-02')).not_to be_cover(EDTF.parse('2004-01-01T23:00:00-05:00'))
      end
    end

    describe 'conversions' do
      let(:t) { EDTF.parse('2004-01-01T10:00:00+05:00') }

      it 'returns plain times from math, getutc and getlocal' do
        expect(t + 60).to be_instance_of(::Time)
        expect(t.getutc).to be_instance_of(::Time).and eq(t)
        expect(t.getlocal('+01:00').hour).to eq(6)
      end

      it 'raises on mutating conversions, like any frozen time' do
        expect { t.utc }.to raise_error(FrozenError)
      end

      it 'converts to a plain date' do
        expect(t.to_date).to eq(::Date.new(2004, 1, 1))
      end
    end

    describe '#with' do
      let(:t) { EDTF.parse('2004-01-01T10:00:00+05:00') }

      it 'replaces the given values' do
        expect(t.with(hour: 11).edtf).to eq('2004-01-01T11:00:00+05:00')
        expect(t.with(offset: nil).edtf).to eq('2004-01-01T10:00:00')
        expect(t.with).to equal(t)
        expect { t.with(zone: 'UTC') }.to raise_error(ArgumentError)
      end

      it 'names minutes and seconds like Ruby (min, sec)' do
        expect(t.with(min: 30, sec: 5).edtf).to eq('2004-01-01T10:30:05+05:00')
        expect { t.with(minute: 30) }.to raise_error(ArgumentError)
      end
    end

    describe 'stepping' do
      it 'steps by second, keeping the offset' do
        expect(EDTF.parse('2004-01-01T23:59:59+05:00').succ.edtf).to eq('2004-01-02T00:00:00+05:00')
        expect(EDTF.parse('2004-01-01T10:10:10').prev(60).edtf).to eq('2004-01-01T10:09:10')
        expect(EDTF.parse('2004-01-01T10:10:10Z').next).to be_an(EDTF::DateTime)
      end
    end

    describe 'coverage' do
      let(:t) { EDTF.parse('2004-01-01T10:10:10Z') }

      it 'covers only the same instant' do
        expect(t).to be_cover(EDTF.parse('2004-01-01T15:10:10+05:00'))
        expect(t).to be_cover(::Time.utc(2004, 1, 1, 10, 10, 10))
        expect(t).not_to be_cover(EDTF.parse('2004-01-01T23:00:00Z'))
        expect(t === EDTF.parse('2004-01-01T23:00:00Z')).to be false
        expect(t).not_to respond_to(:include?)
      end
    end

    describe 'construction and copies' do
      let(:t) { EDTF.parse('2004-01-01T10:10:10') }

      it 'hides Ruby constructors that would skip initialize' do
        %i[now at local utc].each do |name|
          expect { DateTime.public_send(name) }.to raise_error(NoMethodError)
        end
      end

      it 'stays frozen and floating through dup and Marshal' do
        [t.dup, Marshal.load(Marshal.dump(t))].each do |copy|
          expect(copy).to be_frozen.and be_floating.and eql(t)
        end
      end

      it 'returns plain times from getgm' do
        expect(t.getgm).to be_instance_of(::Time)
      end
    end
  end
end
