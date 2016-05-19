module EDTF
  describe 'Interval' do

    describe 'the interval 2008/2011' do
      let(:interval) { Date.edtf('2008/2011') }

			it { expect(interval).not_to be_open }
			it { expect(interval).not_to be_open_end }
			it { expect(interval).not_to be_unknown_start }
			it { expect(interval).not_to be_unknown_end }

      it 'has a length of 4' do
        expect(interval.to_a.length).to eq(4)
      end

      it '#step(2) yields the years 2008 and 2010' do
        expect(interval.step(2).map(&:year)).to eq([2008,2010])
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
        expect(interval).not_to be_include(Date.new(2009,12,24))
      end

      it 'christmas day 2009 is less than max' do
        expect(Date.new(2009,12,24)).to be < interval.max
      end

      it 'christmas day 2009 is greater than min' do
        expect(Date.new(2009,12,24)).to be > interval.min
      end

      it 'covers christmas day 2009' do
        expect(interval).to be_cover(Date.new(2009,12,24))
      end

      it 'covers 2011-12-31' do
        expect(interval).to be_cover(Date.new(2011,12,31))
      end
    end

    describe 'the interval 2008-08-23/2011-07-01' do
      let(:interval) { Date.edtf('2008-08-23/2011-07-01') }

      it 'includes christmas day 2009' do
        expect(interval).to be_include(Date.new(2009,12,24))
      end

      it 'covers christmas day 2009' do
        expect(interval).to be_cover(Date.new(2009,12,24))
      end

      it 'does not cover 2011-07-02' do
        expect(interval).not_to be_cover(Date.new(2011,07,02))
      end
    end

    describe 'the interval 2008-08-23/open' do
      let(:interval) { Date.edtf('2008-08-23/open') }

      it { expect(interval).to be_open }
      it { expect(interval).to be_open_end }
      it { expect(interval).not_to be_unknown }
      it { expect(interval).not_to be_unknown_start }
      it { expect(interval).not_to be_unknown_end }

      it 'the min date is 2008-08-23' do
        expect(interval.min).to eq(Date.new(2008,8,23))
      end

      it 'the max date is nil' do
        expect(interval.max).to be nil
      end

      it 'includes christmas day 2009' do
        expect(interval).to be_include(Date.new(2009,12,24))
      end

      it 'covers christmas day 2009' do
        expect(interval).to be_cover(Date.new(2009,12,24))
      end

      it 'covers 2023-07-02' do
        expect(interval).to be_cover(Date.new(2023,07,02))
      end

    end

    describe 'comparisions' do
      it '2007/2009 should be greater than 2001/2002' do
        expect(Date.edtf('2007/2009')).to be > Date.edtf('2001/2002')
      end

      it '2007/2009 should be less than 2011/2012' do
        expect(Date.edtf('2007/2009')).to be < Date.edtf('2011/2012')
      end

      it '2007/2009 should be less than 2008/2009' do
        expect(Date.edtf('2007/2009')).to be < Date.edtf('2008/2009')
      end

      it '2007/2009 should be greater than 2007/2008' do
        expect(Date.edtf('2007/2009')).to be > Date.edtf('2007/2008')
      end

      it '2007/2009 should be greater than 2006/2007' do
        expect(Date.edtf('2007/2009')).to be > Date.edtf('2006/2007')
      end

      it '2007/2009 should be equal to 2007/2009' do
        expect(Date.edtf('2007/2009')).to eq(Date.edtf('2007/2009'))
      end
    end

    it 'may not have an open start' do
      expect(
        proc { Interval.new(:open, Date.today) }
      ).to raise_error(ArgumentError)
    end
  end
end
