module EDTF
  describe 'Seasons' do
    let(:subject) { Date.new }    
    
    describe '#season?' do
      it 'returns false by default' do
        subject.should_not be_season
      end
      
      context 'when a season code is set' do
        before(:all) { subject.season = 21 }
        it 'returns true if a season code is set' do
          subject.should be_season
        end
      end
    end
    
    describe '#season' do
      before(:each) { subject.season = 21 }
      
      it 'returns the season code' do
        subject.season.should == 21
      end
    end
    
    describe '#season=' do
      it 'sets the season code when called with a valid season code' do
        lambda do
          (21..22).each do |i|
            subject.season = i
          end
        end.should_not raise_error
      end
      
      it 'throws an exception if given invalid season code' do
        lambda { subject.season = 13 }.should raise_error
      end
    end

    describe '#winter!' do
      it 'sets the season code to 24' do
        lambda { subject.winter! }.should change { subject.season }.to(24)
      end
    end

    describe '#winter?' do
      it 'returns true if the season code is 24' do
        subject.season = 24
        subject.should be_winter
      end
      it 'returns false if the season code is not 24' do
        subject.season = 23
        subject.should_not be_winter
      end
    end

    
  end
end
