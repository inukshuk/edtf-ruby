class EDTF
  describe Duration do
    
    describe '#new' do
      it { should_not be_nil }
      
      it 'accepts individual integers' do
        Duration.new(1, 2, 3, 4, 5, 6, 7).to_s.should == 'P1Y2M3W4DT5H6M7S'
      end

      it 'accepts individual strings' do
        Duration.new('1', '2', '3', '4', '5', '6', '7').to_s.should == 'P1Y2M3W4DT5H6M7S'
      end

      it 'accepts full pattern' do
        Duration.new('P1Y2M3W4DT5H6M7S').to_s.should == 'P1Y2M3W4DT5H6M7S'
      end

      %w[ P1Y P1M P1W P1D PT1H PT1M PT1S ].each do |pattern|
        it "accepts partial patterns (#{pattern})" do
          Duration.new(pattern).to_s.should == pattern
        end
      end
      
    end
    
  end
end