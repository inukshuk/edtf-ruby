module EDTF
  describe 'Sets' do

    describe 'constructor' do

      it 'creates a new empty set by default' do
        expect(Set.new).to be_empty
      end

    end

    describe '#edtf' do

      it 'returns {} by default' do
        expect(Set.new.edtf).to eq('{}')
      end

      it 'returns [] for empty choice lists' do
        expect(Set.new.choice!.edtf).to eq('[]')
      end

      it 'returns {1984} if the set contains the year 1984' do
        expect(Set.new(Date.edtf('1984')).edtf).to eq('{1984}')
      end

      it 'returns {1984, 1985-10} for the set containing these dates' do
        expect(Set.new(Date.edtf('1984'), Date.new(1984,10).month_precision).edtf).to eq('{1984,1984-10}')
      end

      it 'returns {..1984, 1985-10} for the set containing these dates and earlier == true' do
        expect(Set.new(Date.edtf('1984'), Date.new(1984,10).month_precision).earlier!.edtf).to eq('{..1984,1984-10}')
      end

      it 'returns {1984, 1985-10..} for the set containing these dates and later == true' do
        expect(Set.new(Date.edtf('1984'), Date.new(1984,10).month_precision).later!.edtf).to eq('{1984,1984-10..}')
      end

      it 'returns [1667, 1668, 1670..1672] for the years 1667, 1668 and the interval 1670..1672' do
        s = Set.new.choice!
        s << Date.edtf('1667') << Date.edtf('1668')
        s << (Date.edtf('1670') .. Date.edtf('1672'))
        expect(s.edtf).to eq('[1667,1668,1670..1672]')
      end

    end

    describe 'the set [1667, 1668, 1670..1672]' do
      let(:set) { Set.new(Date.edtf('1667'), Date.edtf('1668'), Date.edtf('1670')..Date.edtf('1672')).choice! }

      it 'includes the year 1671' do
        expect(set).to include(Date.new(1671).year_precision!)
      end

      it 'does not include the date 1671-01-01' do
        expect(set.include?(Date.new(1671))).to be false
      end

      it 'does not include the year 1669' do
        expect(set.include?(Date.new(1669).year_precision!)).to be false
      end

      it 'has a length of 3' do
        expect(set.size).to eq(3)
      end

      it 'maps to the year array [1667,1668,1670,1671,1672]' do
        expect(set.map(&:year)).to eq([1667, 1668, 1670, 1671, 1672])
      end
    end

    describe 'the set [1984,1985-10-01..]' do
      let(:s1) { Set.new(Date.edtf('1984'), Date.edtf('1985-10-01')).later! }
      let(:s2) { Date.edtf('[1984,1985-10-01..]') }

      it 'has varying precision' do
        expect(s1.map(&:precision)).to eq([:year, :day])
        expect(s2.map(&:precision)).to eq([:year, :day])
      end
    end

  end
end
