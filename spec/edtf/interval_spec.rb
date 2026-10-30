module EDTF
  describe Interval do

    describe 'the interval 2008/2011' do
      let(:interval) { EDTF.parse('2008/2011') }

      it { expect(interval).not_to be_open }
      it { expect(interval).not_to be_open_end }
      it { expect(interval).not_to be_unknown_start }
      it { expect(interval).not_to be_unknown_end }

      it 'has a length of 4' do
        expect(interval.to_a.length).to eq(4)
      end

      it '#step(2) yields the years 2008 and 2010' do
        expect(interval.step(2).map(&:year)).to eq([2008, 2010])
      end

      it 'the max date is 2011-12-31' do
        expect(interval.max.to_s).to eq('2011-12-31')
      end

      it 'the max date has year precision' do
        expect(interval.max).to be_year_precision
      end

      it 'the min date is 2008-01-01' do
        expect(interval.min.to_s).to eq('2008-01-01')
      end

      it 'the min date has year precision' do
        expect(interval.min).to be_year_precision
      end

      it 'includes the years 2008, 2009, 2010 and 2011' do
        expect(interval.to_a.map(&:year)).to eq([2008, 2009, 2010, 2011])
      end

      it 'does not include christmas day 2009' do
        expect(interval).not_to be_include(Date.new(2009, 12, 24))
      end

      it 'christmas day 2009 is less than max' do
        expect(Date.new(2009, 12, 24)).to be < interval.max
      end

      it 'christmas day 2009 is greater than min' do
        expect(Date.new(2009, 12, 24)).to be > interval.min
      end

      it 'covers christmas day 2009' do
        expect(interval).to be_cover(Date.new(2009, 12, 24))
      end

      it 'covers 2011-12-31' do
        expect(interval).to be_cover(Date.new(2011, 12, 31))
      end
    end

    describe 'the interval 2008-08-23/2011-07-01' do
      let(:interval) { EDTF.parse('2008-08-23/2011-07-01') }

      it 'includes christmas day 2009' do
        expect(interval).to be_include(Date.new(2009, 12, 24))
      end

      it 'covers christmas day 2009' do
        expect(interval).to be_cover(Date.new(2009, 12, 24))
      end

      it 'does not cover 2011-07-02' do
        expect(interval).not_to be_cover(Date.new(2011, 7, 2))
      end
    end

    describe 'the interval 2008-08-23/..' do
      let(:interval) { EDTF.parse('2008-08-23/..') }

      it { expect(interval).to be_open }
      it { expect(interval).to be_open_end }
      it { expect(interval).not_to be_unknown }
      it { expect(interval).not_to be_unknown_start }
      it { expect(interval).not_to be_unknown_end }

      it 'the min date is 2008-08-23' do
        expect(interval.min).to eq(Date.new(2008, 8, 23))
      end

      it 'the max date is nil' do
        expect(interval.max).to be nil
      end

      it 'includes christmas day 2009' do
        expect(interval).to be_include(Date.new(2009, 12, 24))
      end

      it 'covers christmas day 2009' do
        expect(interval).to be_cover(Date.new(2009, 12, 24))
      end

      it 'covers 2023-07-02' do
        expect(interval).to be_cover(Date.new(2023, 7, 2))
      end
    end

    describe 'the interval ../2008-08-23' do
      let(:interval) { EDTF.parse('../2008-08-23') }

      it { expect(interval).to be_open }
      it { expect(interval).to be_open_start }
      it { expect(interval).not_to be_open_end }
      it { expect(interval).not_to be_unknown }
      it { expect(interval).not_to be_unknown_start }
      it { expect(interval).not_to be_unknown_end }

      it 'the max date is 2008-08-23' do
        expect(interval.max).to eq(Date.new(2008, 8, 23))
      end

      it 'the min date is nil' do
        expect(interval.min).to be nil
      end

      it 'includes christmas day 2007' do
        expect(interval).to be_include(Date.new(2007, 12, 24))
      end

      it 'covers christmas day 2007' do
        expect(interval).to be_cover(Date.new(2007, 12, 24))
      end

      it 'covers 2003-07-02' do
        expect(interval).to be_cover(Date.new(2003, 7, 2))
      end
    end

    describe 'the interval 2008/' do
      let(:interval) { EDTF.parse('2008/') }

      it { expect(interval).to be_unknown }
      it { expect(interval).to be_unknown_end }
      it { expect(interval).not_to be_unknown_start }

      it 'the min date is 2008-01-01' do
        expect(interval.min.to_s).to eq('2008-01-01')
      end

      it 'the min date has year precision' do
        expect(interval.min).to be_year_precision
      end

      it 'the max date is nil' do
        expect(interval.max).to be nil
      end
    end

    describe 'the interval /2008' do
      let(:interval) { EDTF.parse('/2008') }

      it { expect(interval).to be_unknown }
      it { expect(interval).not_to be_unknown_end }
      it { expect(interval).to be_unknown_start }

      it 'the max date is 2008-12-31' do
        expect(interval.max.to_s).to eq('2008-12-31')
      end

      it 'the max date has year precision' do
        expect(interval.max).to be_year_precision
      end

      it 'the min date is nil' do
        expect(interval.min).to be nil
      end
    end

    describe 'comparisons' do
      it '2007/2009 should be greater than 2001/2002' do
        expect(EDTF.parse('2007/2009')).to be > EDTF.parse('2001/2002')
      end

      it '2007/2009 should be less than 2011/2012' do
        expect(EDTF.parse('2007/2009')).to be < EDTF.parse('2011/2012')
      end

      it '2007/2009 should be less than 2008/2009' do
        expect(EDTF.parse('2007/2009')).to be < EDTF.parse('2008/2009')
      end

      it '2007/2009 should be greater than 2007/2008' do
        expect(EDTF.parse('2007/2009')).to be > EDTF.parse('2007/2008')
      end

      it '2007/2009 should be greater than 2006/2007' do
        expect(EDTF.parse('2007/2009')).to be > EDTF.parse('2006/2007')
      end

      it '2007/2009 should be equal to 2007/2009' do
        expect(EDTF.parse('2007/2009')).to eq(EDTF.parse('2007/2009'))
      end

      describe 'with open or unknown ends' do
        it 'sorts open and unknown starts and ends as infinity' do
          intervals = %w{
            2004/.. 2004/2005 2003/ /2005 ../2005 2004/
          }.map { |s| EDTF.parse(s) }

          expect(intervals.sort).to eq(%w{
            ../2005 /2005 2003/ 2004/2005 2004/ 2004/..
          }.map { |s| EDTF.parse(s) })
        end

        it '../2005 should be equal to ../2005' do
          expect(EDTF.parse('../2005')).to eq(EDTF.parse('../2005'))
        end

        it '../2005 should not be equal to /2005' do
          expect(EDTF.parse('../2005')).not_to eq(EDTF.parse('/2005'))
        end

        it '2004/.. should be greater than 2004/2005' do
          expect(EDTF.parse('2004/..')).to be > EDTF.parse('2004/2005')
        end

        it 'can be compared to seasons and epochs' do
          interval = EDTF.parse('2004/..')
          expect(interval).to be < Season.new(2004, :summer)
          expect(Season.new(2004, :summer)).to be > interval
          expect(interval).to be > Decade.new(1990)
          expect(Decade.new(1990)).to be < interval
        end

        it 'compares seasons and epochs with the same start' do
          expect(Season.new(2004, :spring) <=> EDTF.parse('2004-03-01/..')).to eq(-1)
          expect(Decade.new(1990) <=> EDTF.parse('1990/..')).to eq(-1)
        end
      end

      describe 'with dates' do
        let(:interval) { EDTF.parse('2004/2005') }

        it 'is equal to covered dates' do
          expect(interval <=> Date.new(2004, 6, 1)).to eq(0)
          expect(Date.new(2004, 6, 1) <=> interval).to eq(0)
        end

        it 'is greater than earlier dates' do
          expect(interval <=> Date.new(1990, 1, 1)).to eq(1)
          expect(Date.new(1990, 1, 1) <=> interval).to eq(-1)
        end

        it 'is less than later dates' do
          expect(interval <=> Date.new(2010, 1, 1)).to eq(-1)
          expect(Date.new(2010, 1, 1) <=> interval).to eq(1)
        end

        it 'compares open starts' do
          interval = EDTF.parse('../2005')
          expect(interval <=> Date.new(1990, 1, 1)).to eq(0)
          expect(interval <=> Date.new(2010, 1, 1)).to eq(-1)
        end

        it 'compares seasons and epochs' do
          expect(Date.new(2004, 4, 1) <=> Season.new(2004, :spring)).to eq(0)
          expect(Date.new(2010, 1, 1) <=> Season.new(2004, :spring)).to eq(1)
          expect(Date.new(1980, 1, 1) <=> Decade.new(1990)).to eq(-1)
        end
      end
    end

    describe 'coverage with open or unknown ends' do
      it '2008/ covers dates from 2008 onward' do
        interval = EDTF.parse('2008/')
        expect(interval).to be_cover(Date.new(2008, 6, 1))
        expect(interval).to be_cover(Date.new(2030, 1, 1))
        expect(interval).not_to be_cover(Date.new(2007, 12, 31))
      end

      it '/2008 covers dates up to 2008' do
        interval = EDTF.parse('/2008')
        expect(interval).to be_cover(Date.new(1900, 1, 1))
        expect(interval).to be_cover(Date.new(2008, 12, 31))
        expect(interval).not_to be_cover(Date.new(2009, 1, 1))
      end

      it 'unbounded intervals cover everything' do
        expect(Interval.new(:unknown, :open)).to be_cover(Date.today)
      end

      it '2000/.. covers 2004/..' do
        expect(EDTF.parse('2000/..')).to be === EDTF.parse('2004/..')
      end

      it '2000/2010 does not cover 2004/..' do
        expect(EDTF.parse('2000/2010')).not_to be === EDTF.parse('2004/..')
      end

      it '2000/2010 covers 2004/2005' do
        expect(EDTF.parse('2000/2010')).to be === EDTF.parse('2004/2005')
      end
    end
  end
end
