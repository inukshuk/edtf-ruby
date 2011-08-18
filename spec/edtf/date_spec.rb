describe 'Date/DateTime' do

  describe 'class methods' do
    it 'responds to edtf' do
      Date.should respond_to(:edtf)
    end
  end
  
  describe 'instance methods' do
    [:uncertain?, :approximate?, :unspecified?, :uncertain, :approximate, :unspecified].each do |method|
      it "responds to #{method}" do
        Date.new.respond_to?(method).should == true
      end
    end
  end
  
  describe '#dup' do
    let(:date) { Date.edtf('2004-09?~') }
    
    it 'copies all date values' do
      date.dup.to_s == '2004-09-01'
    end
    
    it 'copies uncertainty' do
      date.dup.should be_uncertain
    end

    it 'copies approximate' do
      date.dup.should be_approximate
    end

    it 'copies precision' do
      date.dup.precision.should == :month
    end 
  end
  
  describe '#uncertain?' do
    
    let(:date) { Date.new }
    
    it { Date.new.should_not be_uncertain }

    [:year, :month, :day].each do |part|
      it "should not be uncertain by default (#{part})" do
        Date.new.uncertain?(part).should == false
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