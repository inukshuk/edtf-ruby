# Partly ported from edtf.js test/decade.js and test/century.js.
module EDTF
  describe Decade do
    it_behaves_like 'a period', parses: false do
      let(:period) { Decade.new(196) }
    end

    it_behaves_like 'a period', parses: false do
      let(:period) { Decade.new(-9, approximate: true) }
    end

    it 'has decade precision' do
      expect(Decade.new(196).precision).to eq(:decade)
    end

    it 'rejects more than three digits' do
      expect { Decade.new(1990) }.to raise_error(ArgumentError)
    end

    describe 'bounds' do
      {
        199 => %w[1990-01-01 1999-12-31],
        0 => %w[0000-01-01 0009-12-31],
        -9 => %w[-0099-01-01 -0090-12-31]
      }.each do |value, bounds|
        it "are #{bounds.join(' and ')} for #{value}" do
          d = Decade.new(value)
          expect([d.begin, d.end].map(&:iso8601)).to eq(bounds)
        end
      end
    end

    describe '#edtf' do
      it 'pads to three digits' do
        expect(Decade.new(198).edtf).to eq('198')
        expect(Decade.new(99).edtf).to eq('099')
        expect(Decade.new(-9).edtf).to eq('-009')
      end

      it 'qualifies the whole decade' do
        expect(Decade.new(198, approximate: true).edtf).to eq('198~')
        expect(Decade.new(198, uncertain: true).edtf).to eq('198?')
        expect(Decade.new(198, uncertain: true, approximate: true).edtf).to eq('198%')
      end
    end

    describe 'qualifiers' do
      it 'reject parts: an epoch is qualified as a whole' do
        expect { Decade.new(196, uncertain: :year) }.to raise_error(ArgumentError, /as a whole/)
      end

      it 'stay frozen through Marshal' do
        decade = Decade.new(198, uncertain: true)
        expect(Marshal.load(Marshal.dump(decade))).to be_frozen.and eql(decade)
      end

      it 'are booleans, also given as bitmasks' do
        expect(Decade.new(201, uncertain: true)).to be_uncertain
        expect(Decade.new(201)).not_to be_uncertain
        expect(Decade.new(201, approximate: Bitmask::YEAR)).to be_approximate
        expect(Decade.new(201, approximate: 0)).not_to be_approximate
      end
    end

    describe '#with' do
      it 'replaces the given attributes' do
        expect(Decade.new(196).with(approximate: true).edtf).to eq('196~')
        expect(Decade.new(196).with(value: 197).edtf).to eq('197')
        expect { Decade.new(196).with(year: 1970) }.to raise_error(ArgumentError)
      end
    end

    describe 'comparison' do
      it '== means the same period; eql? includes the qualifiers' do
        expect(Decade.new(199)).to eq(Decade.new(199, uncertain: true))
        expect(Decade.new(199)).not_to eql(Decade.new(199, uncertain: true))
        expect(Decade.new(199)).to eql(Decade.new(199))
      end

      it 'orders by bounds and precision' do
        expect(Decade.new(199)).to be < Decade.new(200)
        expect(Century.new(19)).to be > Decade.new(190)
        expect(Decade.new(199) <=> ::Date.new(1980, 1, 1)).to eq(1)
        expect(::Date.new(1980, 1, 1) <=> Decade.new(199)).to eq(-1)
      end

      it 'covers the dates within' do
        expect(Decade.new(198)).to be_cover(::Date.new(1989, 12, 31))
        expect(Decade.new(198)).to be_cover(EDTF.parse('1985-06'))
        expect(Decade.new(198)).not_to be_cover(::Date.new(1990, 1, 1))
      end

      it 'has no include?, as it is not a collection' do
        expect(Decade.new(198)).not_to respond_to(:include?)
      end
    end

    it 'steps by decade' do
      expect((Decade.new(199)..Decade.new(201)).map(&:edtf)).to eq(%w[199 200 201])
      expect(Decade.new(199).prev.edtf).to eq('198')
    end
  end

  describe Century do
    it_behaves_like 'a period', parses: false do
      let(:period) { Century.new(19) }
    end

    it 'has century precision' do
      expect(Century.new(19).precision).to eq(:century)
    end

    it 'rejects more than two digits' do
      expect { Century.new(190) }.to raise_error(ArgumentError)
    end

    describe 'bounds' do
      # edtf.js spans -19 from -1900 to -1801.
      {
        19 => %w[1900-01-01 1999-12-31],
        0 => %w[0000-01-01 0099-12-31],
        -19 => %w[-1999-01-01 -1900-12-31]
      }.each do |value, bounds|
        it "are #{bounds.join(' and ')} for #{value}" do
          c = Century.new(value)
          expect([c.begin, c.end].map(&:iso8601)).to eq(bounds)
        end
      end

      it 'match the unspecified year with the same digits' do
        expect(Century.new(-19).to_range).to eq(EDTF.parse('-19XX').to_range)
      end
    end

    describe '#edtf' do
      it 'pads to two digits' do
        expect(Century.new(20).edtf).to eq('20')
        expect(Century.new(1).edtf).to eq('01')
        expect(Century.new(0).edtf).to eq('00')
        expect(Century.new(-1).edtf).to eq('-01')
      end

      it 'qualifies the whole century' do
        expect(Century.new(20, uncertain: true).edtf).to eq('20?')
      end
    end

    it 'is a different period than the unspecified year with the same span' do
      expect(Century.new(19)).not_to eq(EDTF.parse('19XX'))
      expect(Century.new(19).to_range).to eq(EDTF.parse('19XX').to_range)
    end
  end
end
