module EDTF
  describe 'Sets' do
	
		describe 'constructor' do
			
			it 'creates a new empty set by default' do
				Set.new.should be_empty
			end
			
		end
	
		describe '#edtf' do
			
			it 'returns {} by default' do
				Set.new.edtf.should == '{}'
			end

			it 'returns [] for empty choice lists' do
				Set.new.choice!.edtf.should == '[]'
			end
			
			it 'returns {1984} if the set contains the year 1984' do
				Set.new(Date.edtf('1984')).edtf.should == '{1984}'
			end
			
			it 'returns {1984, 1985-10} for the set containing these dates' do
				Set.new(Date.edtf('1984'), Date.new(1984,10).month_precision).edtf.should == '{1984, 1984-10}'
			end

			it 'returns {..1984, 1985-10} for the set containing these dates and earlier == true' do
				Set.new(Date.edtf('1984'), Date.new(1984,10).month_precision).earlier!.edtf.should == '{..1984, 1984-10}'
			end

			it 'returns {1984, 1985-10..} for the set containing these dates and later == true' do
				Set.new(Date.edtf('1984'), Date.new(1984,10).month_precision).later!.edtf.should == '{1984, 1984-10..}'
			end

			it 'returns [1667, 1668, 1670..1672] for the years 1667, 1668 and the interval 1670..1672' do
				s = Set.new.choice!
				s << Date.edtf('1667') << Date.edtf('1668')
				s << (Date.edtf('1670') .. Date.edtf('1672'))
				s.edtf.should == '[1667, 1668, 1670..1672]'
			end
			
		end
		
		describe 'the set [1667, 1668, 1670..1672]' do
			let(:set) { Set.new(Date.edtf('1667'), Date.edtf('1668'), Date.edtf('1670')..Date.edtf('1672')).choice! }
		
			it 'includes the year 1671' do
				set.should include(Date.new(1671).year_precision!)
			end

			it 'does not include the date 1671-01-01' do
				set.should_not include(Date.new(1671))
			end

			it 'does not include the year 1669' do
				set.should_not include(Date.new(1669).year_precision!)
			end
			
			it 'has a length of 3' do
				set.should have(3).elements
			end
			
			it 'maps to the year array [1667, 1668, 1670, 1671, 1672]' do
				set.map(&:year).should == [1667, 1668, 1670, 1671, 1672]
			end
		
		end
		
	end
end