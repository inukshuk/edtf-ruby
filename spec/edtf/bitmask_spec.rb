# Ported from edtf.js test/bitmask.js; months are 1-based here.
module EDTF
  describe Bitmask do
    def bm(value = 0)
      Bitmask.new(value)
    end

    describe 'instance' do
      it 'is zero by default' do
        expect(bm.to_i).to eq(0)
        expect(bm).to be_zero
        expect([bm.year?, bm.month?, bm.day?]).to eq([false, false, false])
      end

      it 'is immutable' do
        mask = bm(:day)
        expect(mask).to be_frozen
        expect(mask | :month).to eq(bm(Bitmask::MD))
        expect(mask).to eq(bm(:day))
      end

      it 'compares by value' do
        expect(bm(:year)).to eq(bm('xxxxmmdd'))
        expect(bm(:year)).to eql(bm(Bitmask::YEAR))
        expect(bm(:year).hash).to eq(bm(Bitmask::YEAR).hash)
        expect(bm(:year)).not_to eq(Bitmask::YEAR)
      end

      it 'rejects invalid values' do
        expect { bm(:week) }.to raise_error(ArgumentError)
        expect { bm('2016-XX') }.to raise_error(ArgumentError)
        expect { bm(1.5) }.to raise_error(ArgumentError)
      end

      describe '#masks' do
        it 'YYYYMMXX' do
          expect(bm(:day).masks(%w[YYYY MM DD]).join).to eq('YYYYMMXX')
        end

        it 'YYYYXXDD' do
          expect(bm(:month).masks(%w[YYYY MM DD]).join).to eq('YYYYXXDD')
        end

        it 'XXXXMMDD' do
          expect(bm(:year).masks(%w[YYYY MM DD]).join).to eq('XXXXMMDD')
        end

        it 'masks digit strings' do
          expect(bm(Bitmask::YYYX).masks(%w[2016 05])).to eq(%w[201X 05])
        end
      end

      describe '#to_s' do
        it 'YYYY-MM-DD' do
          expect(bm.to_s).to eq('YYYY-MM-DD')
        end

        it 'YYYY-MM-XX' do
          expect(bm(:day).to_s).to eq('YYYY-MM-XX')
        end
      end
    end

    describe '#max' do
      it 'year' do
        expect(bm.max([2016])).to eq([2016])
        expect(bm(:year).max([2016])).to eq([9999])
        expect(bm('yxyxmmdd').max([2016])).to eq([2919])
      end

      it 'month' do
        expect(bm.max([2016, 1])).to eq([2016, 1])
        expect(bm('yyyyxxdd').max([2016, 1])).to eq([2016, 12])
        expect(bm('yyyymxdd').max([2016, 1])).to eq([2016, 9])
        expect(bm('yyyymxdd').max([2016, 10])).to eq([2016, 12])
        expect(bm('yyyyxmdd').max([2016, 1])).to eq([2016, 11])
        expect(bm('yyyyxmdd').max([2016, 2])).to eq([2016, 12])
        expect(bm('yyyyxmdd').max([2016, 3])).to eq([2016, 3])
      end

      it 'day' do
        expect(bm.max([2016, 1, 1])).to eq([2016, 1, 1])
        expect(bm('yyyymmxx').max([2016, 1, 1])).to eq([2016, 1, 31])
        expect(bm('yyyymmxx').max([2016, 2, 1])).to eq([2016, 2, 29])
        expect(bm('yyyymmxx').max([2016, 4, 1])).to eq([2016, 4, 30])
      end

      it 'day in February of a common year' do
        expect(bm('yyyymmxx').max([2019, 2, 1])).to eq([2019, 2, 28])
        expect(bm('yyyymmxd').max([2019, 2, 9])).to eq([2019, 2, 19])
      end
    end

    describe '#min' do
      it 'year' do
        expect(bm.min([2016])).to eq([2016])
        expect(bm(:year).min([2016])).to eq([0])
        expect(bm('yxyxmmdd').min([2016])).to eq([2010])
      end

      it 'month' do
        expect(bm.min([2019, 11])).to eq([2019, 11])
        expect(bm('yyyyxxdd').min([2019, 11])).to eq([2019, 1])

        expect(bm('yyyymxdd').min([2019, 9])).to eq([2019, 1])
        expect(bm('yyyymxdd').min([2019, 10])).to eq([2019, 10])
        expect(bm('yyyymxdd').min([2019, 11])).to eq([2019, 10])
        expect(bm('yyyymxdd').min([2019, 12])).to eq([2019, 10])

        # edtf.js returns January for any XM mask
        expect(bm('yyyyxmdd').min([2019, 3])).to eq([2019, 3])
        expect(bm('yyyyxmdd').min([2019, 12])).to eq([2019, 2])
        expect(bm('yyyyxmdd').min([2019, 10])).to eq([2019, 10])
      end

      it 'day' do
        expect(bm.min([2019, 1, 11])).to eq([2019, 1, 11])
        expect(bm('yyyymmxx').min([2019, 1, 3])).to eq([2019, 1, 1])
        expect(bm('yyyymmxx').min([2019, 1, 13])).to eq([2019, 1, 1])
        expect(bm('yyyymmxx').min([2019, 1, 31])).to eq([2019, 1, 1])
        expect(bm('yyyymmdx').min([2019, 1, 3])).to eq([2019, 1, 1])
        expect(bm('yyyymmdx').min([2019, 1, 13])).to eq([2019, 1, 10])
        expect(bm('yyyymmdx').min([2019, 1, 31])).to eq([2019, 1, 30])
        expect(bm('yyyymmxd').min([2019, 1, 3])).to eq([2019, 1, 3])
        expect(bm('yyyymmxd').min([2019, 1, 13])).to eq([2019, 1, 3])
        expect(bm('yyyymmxd').min([2019, 1, 31])).to eq([2019, 1, 1])
        # edtf.js returns the 1st for X0
        expect(bm('yyyymmxd').min([2019, 1, 30])).to eq([2019, 1, 10])
      end
    end

    describe '#intersect?' do
      it 'true' do
        expect(bm(true)).to be_intersect(true)
        expect(bm(true)).to be_intersect(:day)
        expect(bm(true)).to be_intersect(:month)
        expect(bm(true)).to be_intersect(:year)
        expect(bm(true)).not_to be_intersect(false)
      end

      it 'day' do
        expect(bm(:day)).to be_intersect(:day)
        expect(bm(:day)).not_to be_intersect(:month)
        expect(bm(:day)).not_to be_intersect(:year)
        expect(bm(:day)).to be_intersect(true)
      end

      it 'month' do
        expect(bm(:month)).to be_intersect(:month)
        expect(bm(:month)).not_to be_intersect(:year)
        expect(bm(:month)).not_to be_intersect(:day)
        expect(bm(:month)).to be_intersect(true)
        expect(bm(:month)).not_to be_intersect(Bitmask::YEAR)
        expect(bm(:month)).to be_intersect(Bitmask::YM)
        expect(bm(:month)).to be_intersect(Bitmask::YMD)
      end

      it 'year' do
        expect(bm(:year)).to be_intersect(:year)
        expect(bm(:year)).not_to be_intersect(:day)
        expect(bm(:year)).not_to be_intersect(:month)
        expect(bm(:year)).to be_intersect(true)
        expect(bm(:year)).to be_intersect(Bitmask::YEAR)
        expect(bm(:year)).to be_intersect(Bitmask::YM)
        expect(bm(:year)).to be_intersect(Bitmask::YMD)
        expect(bm(:year)).to be_intersect(Bitmask::YYXX)
        expect(bm(:year)).to be_intersect(Bitmask::YYYX)
        expect(bm(:year)).to be_intersect(Bitmask::XXXX)
      end

      it 'false' do
        expect(bm(false)).not_to be_intersect(false)
        expect(bm(false)).not_to be_intersect(:day)
        expect(bm(false)).not_to be_intersect(:month)
        expect(bm(false)).not_to be_intersect(:year)
        expect(bm(false)).not_to be_intersect(true)
      end
    end

    describe 'qualifiers' do
      def qualify(*positions)
        positions.reduce(bm) { |mask, idx| mask.qualify(idx) }
      end

      it 'map qualifier positions to parts' do
        expect(qualify(0)).to eq(bm(:year))
        expect(qualify(3)).to eq(bm(Bitmask::YM))
        expect(qualify(5)).to eq(bm(true))
        expect(qualify(2, 4)).to eq(bm(Bitmask::MD))
      end

      it 'normalize when marked' do
        expect(qualify(0, 2).marks(%w[2016 05 31])).to eq(%w[2016 05? 31])
        expect(qualify(4).marks(%w[2016 05 31])).to eq(%w[2016 05 ?31])
        expect(qualify(5).marks(%w[2016 05 31])).to eq(%w[2016 05 31?])
        expect(qualify(0, 4).marks(%w[2016 05 31], '~')).to eq(%w[2016~ 05 ~31])
      end
    end

    describe '.values' do
      it 'XXXXXXXX' do
        expect(Bitmask.values('XXXXXXXX')).to eq([0, 1, 1])
        expect(Bitmask.values('XXXXXXXX', digit: 9)).to eq([9999, 12, 31])
      end

      it 'XXXXXXDD' do
        expect(Bitmask.values('XXXXXX31')).to eq([0, 1, 31])
        expect(Bitmask.values('XXXXXX31', digit: 9)).to eq([9999, 12, 31])
      end

      it 'XXXXMMXX' do
        expect(Bitmask.values('XXXX05XX')).to eq([0, 5, 1])
        expect(Bitmask.values('XXXX05XX', digit: 9)).to eq([9999, 5, 31])
        expect(Bitmask.values('XXXX02XX', digit: 9)).to eq([9999, 2, 29])
        expect(Bitmask.values('XXXX06XX', digit: 9)).to eq([9999, 6, 30])
      end

      it 'YYYYXXXX' do
        expect(Bitmask.values('2014XXXX')).to eq([2014, 1, 1])
        expect(Bitmask.values('2014XXXX', digit: 9)).to eq([2014, 12, 31])
      end

      it 'XXXXXXDX' do
        expect(Bitmask.values('XXXXXX3X')).to eq([0, 1, 30])
        expect(Bitmask.values('XXXXXX3X', digit: 9)).to eq([9999, 12, 31])
        expect(Bitmask.values('XXXXXX2X')).to eq([0, 1, 20])
        expect(Bitmask.values('XXXXXX2X', digit: 9)).to eq([9999, 12, 29])
      end

      it 'XXXXMXXX' do
        expect(Bitmask.values('XXXX0XXX')).to eq([0, 1, 1])
        expect(Bitmask.values('XXXX0XXX', digit: 9)).to eq([9999, 9, 30])
        expect(Bitmask.values('XXXX1XXX')).to eq([0, 10, 1])
        expect(Bitmask.values('XXXX1XXX', digit: 9)).to eq([9999, 12, 31])
      end

      it 'XXXXMX' do
        expect(Bitmask.values('XXXX0X')).to eq([0, 1])
        expect(Bitmask.values('XXXX0X', digit: 9)).to eq([9999, 9])
        expect(Bitmask.values('XXXX1X')).to eq([0, 10])
        expect(Bitmask.values('XXXX1X', digit: 9)).to eq([9999, 12])
      end

      it 'can skip normalization' do
        expect(Bitmask.values('XXXXXXXX', normalize: false)).to eq([0, 0, 0])
      end
    end
  end
end
