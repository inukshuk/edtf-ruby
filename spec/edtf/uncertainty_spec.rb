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
    
  end
  
end