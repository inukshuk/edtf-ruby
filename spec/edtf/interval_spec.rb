module EDTF
  describe 'Interval' do
    describe 'when it ends in 2008' do

      let(:interval) { Interval.new(Date.new(2007), Date.new(2008)) }
      
      it 'should include any day in the year 2008' do
        interval.should include(Date.new(2008, 12, 31))
      end
    end
  end
end