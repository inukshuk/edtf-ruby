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

	describe 'precisions' do
		let(:date) { Date.today }
		
		it 'has day precision by default' do
			date.should be_day_precision
		end
		
		it '#day_precison returns a new date object' do
			date.day_precision.should_not equal(date)
			date.day_precision.should == date
		end
		
	end
	
  
	describe '#negate' do
    let(:date) { Date.edtf('2004?') }
		
		it 'returns a new date with the negated year' do
			date.negate.year.should == (date.year * -1)
		end
		
		it 'returns a new date with the same month' do
			date.negate.month.should == date.month
		end
		
		it 'returns a new date with the same day' do
			date.negate.day.should == date.day
		end
		
		it 'returns a new date with the same precision' do
			date.negate.precision.should == date.precision
		end
	end
	
	describe '#succ' do
		
		it 'the successor of 2004 is 2005' do
			Date.edtf('2004').succ.year.should == 2005
		end

		it 'the successor of 2004-03 is 2004-04' do
			Date.edtf('2004-03').succ.strftime('%Y-%m').should == '2004-04'
		end

		it 'the successor of 2004-03-01 is 2004-03-02' do
			Date.edtf('2004-03-01').succ.strftime('%Y-%m-%d').should == '2004-03-02'
		end

		it "the successor of 1999 has year precision" do
			Date.edtf('1999').succ.should be_year_precision
		end

	end
	
	describe '#next' do
	  
	  it 'returns the successor when given no argument' do
			Date.edtf('1999').next.year.should == 2000
	  end
	  
	  it 'returns an array of the next 3 elements when passed 3 as an argument' do
	    Date.edtf('1999').next(3).map(&:year) == [2000, 2001, 2002]
	  end
	  
	end
	
	
  describe '#change' do
    let(:date) { Date.edtf('2004-09?~') }

    it 'returns a copy of the date if given empty option hash' do
      date.change({}).should == date
		end
		
    it 'the returned copy is not identical at object level' do
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
  
  describe 'uncertain/approximate hash' do
    
    it 'is 0 by default' do
      Date.new().send(:ua_hash).should == 0
    end
    
    it 'is 8 for approximate year' do
      Date.new.approximate!(:year).send(:ua_hash).should == 8
    end
    
  end
  
	describe 'sorting and comparisons' do
		let(:xmas) { Date.new(2011, 12, 24) }
		let(:new_years_eve) { Date.new(2011, 12, 31) }
		
		describe '#values' do
			
			it 'returns [2011,12,24] for christmas' do
				xmas.values.should == [2011,12,24]
			end

			it 'returns [2011,12] for christmas with month precision' do
				xmas.month_precision!.values.should == [2011,12]
			end

			it 'returns [2011] for christmas with year precision' do
				xmas.year_precision!.values.should == [2011]
			end
			
		end
		
		describe '#<=>' do
			
			it '2009-12-24 should be less than 2011-12-31' do
				Date.new(2009,12,24).should < Date.new(2011,12,31)
			end

			it '2009-12-24 should be less than 2011-12' do
				Date.new(2009,12,24).should < Date.edtf('2011-12')
			end

			it '2009-12-24 should be less than 2011' do
				Date.new(2009,12,24).should < Date.edtf('2011')
			end
			
			
		end
		
		describe '#==' do
			
			it "xmas and new year's eve are not equal" do
				xmas.should_not == new_years_eve
			end

			it "xmas and new year's eve are equal using month percision" do
				xmas.month_precision!.should == new_years_eve.month_precision!
			end

			it "xmas and january 24 are not equal using month percision" do
				xmas.month_precision!.should_not == xmas.month_precision!.next
			end
			

			it "xmas and new year's eve are equal using year percision" do
				xmas.year_precision!.should == new_years_eve.year_precision!
			end
			
		end
		
	end
	
    
end