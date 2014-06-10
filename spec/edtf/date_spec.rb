describe 'Date/DateTime' do

  describe 'class methods' do
    it 'responds to edtf' do
      expect(Date).to respond_to(:edtf)
    end
  end
  
  describe 'instance methods' do
    [:uncertain?, :approximate?, :unspecified?, :uncertain, :approximate, :unspecified].each do |method|
      it "responds to #{method}" do
        expect(Date.new.respond_to?(method)).to eq(true)
      end
    end
  end
  
  describe '#dup' do
    let(:date) { Date.edtf('2004-09?~') }
    
    it 'copies all date values' do
      date.dup.to_s == '2004-09-01'
    end
    
    it 'copies uncertainty' do
      expect(date.dup).to be_uncertain
    end

    it 'copies approximate' do
      expect(date.dup).to be_approximate
    end

    it 'copies precision' do
      expect(date.dup.precision).to eq(:month)
    end
    
    it 'copies uncertainty by value' do
      expect { date.dup.certain! }.not_to change { date.uncertain? }
    end
    
  end

	describe 'precisions' do
		let(:date) { Date.today }
		
		it 'has day precision by default' do
			expect(date).to be_day_precision
		end
		
		it '#day_precison returns a new date object' do
			expect(date.day_precision).not_to equal(date)
			expect(date.day_precision).to eq(date)
		end
		
	end
	
  
	describe '#negate' do
    let(:date) { Date.edtf('2004?') }
		
		it 'returns a new date with the negated year' do
			expect(date.negate.year).to eq(date.year * -1)
		end
		
		it 'returns a new date with the same month' do
			expect(date.negate.month).to eq(date.month)
		end
		
		it 'returns a new date with the same day' do
			expect(date.negate.day).to eq(date.day)
		end
		
		it 'returns a new date with the same precision' do
			expect(date.negate.precision).to eq(date.precision)
		end
	end
	
	describe '#succ' do
		
		it 'the successor of 2004 is 2005' do
			expect(Date.edtf('2004').succ.year).to eq(2005)
		end

		it 'the successor of 2004-03 is 2004-04' do
			expect(Date.edtf('2004-03').succ.strftime('%Y-%m')).to eq('2004-04')
		end

		it 'the successor of 2004-03-01 is 2004-03-02' do
			expect(Date.edtf('2004-03-01').succ.strftime('%Y-%m-%d')).to eq('2004-03-02')
		end

		it "the successor of 1999 has year precision" do
			expect(Date.edtf('1999').succ).to be_year_precision
		end

	end
	
	describe '#next' do
	  
	  it 'returns the successor when given no argument' do
			expect(Date.edtf('1999').next[0].year).to eq(2000)
	  end
	  
	  it 'returns an array of the next 3 elements when passed 3 as an argument' do
	    Date.edtf('1999').next(3).map(&:year) == [2000, 2001, 2002]
	  end
	  
	end
	
	
  describe '#change' do
    let(:date) { Date.edtf('2004-09?~') }

    it 'returns a copy of the date if given empty option hash' do
      expect(date.change({})).to eq(date)
		end
		
    it 'the returned copy is not identical at object level' do
      expect(date.change({})).not_to equal(date)
    end
    
    describe 'when given a new year' do
      let(:changeset) { { :year => 1999 } }
      
      it 'returns a new date instance with the changed year' do
        expect(date.change(changeset).year).to eq(1999)
      end
      
    end

    describe 'when given a new precision' do
      let(:changeset) { { :precision => :year } }
      
      it 'returns a new date instance with the changed precision' do
        expect(date.change(changeset).precision).to eq(:year)
      end

    end

    it 'copies extended values by value' do
      expect { date.change({}).approximate! }.not_to change { date.approximate? }
    end
    
  end
  
  describe '#uncertain?' do
    
    let(:date) { Date.new }
    
    it { expect(Date.new).not_to be_uncertain }

    [:year, :month, :day].each do |part|
      it "should not be uncertain by default (#{part})" do
        expect(Date.new.uncertain?(part)).to eq(false)
      end

      it "should be uncertain if set to uncertain (#{part})" do
        date.uncertain.send("#{part}=", true)
        expect(date.uncertain?(part)).to eq(true)
      end

      ([:year, :month, :day] - [part]).each do |other|
        it "#{other} should not be uncertain if #{part} is uncertain" do
          date.uncertain.send("#{part}=", true)
          expect(date.uncertain?(other)).to eq(false)
        end
      end
      
    end
    
  end
  
  describe 'uncertain/approximate hash' do
    
    it 'is 0 by default' do
      expect(Date.new().send(:ua_hash)).to eq(0)
    end
    
    it 'is 8 for approximate year' do
      expect(Date.new.approximate!(:year).send(:ua_hash)).to eq(8)
    end
    
  end
  
	describe 'sorting and comparisons' do
		let(:xmas) { Date.new(2011, 12, 24) }
		let(:new_years_eve) { Date.new(2011, 12, 31) }
		
		describe '#values' do
			
			it 'returns [2011,12,24] for christmas' do
				expect(xmas.values).to eq([2011,12,24])
			end

			it 'returns [2011,12] for christmas with month precision' do
				expect(xmas.month_precision!.values).to eq([2011,12])
			end

			it 'returns [2011] for christmas with year precision' do
				expect(xmas.year_precision!.values).to eq([2011])
			end
			
		end
		
		describe '#<=>' do
			
			it '2009-12-24 should be less than 2011-12-31' do
				expect(Date.new(2009,12,24)).to be < Date.new(2011,12,31)
			end

			it '2009-12-24 should be less than 2011-12' do
				expect(Date.new(2009,12,24)).to be < Date.edtf('2011-12')
			end

			it '2009-12-24 should be less than 2011' do
				expect(Date.new(2009,12,24)).to be < Date.edtf('2011')
			end
			
			
		end
		
		describe '#==' do
			
			it "xmas and new year's eve are not equal" do
				expect(xmas).not_to eq(new_years_eve)
			end

			it "xmas and new year's eve are equal using month percision" do
				expect(xmas.month_precision!).to eq(new_years_eve.month_precision!)
			end

			it "xmas and january 24 are not equal using month percision" do
				expect(xmas.month_precision!).not_to eq(xmas.month_precision!.next)
			end
			

			it "xmas and new year's eve are equal using year percision" do
				expect(xmas.year_precision!).to eq(new_years_eve.year_precision!)
			end
			
		end
		
	end
	
    
end