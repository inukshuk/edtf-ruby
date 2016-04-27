module EDTF
  describe 'Seasons' do
    let(:subject) { Season.new }
    let(:summer) { Season.new(:summer) }
    let(:winter) { Season.new(:winter) }


    describe 'uncertain/approximate' do

      it 'is certain by default' do
        expect(subject).to be_certain
        expect(subject).not_to be_uncertain
      end

      it 'is precise by default' do
        expect(subject).to be_precise
        expect(subject).not_to be_approximate
      end

      describe '#approximate!' do
        it 'makes the season approximate' do
          expect(subject.approximate!).to be_approximate
          expect(subject.approximate!).not_to be_precise
        end
      end

      describe '#uncertain!' do
        it 'makes the season uncertain' do
          expect(subject.uncertain!).to be_uncertain
          expect(subject.uncertain!).not_to be_certain
        end
      end

    end

    describe '#succ' do

      it 'returns a season' do
        expect(summer.succ).to be_instance_of(Season)
      end

      it 'it returns a season that is greater than the original one' do
        expect(summer.succ).to be > summer
      end

      it 'the successor of the winter season is spring of the following year' do
        spring = winter.succ
        expect(spring).to be_spring
        expect(spring.year).to eq(winter.year + 1)
      end

    end

    describe '#season?' do
      it 'returns true by default' do
        expect(subject).to be_season
      end
    end

    describe '#season' do
      before(:each) { subject.season = :summer }

      it 'returns the season code' do
        expect(subject.season).to eq(:summer)
      end
    end

    describe '#season=' do
      it 'sets the season code when called with a valid season code' do
        expect {
          (21..22).each do |i|
            subject.season = i
          end
        }.not_to raise_error
      end

      it 'throws an exception if given invalid season code' do
        expect { subject.season = 13 }.to raise_error(NoMethodError)
      end
    end

    describe '#summer!' do
      it 'sets the season to :summer' do
        subject.season = :spring
        expect { subject.summer! }.to change { subject.season }.to(:summer)
      end
    end

    describe '#winter?' do
      it 'returns true if the season is set to :winter' do
        subject.season = :winter
        expect(subject).to be_winter
      end
      it 'returns false if the season is not set to :winter' do
        subject.season = :summer
        expect(subject).not_to be_winter
      end
    end

    describe '#include?' do

      context 'for summer' do
        it 'returns true for August 24' do
          expect(Season.new(1980, :summer)).to include(Date.new(1980,8,24))
        end
      end

    end

  end
end
