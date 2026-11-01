# Partly ported from edtf.js test/interval.js.
module EDTF
  describe Interval do
    def interval(string)
      EDTF.parse!(string)
    end

    it_behaves_like 'a period' do
      let(:period) { interval('2004-06/2006-08') }
    end

    it_behaves_like 'a period' do
      let(:period) { interval('1984?/2004~') }
    end

    it_behaves_like 'a period' do
      let(:period) { interval('2004/..') }
    end

    it_behaves_like 'a period' do
      let(:period) { interval('/2004') }
    end

    describe '.new' do
      it 'takes periods, :open or :unknown' do
        i = Interval.new(Date.new(2001), :open)
        expect([i.from, i.to]).to eq([Date.new(2001), :open])
        expect(Interval.new(:unknown, Season.new(2001, 21)).edtf).to eq('/2001-21')
      end

      it 'converts plain dates' do
        expect(Interval.new(::Date.new(2001, 2, 3), :open).from).to be_an(EDTF::Date)
      end

      it 'rejects anything else' do
        expect { Interval.new('2001', :open) }.to raise_error(ArgumentError)
        expect { Interval.new(2001, :open) }.to raise_error(ArgumentError)
      end

      it 'is what intervals parse to, with EDTF dates as ends' do
        i = interval('2004-06?/2006-08')
        expect([i.from, i.to]).to all(be_an(EDTF::Date))
        expect(i.from).to eql(EDTF.parse('2004-06?'))
      end
    end

    describe 'bounds' do
      {
        '2001/2003' => %w[2001-01-01 2003-12-31],
        '2004-02-01/2005' => %w[2004-02-01 2005-12-31],
        '2004-06-XX/2004-07-03' => %w[2004-06-01 2004-07-03],
        '2004/..' => ['2004-01-01', nil],
        '2004/' => ['2004-01-01', nil],
        '../2005' => [nil, '2005-12-31']
      }.each do |string, bounds|
        it "are #{bounds.map(&:inspect).join(' and ')} for #{string}" do
          i = interval(string)
          expect([i.begin, i.end].map { |bound| bound&.iso8601 }).to eq(bounds)
        end
      end

      it 'make beginless and endless ranges' do
        expect(interval('2004/..').to_range).to eq(::Date.new(2004, 1, 1)..)
      end
    end

    describe 'open and unknown ends' do
      it 'are reported' do
        expect([interval('2004/..').open?, interval('2004/..').unknown?]).to eq([true, false])
        expect([interval('/2004').open?, interval('/2004').unknown?]).to eq([false, true])
        expect([interval('2001/2003').open?, interval('2001/2003').unknown?]).to eq([false, false])
      end
    end

    describe '#precision' do
      it 'is the precision of the start, or else of the end' do
        expect(interval('1980-08/1994').precision).to eq(:month)
        expect(interval('../1994').precision).to eq(:year)
      end
    end

    describe 'iteration' do
      it 'yields the units of the start' do
        expect(interval('2001/2003').map(&:edtf)).to eq(%w[2001 2002 2003])
        expect(interval('1994-01/1994-03').map(&:edtf)).to eq(%w[1994-01 1994-02 1994-03])
        expect(interval('1984-06/2004-08').count).to eq(243)
        expect(interval('1582-10-01/1582-10-31').count).to eq(31)
      end

      it 'reaches the last unit that begins within the interval' do
        # edtf.js stops at 1994-01 here.
        expect(interval('1980-08/1994').to_a.last.edtf).to eq('1994-12')
      end

      it 'steps seasons' do
        expect(Interval.new(Season.new(1980, 21), Season.new(1980, 24)).map(&:edtf))
          .to eq(%w[1980-21 1980-22 1980-23 1980-24])
      end

      it 'fails for open or unknown intervals' do
        expect { interval('2004/..').to_a }.to raise_error(RangeError)
        expect { interval('/2004').first }.to raise_error(RangeError)
      end
    end

    describe 'coverage' do
      let(:q1) { interval('1994-01/1994-03') }

      it 'covers periods within its bounds' do
        expect(q1).to be_cover(EDTF.parse('1994-02'))
        expect(q1).to be_cover(EDTF.parse('1994-02-01'))
        expect(q1).not_to be_cover(EDTF.parse('1994'))
        expect(interval('2008-08-23/2011-07-01')).not_to be_cover(::Date.new(2011, 7, 2))
      end

      it 'includes covered periods of the same precision' do
        expect(q1).to be_include(EDTF.parse('1994-02'))
        expect(q1).not_to be_include(EDTF.parse('1994-02-01'))
        expect(q1).not_to be_include(EDTF.parse('1994'))
      end

      it 'reaches without limit at open or unknown ends' do
        expect(interval('2008/')).to be_cover(::Date.new(2030, 1, 1))
        expect(interval('/2008')).to be_cover(::Date.new(1900, 1, 1))
        expect(interval('2008/')).not_to be_cover(::Date.new(2007, 12, 31))
        expect(interval('2000/..')).to be === interval('2004/..')
        expect(interval('2000/2010')).not_to be === interval('2004/..')
        expect(interval('2000/2010')).to be === interval('2004/2005')
      end

      it 'covers seasons' do
        s80 = Interval.new(Season.new(1980, 21), Season.new(1980, 24))
        expect(s80).to be_cover(Season.new(1980, 22))
        expect(s80).to be_cover(EDTF.parse('1980-09'))
        expect(s80).to be_include(Season.new(1980, 22))
        expect(s80).not_to be_include(EDTF.parse('1980-09'))
      end
    end

    describe 'comparison' do
      it 'orders by bounds' do
        expect(interval('2007/2009')).to be > interval('2001/2002')
        expect(interval('2007/2009')).to be < interval('2008/2009')
        expect(interval('2007/2009')).to be > interval('2007/2008')
        expect(interval('2007/2009')).to eq(interval('2007/2009'))
      end

      it 'sorts open starts first and open ends last, unknown ends inside them' do
        intervals = %w[2004/.. 2004/2005 2003/ /2005 ../2005 2004/].map { |s| interval(s) }
        expect(intervals.sort.map(&:edtf)).to eq(%w[../2005 /2005 2003/ 2004/2005 2004/ 2004/..])
      end

      it 'tells open and unknown ends apart' do
        expect(interval('../2005')).to eq(interval('../2005'))
        expect(interval('../2005')).not_to eq(interval('/2005'))
      end

      it 'compares with dates, seasons and epochs as periods' do
        i = interval('2004/2005')
        expect(i <=> ::Date.new(2004, 6, 1)).to eq(-1)
        expect(::Date.new(2004, 6, 1) <=> i).to eq(1)
        expect(i).to be < Season.new(2004, 22)
        expect(Season.new(2004, 22)).to be > i
        expect(interval('2004/..')).to be > Decade.new(199)
        expect(Decade.new(199) <=> interval('1990/..')).to eq(-1)
      end

      it 'equals another period with the same bounds and precision' do
        expect(interval('2004/2004')).to eq(EDTF.parse('2004'))
        expect(interval('2004/2005')).not_to eq(interval('2004-01/2005-12'))
      end

      it 'eql? compares the ends, qualifiers included' do
        expect(interval('2004/2005')).to eql(interval('2004/2005'))
        expect(interval('2004?/2005')).not_to eql(interval('2004/2005'))
        expect(interval('2004?/2005').hash).to eq(interval('2004?/2005').hash)
      end
    end

    describe '#edtf' do
      it 'writes .. for open and nothing for unknown ends' do
        expect(Interval.new(:unknown, :unknown).edtf).to eq('/')
        expect(interval('2004-01-01/open').edtf).to eq('2004-01-01/..')
        expect(interval('unknown/2006').edtf).to eq('/2006')
        expect(interval('1984?/2004?~').edtf).to eq('1984?/2004%')
      end
    end

    describe '#with' do
      it 'replaces an end' do
        expect(interval('2004/2005').with(to: :open).edtf).to eq('2004/..')
        expect { interval('2004/2005').with(lower: :open) }.to raise_error(ArgumentError)
      end
    end

    it 'accepts reversed intervals, as 4.x does' do
      expect(interval('2008/2004').edtf).to eq('2008/2004')
    end
  end
end
