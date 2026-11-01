# Partly ported from edtf.js test/set.js and test/list.js.
module EDTF
  describe Set do
    it_behaves_like 'a period' do
      let(:period) { EDTF.parse('[1667,1668,1670..1672]') }
    end

    it_behaves_like 'a period' do
      let(:period) { EDTF.parse('[..1760-12-03]') }
    end

    it 'is one of a set' do
      expect(EDTF.parse('[1667,1668]')).to be_an(EDTF::Set)
      expect(EDTF.parse('[1667,1668]')).not_to be_an(EDTF::List)
      expect(EDTF.parse('[1667,1668]')).not_to be_a(::Set)
    end

    describe '#edtf' do
      it 'wraps the members in brackets' do
        expect(Set.new.edtf).to eq('[]')
        expect(Set.new(Date.new(2016)).edtf).to eq('[2016]')
        expect(Set.new(Date.new(2016)..Date.new(2018)).edtf).to eq('[2016..2018]')
      end

      it 'marks open starts and ends' do
        expect(Set.new(Date.new(2016), earlier: true).edtf).to eq('[..2016]')
        expect(Set.new(Date.new(2016), later: true).edtf).to eq('[2016..]')
        expect(Set.new(earlier: true).edtf).to eq('[]')
      end
    end

    it 'supports varying precisions' do
      %w[[1984,1985-10-01] [1984,1985-10-01..] [..1984,1985-10-01..]].each do |string|
        expect(EDTF.parse(string).values.map(&:precision)).to eq(%i[year day])
      end
    end
  end

  describe List do
    it_behaves_like 'a period' do
      let(:period) { EDTF.parse('{1667,1668,1670..1672}') }
    end

    it_behaves_like 'a period' do
      let(:period) { EDTF.parse('{1984~,1985}') }
    end

    it 'is all members of a set' do
      expect(EDTF.parse('{1667,1668}')).to be_an(EDTF::List)
      expect(EDTF.parse('{1667,1668}')).not_to be_an(EDTF::Set)
    end

    describe '#edtf' do
      it 'wraps the members in braces' do
        expect(List.new.edtf).to eq('{}')
        expect(List.new(Date.new(2016)).edtf).to eq('{2016}')
        expect(List.new(Date.new(2016), later: true).edtf).to eq('{2016..}')
        expect(List.new(Date.new(2016)..Date.new(2018)).edtf).to eq('{2016..2018}')
        expect(List.new(later: true).edtf).to eq('{}')
      end
    end
  end

  describe Members do
    let(:list) { EDTF.parse('{1667,1668,1670..1672}') }

    describe '.new' do
      it 'takes periods, ranges of periods, and plain dates' do
        list = List.new(Date.new(1667), Season.new(1668, 21), ::Date.new(1669, 1, 2), Date.new(1670)..Date.new(1672))
        expect(list.edtf).to eq('{1667,1668-21,1669-01-02,1670..1672}')
      end

      it 'rejects anything else' do
        expect { List.new('1667') }.to raise_error(ArgumentError)
      end

      it 'is frozen' do
        expect(list).to be_frozen
        expect(list.values).to be_frozen
      end
    end

    describe 'members' do
      it 'remembers ranges as written' do
        expect(list.values.length).to eq(3)
        expect(list.values.last).to eq(Date.new(1670)..Date.new(1672))
      end

      it 'enumerates ranges' do
        expect(list.map(&:year)).to eq([1667, 1668, 1670, 1671, 1672])
        expect(list.count).to eq(5)
      end

      it 'converts to a Ruby Set of the enumerated members' do
        expect(list.to_set).to eq(::Set[*%w[1667 1668 1670 1671 1672].map { |y| EDTF.parse(y) }])
      end

      it 'cannot convert open sets' do
        expect { EDTF.parse('{1984..}').to_set }.to raise_error(RangeError)
      end
    end

    describe '#include?' do
      it 'is true for enumerated members' do
        expect(list).to be_include(EDTF.parse('1671'))
        expect(list).not_to be_include(EDTF.parse('1669'))
        expect(list).not_to be_include(EDTF.parse('1671-01-01'))
      end

      it 'reaches beyond open ends at the same precision' do
        earlier, later = EDTF.parse('{..1984}'), EDTF.parse('{1984..}')
        expect(earlier).to be_include(EDTF.parse('1984'))
        expect(earlier).to be_include(EDTF.parse('-1984'))
        expect(earlier).not_to be_include(EDTF.parse('1995'))
        expect(earlier).not_to be_include(EDTF.parse('1980-01'))
        expect(later).to be_include(EDTF.parse('1995'))
        expect(later).not_to be_include(EDTF.parse('-1984'))
      end

      it 'matches membership in each, without iterating' do
        set = EDTF.parse('[1985,1985-03,1994-12,1667..1669]')
        %w[1985 1985-03 1985-04 1994-12 1668 1670 1668-01].map { |s| EDTF.parse(s) }.each do |other|
          expect(set.include?(other)).to eq(set.any? { |member| member == other })
        end
      end

      it 'is false for empty sets' do
        expect(List.new).not_to be_include(EDTF.parse('1984'))
      end
    end

    describe 'bounds' do
      it 'span all members' do
        expect(EDTF.parse('[1760-01,1760-12-03,1759]').to_range)
          .to eq(::Date.new(1759, 1, 1)..::Date.new(1760, 12, 3))
      end

      it 'are open at open starts and ends' do
        expect(EDTF.parse('[..1760-12-03]').to_range).to eq(..::Date.new(1760, 12, 3))
        expect(EDTF.parse('[1760-12..]').to_range).to eq(::Date.new(1760, 12, 1)..)
      end

      it 'cover the dates between the members' do
        expect(list).to be_cover(EDTF.parse('1669'))
        expect(list).not_to be_cover(EDTF.parse('1673'))
      end

      it 'take the precision of the first member' do
        expect(EDTF.parse('[1984,1985-10-01]').precision).to eq(:year)
        expect(List.new.precision).to be_nil
      end
    end

    describe 'empty sets' do
      it 'cover nothing' do
        expect(Set.new).not_to be_cover(::Date.today)
        expect(List.new).not_to be_include(EDTF.parse('2004'))
      end

      it 'have no open start or end' do
        expect(Set.new(earlier: true)).not_to be_earlier
        expect(Set.new(earlier: true)).to eql(Set.new)
      end
    end

    describe 'ranges' do
      it 'are tested by their bounds, not enumerated' do
        list = EDTF.parse('{1000-01-01..2999-12-31}')
        expect(list).to be_include(EDTF.parse('2000-05-05'))
        expect(list).not_to be_include(EDTF.parse('3000-01-01'))
        expect(list).not_to be_include(EDTF.parse('2000-05'))
      end
    end

    it 'stays frozen through dup and Marshal' do
      [list.dup, Marshal.load(Marshal.dump(list))].each { |copy| expect(copy).to be_frozen.and eql(list) }
    end

    describe 'comparison' do
      it 'treats open starts and ends like those of intervals' do
        expect(EDTF.parse('[..2004]')).to eq(EDTF.parse('../2004'))
        expect(EDTF.parse('[..2004]')).not_to eq(EDTF.parse('/2004'))
        expect(EDTF.parse('{2004..}')).to eq(EDTF.parse('2004/..'))
      end

      it 'eql? compares the class, members and open ends' do
        expect(EDTF.parse('[1667,1668]')).to eql(EDTF.parse('[1667,1668]'))
        expect(EDTF.parse('[1667,1668]')).not_to eql(EDTF.parse('{1667,1668}'))
        expect(EDTF.parse('[1667,1668]')).not_to eql(EDTF.parse('[1667,1668?]'))
        expect(EDTF.parse('[1667,1668]')).not_to eql(EDTF.parse('[1667,1668..]'))
        expect(EDTF.parse('[1667,1668]').hash).to eq(EDTF.parse('[1667,1668]').hash)
      end

      it 'orders by bounds' do
        expect(EDTF.parse('{1667,1668}')).to be < EDTF.parse('{1669}')
        expect(EDTF.parse('{..1667}')).to be < EDTF.parse('{1667}')
      end
    end

    describe '#with' do
      it 'replaces members and open ends' do
        expect(list.with(later: true).edtf).to eq('{1667,1668,1670..1672..}')
        expect(list.with(values: [Date.new(2001)]).edtf).to eq('{2001}')
        expect { list.with(choice: true) }.to raise_error(ArgumentError)
      end
    end
  end
end
