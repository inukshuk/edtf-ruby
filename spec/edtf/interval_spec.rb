module EDTF
  describe 'Interval' do
    
    describe 'the interval 2008/2011' do
      let(:interval) { Date.edtf('2008/2011') }
      
      it 'includes the years 2008, 2009, 2010 and 2011' do
        interval.to_a.map(&:year).should == [2008, 2009, 2010, 2011]
      end
      
      it 'does not include christmas day 2009' do
        interval.should_not include(Date.new(2009,12,24))
      end
      
      it 'covers christmas day 2009' do
        interval.should cover(Date.new(2009,12,24))
      end
    end

    describe 'the interval 2008-08-23/2011-07-01' do
      let(:interval) { Date.edtf('2008-08-23/2011-07-01') }
      
      it 'includes christmas day 2009' do
        interval.should include(Date.new(2009,12,24))
      end
      
      it 'covers christmas day 2009' do
        interval.should cover(Date.new(2009,12,24))
      end
    end
    
    
  end
end