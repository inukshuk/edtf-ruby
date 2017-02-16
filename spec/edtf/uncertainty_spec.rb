module EDTF
  
  describe Uncertainty do

    let(:uncertainty) { Uncertainty.new }
    
    describe '#uncertain?' do
      
      it { is_expected.to be_certain }

      it 'should be uncertain if at least one part is uncertain' do
        expect(Uncertainty.new(false, false, true)).to be_uncertain
      end

      it 'should not be uncertain if all parts are certain' do
        expect(Uncertainty.new(false, false, false)).to be_certain
      end

      it 'should be uncertain if all parts are uncertain' do
        expect(Uncertainty.new(true, true, true)).to be_uncertain
      end

      # [:year, :month, :day, :hour, :minute, :second].each do |part|
      [:year, :month, :day].each do |part|
        it "#{ part } should not be uncertain by default" do
          expect(uncertainty.uncertain?(part)).to be false
        end

        it "#{ part } should be uncertain if set to uncertain" do
          uncertainty.send("#{part}=", true)
          expect(uncertainty.uncertain?(part)).to be true
        end
        
        # ([:year, :month, :day, :hour, :minute, :second] - [part]).each do |other|
        ([:year, :month, :day] - [part]).each do |other|
          it "#{other} should not be uncertain if #{part} is uncertain" do
            uncertainty.send("#{part}=", true)
            expect(uncertainty.uncertain?(other)).to be false
          end
        end

      end

      describe '#hash' do
        
        describe 'with the default hash base (1)' do

          it 'returns 0 by default' do
            expect(Uncertainty.new.hash).to eq(0)
          end
          
          it 'returns 1 for uncertain year' do
            expect(Uncertainty.new.hash).to eq(0)
          end

          it 'returns 2 for uncertain month' do
            expect(Uncertainty.new.hash).to eq(0)
          end

          it 'returns 4 for uncertain day' do
            expect(Uncertainty.new.hash).to eq(0)
          end

          it 'returns 3 for uncertain year, month' do
            expect(Uncertainty.new(true, true).hash).to eq(3)
          end

          it 'returns 7 for uncertain year, month, day' do
            expect(Uncertainty.new(true, true, true).hash).to eq(7)
          end

          it 'returns 5 for uncertain year, day' do
            expect(Uncertainty.new(true, nil, true).hash).to eq(5)
          end

          it 'returns 6 for uncertain month, day' do
            expect(Uncertainty.new(nil, true, true).hash).to eq(6)
          end
          
        end
        
      end
      
    end
    
    describe '#uncertain!' do
      it 'should make all parts certain when no part given' do
        expect { uncertainty.uncertain! }.to change { uncertainty.certain? }
      end
    end
    
  end
  
  describe Unspecified do
    let(:u) { Unspecified.new }
    
    
    describe '#unspecified?' do
      it 'should return false by default' do
        expect(u).not_to be_unspecified
      end
      
      it 'should return true if the day is unspecified' do
        expect(u.unspecified!(:day)).to be_unspecified
      end

      it 'should return true if the month is unspecified' do
        expect(u.unspecified!(:month)).to be_unspecified
      end

      it 'should return true if the year is unspecified' do
        expect(u.unspecified!(:year)).to be_unspecified
      end
    end
    
    describe '#year' do
      it 'returns the year values' do
        expect(u.year).to eq([nil,nil,nil,nil])
      end
      
      it 'allows you to set individual offsets' do
        u.year[1] = true
        expect(u.to_s).to eq('suss-ss-ss')
      end
    end
    
    describe '#to_s' do
      it 'should be return "ssss-ss-ss" by default' do
        expect(u.to_s).to eq('ssss-ss-ss')
      end
      
      it 'should return "ssss-ss-uu" if the day is unspecified' do
        expect(u.unspecified!(:day).to_s).to eq('ssss-ss-uu')
      end

      it 'should return "ssss-uu-ss" if the month is unspecified' do
        expect(u.unspecified!(:month).to_s).to eq('ssss-uu-ss')
      end

      it 'should return "ssss-uu-uu" if month and day are unspecified' do
        expect(u.unspecified!([:day, :month]).to_s).to eq('ssss-uu-uu')
      end

      it 'should return "uuuu-ss-ss" if the year is unspecified' do
        expect(u.unspecified!(:year).to_s).to eq('uuuu-ss-ss')
      end

      it 'should return "uuuu-uu-uu" if the date is unspecified' do
        expect(u.unspecified!.to_s).to eq('uuuu-uu-uu')
      end
      
    end

		describe '#mask' do
			
			context 'when passed an empty array' do
				it 'should return an empty array' do
					expect(u.mask([])).to eq([])
				end
			end
			
			context 'when passed an array with a year string' do
				let(:date) { ['1994'] }
				
				it 'should return the array with the year by default' do
					expect(u.mask(date)).to eq(['1994'])
				end
				
				context 'when the year is unspecified' do
					before(:each) { u.year[3] = true }
					
					it 'should return the array with the year and the fourth digit masked' do
						expect(u.mask(date)).to eq(['199u'])
					end
					
				end

				context 'when the decade is unspecified' do
					before(:each) { u.year[2,2] = [true,true] }
					
					it 'should return the array with the year and the third and fourth digit masked' do
						expect(u.mask(date)).to eq(['19uu'])
					end
					
				end
				
			end
			
      context 'when passed an array with a negative year string' do
        let(:date) { ['-1994'] }
          
        it 'should return the array with the year by default' do
          expect(u.mask(date)).to eq(['-1994'])
        end

        context 'when the year is unspecified' do
          before(:each) { u.year[3] = true }
          
          it 'should return the array with the year and the fourth digit masked' do
            expect(u.mask(date)).to eq(['-199u'])
          end      
        end

        context 'when the decade is unspecified' do
          before(:each) { u.year[2,2] = [true,true] }
          
          it 'should return the array with the year and the third and fourth digit masked' do
            expect(u.mask(date)).to eq(['-19uu'])
          end
          
        end
      end

			context 'when passed an array with a year-month string' do
				let(:date) { ['1994', '01'] }
				
				it 'should return the array with the year by default' do
					expect(u.mask(date)).to eq(['1994', '01'])
				end

				context 'when the year is unspecified' do
					before(:each) { u.year[3] = true }
					
					it 'should return the array with the year and the fourth digit masked' do
						expect(u.mask(date)).to eq(['199u', '01'])
					end
					
					context 'when the month is unspecified' do
						before(:each) { u.unspecified! :month }

						it 'should return the array with the month masked' do
							expect(u.mask(date)).to eq(['199u', 'uu'])
						end		
					end
				end

				context 'when the decade is unspecified' do
					before(:each) { u.year[2,2] = [true,true] }
					
					it 'should return the array with the year and the third and fourth digit masked' do
						expect(u.mask(date)).to eq(['19uu', '01'])
					end
					
					context 'when the month is unspecified' do
						before(:each) { u.unspecified! :month }

						it 'should return the array with the month masked' do
							expect(u.mask(date)).to eq(['19uu', 'uu'])
						end		
					end			
				end

				context 'when the month is unspecified' do
					before(:each) { u.unspecified! :month }
					
					it 'should return the array with the month masked' do
						expect(u.mask(date)).to eq(['1994', 'uu'])
					end		
				end				

			end
			
			context 'when passed an array with a year-month-day string' do
				let(:date) { ['1994', '01', '27'] }
				
				it 'should return the array with the date by default' do
					expect(u.mask(date)).to eq(['1994', '01', '27'])
				end
			
				context 'when the year is unspecified' do
					before(:each) { u.year[3] = true }
					
					it 'should return the array with the year and the fourth digit masked' do
						expect(u.mask(date)).to eq(['199u', '01', '27'])
					end
					
					context 'when the month is unspecified' do
						before(:each) { u.unspecified! :month }

						it 'should return the array with the month masked' do
							expect(u.mask(date)).to eq(['199u', 'uu', '27'])
						end		
						
						context 'when the day is unspecified' do
							before(:each) { u.unspecified! :day }

							it 'should return the array with the month masked' do
								expect(u.mask(date)).to eq(['199u', 'uu', 'uu'])
							end		
						end
					end
				end
			
			
			end
			
			
		end
    
  end
  
end