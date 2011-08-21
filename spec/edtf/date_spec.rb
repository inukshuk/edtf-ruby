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
    
    it 'copies uncertainty by value' do
      lambda { date.dup.certain! }.should_not change { date.uncertain? }
    end
    
  end
  
	describe '#negate' do
    let(:date) { Date.edtf('2004?') }
		
		it 'should return a new date with the negated year' do
			date.negate.year.should == (date.year * -1)
		end
		
		it 'should return a new date with the same month and day' do
			date.negate.month.should == date.month
			date.negate.day.should == date.day
		end
		
		it 'should return a new date with the same precision' do
			date.negate.precision.should == date.precision
		end
	end
	
  describe '#change' do
    let(:date) { Date.edtf('2004-09?~') }

    it 'returns a copy of the date if given empty option hash' do
      date.change({}).should == date
      date.change({}).should_not equal(date)
    end
    
    describe 'when given a new year' do
      let(:changeset) { { :year => 1999 } }
      
      it 'returns a new date instance with the changed year' do
        date.change(changeset).year.should == 1999
      end
      
    end

    describe 'when given a new precision' do
      let(:changeset) { { :precision => :year } }
      
      it 'returns a new date instance with the changed precision' do
        date.change(changeset).precision.should == :year
      end

    end

    it 'copies extended values by value' do
      lambda { date.change({}).approximate! }.should_not change { date.approximate? }
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