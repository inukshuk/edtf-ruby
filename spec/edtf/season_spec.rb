module EDTF
  describe 'Seasons' do
    let(:subject) { Season.new }
		let(:summer) { Season.new(:summer) }
		let(:winter) { Season.new(:winter) }
    

		describe 'uncertain/approximate' do
			
			it 'is certain by default' do
				subject.should be_certain
				subject.should_not be_uncertain
			end

			it 'is precise by default' do
				subject.should be_precise
				subject.should_not be_approximate
			end
			
			describe '#approximate!' do
				it 'makes the season approximate' do
					subject.approximate!.should be_approximate
					subject.approximate!.should_not be_precise
				end
			end

			describe '#uncertain!' do
				it 'makes the season uncertain' do
					subject.uncertain!.should be_uncertain
					subject.uncertain!.should_not be_certain
				end
			end
			
		end
		
		describe '#succ' do
			
			it 'returns a season' do
				summer.succ.should be_instance_of(Season)
			end	
			
			it 'it returns a season that is greater than the original one' do
				summer.succ.should > summer
			end
			
			it 'the successor of the winter season is spring of the following year' do
				spring = winter.succ
				spring.should be_spring
				spring.year.should == winter.year + 1
			end
			
		end
		
    describe '#season?' do
      it 'returns true by default' do
        subject.should be_season
      end
    end

    describe '#season' do
      before(:each) { subject.season = :summer }
      
      it 'returns the season code' do
        subject.season.should == :summer
      end
    end
    
    describe '#season=' do
      it 'sets the season code when called with a valid season code' do
        lambda {
          (21..22).each do |i|
            subject.season = i
          end
        }.should_not raise_error
      end
      
      it 'throws an exception if given invalid season code' do
        lambda { subject.season = 13 }.should raise_error
      end
    end

    describe '#winter!' do
      it 'sets the season to :winter' do
        lambda { subject.winter! }.should change { subject.season }.to(:winter)
      end
    end

    describe '#winter?' do
      it 'returns true if the season is set to :winter' do
        subject.season = :winter
        subject.should be_winter
      end
      it 'returns false if the season is not set to :winter' do
        subject.season = :summer
        subject.should_not be_winter
      end
    end

    describe '#include?' do
      
      context 'for summer' do
        it 'returns true for August 24' do
          Season.new(1980, :summer).should include(Date.new(1980,8,24))
        end
      end
      
    end
    
  end
end
