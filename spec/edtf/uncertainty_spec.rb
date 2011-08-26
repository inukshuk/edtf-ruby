module EDTF
  
  describe Uncertainty do

    let(:uncertainty) { Uncertainty.new }
    
    describe '#uncertain?' do
      
      it { should be_certain }

      it 'should be uncertain if at least one part is uncertain' do
        Uncertainty.new(false, false, true).should be_uncertain
      end

      it 'should not be uncertain if all parts are certain' do
        Uncertainty.new(false, false, false, false, false, false).should be_certain
      end

      it 'should be uncertain if all parts are uncertain' do
        Uncertainty.new(true, true, true, true, true, true).should be_uncertain
      end

      [:year, :month, :day, :hour, :minute, :second].each do |part|
        it "#{ part } should not be uncertain by default" do
          uncertainty.uncertain?(part).should be false
        end

        it "#{ part } should be uncertain if set to uncertain" do
          uncertainty.send("#{part}=", true)
          uncertainty.uncertain?(part).should be true
        end
        
        ([:year, :month, :day, :hour, :minute, :second] - [part]).each do |other|
          it "#{other} should not be uncertain if #{part} is uncertain" do
            uncertainty.send("#{part}=", true)
            uncertainty.uncertain?(other).should be false
          end
        end
        
      end
      
    end
    
    describe '#uncertain!' do
      it 'should make all parts certain when no part given' do
        lambda { uncertainty.uncertain! }.should change { uncertainty.certain? }
      end
    end
    
  end
  
  describe Unspecified do
    let(:u) { Unspecified.new }
    
    
    describe '#unspecified?' do
      it 'should return false by default' do
        u.should_not be_unspecified
      end
      
      it 'should return true if the day is unspecified' do
        u.unspecified!(:day).should be_unspecified
      end

      it 'should return true if the month is unspecified' do
        u.unspecified!(:month).should be_unspecified
      end

      it 'should return true if the year is unspecified' do
        u.unspecified!(:year).should be_unspecified
      end
    end
    
    describe '#year' do
      it 'returns the year values' do
        u.year.should == [nil,nil,nil,nil]
      end
      
      it 'allows you to set individual offsets' do
        u.year[1] = true
        u.to_s.should == 'suss-ss-ss'
      end
    end
    
    describe '#to_s' do
      it 'should be return "ssss-ss-ss" by default' do
        u.to_s.should == 'ssss-ss-ss'
      end
      
      it 'should return "ssss-ss-uu" if the day is unspecified' do
        u.unspecified!(:day).to_s.should == 'ssss-ss-uu'
      end

      it 'should return "ssss-uu-ss" if the month is unspecified' do
        u.unspecified!(:month).to_s.should == 'ssss-uu-ss'
      end

      it 'should return "ssss-uu-uu" if month and day are unspecified' do
        u.unspecified!([:day, :month]).to_s.should == 'ssss-uu-uu'
      end

      it 'should return "uuuu-ss-ss" if the year is unspecified' do
        u.unspecified!(:year).to_s.should == 'uuuu-ss-ss'
      end

      it 'should return "uuuu-uu-uu" if the date is unspecified' do
        u.unspecified!.to_s.should == 'uuuu-uu-uu'
      end
      
    end

		describe '#mask' do
			
			context 'when passed an empty array' do
				it 'should return an empty array' do
					u.mask([]).should == []
				end
			end
			
			context 'when passed an array with a year string' do
				let(:date) { ['1994'] }
				
				it 'should return the array with the year by default' do
					u.mask(date).should == ['1994']
				end
				
				context 'when the year is unspecified' do
					before(:each) { u.year[3] = true }
					
					it 'should return the array with the year and the fourth digit masked' do
						u.mask(date).should == ['199u']
					end
					
				end

				context 'when the decade is unspecified' do
					before(:each) { u.year[2,2] = [true,true] }
					
					it 'should return the array with the year and the third and fourth digit masked' do
						u.mask(date).should == ['19uu']
					end
					
				end
				
			end
			
			context 'when passed an array with a year-month string' do
				let(:date) { ['1994', '01'] }
				
				it 'should return the array with the year by default' do
					u.mask(date).should == ['1994', '01']
				end

				context 'when the year is unspecified' do
					before(:each) { u.year[3] = true }
					
					it 'should return the array with the year and the fourth digit masked' do
						u.mask(date).should == ['199u', '01']
					end
					
					context 'when the month is unspecified' do
						before(:each) { u.unspecified! :month }

						it 'should return the array with the month masked' do
							u.mask(date).should == ['199u', 'uu']
						end		
					end
				end

				context 'when the decade is unspecified' do
					before(:each) { u.year[2,2] = [true,true] }
					
					it 'should return the array with the year and the third and fourth digit masked' do
						u.mask(date).should == ['19uu', '01']
					end
					
					context 'when the month is unspecified' do
						before(:each) { u.unspecified! :month }

						it 'should return the array with the month masked' do
							u.mask(date).should == ['19uu', 'uu']
						end		
					end			
				end

				context 'when the month is unspecified' do
					before(:each) { u.unspecified! :month }
					
					it 'should return the array with the month masked' do
						u.mask(date).should == ['1994', 'uu']
					end		
				end				

			end
			
			context 'when passed an array with a year-month-day string' do
				let(:date) { ['1994', '01', '27'] }
				
				it 'should return the array with the date by default' do
					u.mask(date).should == ['1994', '01', '27']
				end
			
				context 'when the year is unspecified' do
					before(:each) { u.year[3] = true }
					
					it 'should return the array with the year and the fourth digit masked' do
						u.mask(date).should == ['199u', '01', '27']
					end
					
					context 'when the month is unspecified' do
						before(:each) { u.unspecified! :month }

						it 'should return the array with the month masked' do
							u.mask(date).should == ['199u', 'uu', '27']
						end		
						
						context 'when the day is unspecified' do
							before(:each) { u.unspecified! :day }

							it 'should return the array with the month masked' do
								u.mask(date).should == ['199u', 'uu', 'uu']
							end		
						end
					end
				end
			
			
			end
			
			
		end
    
  end
  
end