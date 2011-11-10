require 'spec_helper'

module EDTF
	
	describe Decade do
		
		it { should_not be nil }

		describe '.current' do
			it 'creates the current decade' do
				Decade.current.year.should == (Time.now.year / 10) * 10
			end
		end
		
		describe '#min' do
			it 'the year 1990 should be the minimum of the 1990s' do
				Decade.new(1999).min.should == Date.new(1990).year_precision!
			end
		end

		describe '#max' do
			it 'the year 1999 should be the maximum of the 1990s' do
				Decade.new(1999).max.should == Date.new(1999).year_precision!
			end
			
			it 'has year precision' do
				Decade.new(1999).max.should be_year_precision
			end
		end

		describe '#cover?' do
			it '1989-12-31 should be covered by the 1980s' do
				Decade.new(1980).should be_cover(Date.new(1989,12,31))
			end
		end
		
		describe '#to_range' do
			
			it 'returns a range' do
				Decade.new.to_range.should be_instance_of(::Range)
			end
			
			it 'the range starts with a date object' do
				Decade.new.to_range.begin.should be_instance_of(::Date)
			end

			it 'the range ends with a date object' do
				Decade.new.to_range.end.should be_instance_of(::Date)
			end

			it 'the range start has year precision' do
				Decade.new.to_range.begin.should be_year_precision
			end

			it 'the range end has year precision' do
				Decade.new.to_range.end.should be_year_precision
			end
			
		end
		
		describe 'enumeration' do
			
			it 'always covers ten years' do
				Decade.new.to_a.should have(10).elements
			end
			
			it 'the 1970s should map to the years [1970, 1971, ... , 1979]' do
				Decade.new(1970).map(&:year).should == [1970, 1971, 1972, 1973, 1974, 1975, 1976, 1977, 1978, 1979]
			end
		
		end
		
	end

	describe Century do
		
		it { should_not be nil }

		describe '.current' do
			it 'creates the current century' do
				Century.current.year.should == (Time.now.year / 100) * 100
			end
		end
		
	end
	
	
end