describe DateTime do

  let(:date) { DateTime.new }

  describe 'class methods' do
    it 'responds to edtf' do
      DateTime.respond_to?(:edtf).should == true
    end
  end
  
  describe 'instance methods' do
    [:uncertain?, :approximate?, :unspecified?, :uncertain, :approximate, :unspecified].each do |method|
      it "responds to #{method}" do
        DateTime.new.respond_to?(method).should == true
      end
    end
  end
  
  describe '#uncertain?' do
    
    it { should_not be_uncertain }

    [:year, :month, :day].each do |part|
      it "should not be uncertain by default (#{part})" do
        DateTime.new.uncertain?(part).should == false
      end

      it "should be uncertain if set to uncertain (#{part})" do
        date.uncertain.send("#{part}=", true)
        date.uncertain?(part).should == true
      end

      ([:year, :month, :day] - [part]).each do |other|
        it "#{other} should not be uncertain if #{part} is uncertain" do
          date.uncertain.send("#{part}=", true)
          date.uncertain?(other).should == false
        end
      end
      
    end
    
  end
    
end