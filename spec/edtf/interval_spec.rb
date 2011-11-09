module EDTF
  describe 'Interval' do
    
    describe 'the interval 2008/2011' do
      let(:interval) { Date.edtf('2008/2011') }

			it { interval.should_not be_open }      
			it { interval.should_not be_open_end }
			it { interval.should_not be_unknown_start }
			it { interval.should_not be_unknown_end }
			
			it 'has a length of 4' do
				interval.to_a.length.should == 4
			end
			
			it '#step(2) yields the years 2008 and 2010' do
				interval.step(2).map(&:year).should == [2008,2010]
			end
			
			it 'the max date is 2011-12-31' do
				interval.max.to_s.should == '2011-12-31'
			end

			it 'the max date has year precision' do
				interval.max.should be_year_precision
			end

			it 'the min date is 2008-01-01' do
				interval.min.to_s.should == '2008-01-01'
			end

			it 'the min date has year precision' do
				interval.min.should be_year_precision
			end
			
			
      it 'includes the years 2008, 2009, 2010 and 2011' do
        interval.to_a.map(&:year).should == [2008, 2009, 2010, 2011]
      end
      
      it 'does not include christmas day 2009' do
        interval.should_not be_include(Date.new(2009,12,24))
      end

 			it 'christmas day 2009 is less than max' do
				Date.new(2009,12,24).should < interval.max
			end

 			it 'christmas day 2009 is greater than min' do
				Date.new(2009,12,24).should > interval.min
			end
     
      it 'covers christmas day 2009' do
        interval.should be_cover(Date.new(2009,12,24))
      end
			
      it 'covers 2011-12-31' do
        interval.should be_cover(Date.new(2011,12,31))
      end

    end

    describe 'the interval 2008-08-23/2011-07-01' do
      let(:interval) { Date.edtf('2008-08-23/2011-07-01') }
      
      it 'includes christmas day 2009' do
        interval.should be_include(Date.new(2009,12,24))
      end
      
      it 'covers christmas day 2009' do
        interval.should be_cover(Date.new(2009,12,24))
      end

      it 'does not cover 2011-07-02' do
        interval.should_not be_cover(Date.new(2011,07,02))
      end
    end

    describe 'the interval 2008-08-23/open' do
      let(:interval) { Date.edtf('2008-08-23/open') }

			it { interval.should be_open }
			it { interval.should be_open_end }
			it { interval.should_not be_unknown }
			it { interval.should_not be_unknown_start }
			it { interval.should_not be_unknown_end }
			
			it 'the min date is 2008-08-23' do
				interval.min.should == Date.new(2008,8,23)
			end

			it 'the max date is nil' do
				interval.max.should be nil
			end
			
      it 'includes christmas day 2009' do
        interval.should be_include(Date.new(2009,12,24))
      end
      
      it 'covers christmas day 2009' do
        interval.should be_cover(Date.new(2009,12,24))
      end

      it 'covers 2023-07-02' do
        interval.should be_cover(Date.new(2023,07,02))
      end
			
		end    
    
		describe 'comparisions' do
			
			it '2007/2009 should be greater than 2001/2002' do
				Date.edtf('2007/2009').should > Date.edtf('2001/2002')
			end

			it '2007/2009 should be less than 2011/2012' do
				Date.edtf('2007/2009').should < Date.edtf('2011/2012')
			end

			it '2007/2009 should be less than 2008/2009' do
				Date.edtf('2007/2009').should < Date.edtf('2008/2009')
			end

			it '2007/2009 should be greater than 2007/2008' do
				Date.edtf('2007/2009').should > Date.edtf('2007/2008')
			end

			it '2007/2009 should be greater than 2006/2007' do
				Date.edtf('2007/2009').should > Date.edtf('2006/2007')
			end

			it '2007/2009 should be equal to 2007/2009' do
				Date.edtf('2007/2009').should == Date.edtf('2007/2009')
			end


			
		end
  end
end