class EDTF
  describe Century do
    
    let(:instance) { Century.new }

    describe '#new' do
      it { should_not be_nil }
      
      it 'should accept a simple EDTF string' do
        Century.new('19').century.should == 20
        Century.new('00').century.should == 1
      end
      
      it 'should accept a year' do
        Century.new(1901).century.should == 20
      end
      
    end
    
    describe '#year' do
      [1900, 2011, 0, -533].each do |year|
        it "returns the year (year set to #{year})" do
          instance.year = year
          instance.year.should == year
        end
      end
      
      [19, 21, 1, -6].each do |century|
        it "returns the year (century set to #{century})" do
          instance.century = century
          (instance.year / 100).should  == (century - 1)
        end
      end
      
    end

    describe '#century' do
      [19, 21, 1, -6].each do |century|
        it "returns the year (century set to #{century})" do
          instance.century = century
          instance.century.should == century
        end
      end

      [1900, 2011, 0, -533].each do |year|
        it "returns the year (#{year})" do
          instance.year = year
          instance.century.should == (year / 100 + 1)
        end
      end
    end
    
    describe 'arithmetics' do
      it 'adds a 100 years when adding 1' do
        (Century.new(1911) + 1).year.should == 2011
      end
    end

    describe '#iso8601' do
      it 'returns the century as an iso8061 string by default' do
        instance.iso8601.should == '00'
      end

      it 'parses an iso8601 string if argument is given' do
        instance.iso8601('19').century.should == 20
      end
    end
    
  end  
end