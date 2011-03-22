class EDTF
  
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
    
  end
  
end