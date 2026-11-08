module EDTF
  describe Builder do
    def build(input, **options)
      Builder.build(Parser.new(warn: false).parse!(input), **options)
    end

    describe 'centuries: true (default)' do
      it 'builds years with unspecified trailing digits as centuries and decades' do
        expect(build('19XX')).to eql(Century.new(19))
        expect(build('-196X~')).to eql(Decade.new(-196, approximate: true))
        expect(build('19XX?')).to eql(Century.new(19, uncertain: true))
        expect(build('19uu')).to eql(Century.new(19))
      end

      it 'builds other unspecified digits as dates' do
        expect(build('1X0X')).to be_an(EDTF::Date)
        expect(build('19XX-06')).to be_an(EDTF::Date)
      end

      it 'applies to interval ends and set members' do
        expect(build('05XX/15XX')).to eql(Interval.new(Century.new(5), Century.new(15)))
        expect(build('[19XX,1X0X]').to_a.map(&:class)).to eq([Century, EDTF::Date])
      end

      it 'applies to hand-written results' do
        result = { 'type' => 'date', 'values' => [1990], 'unspecified' => Bitmask::YYYX }
        expect(EDTF(result)).to eql(Decade.new(199))
      end
    end

    describe 'centuries: false' do
      it 'builds dates with unspecified digits' do
        expect(build('19XX', centuries: false)).to eql(EDTF::Date.new(1900, unspecified: Bitmask::YYXX))
        expect(build('05XX/15XX', centuries: false).from).to be_an(EDTF::Date)
      end

      it 'rejects them with qualifiers' do
        expect { build('19XX?', centuries: false) }.to raise_error(ArgumentError, /qualified/)
      end
    end

    describe 'EDTF.parse' do
      it 'passes centuries: to the builder, off with strict: true' do
        expect(EDTF.parse('196X')).to be_a(Decade)
        expect(EDTF.parse('196X', centuries: false)).to be_an(EDTF::Date)
        expect(EDTF.parse('196X', strict: true)).to be_an(EDTF::Date)
        expect(EDTF.parse('196X', strict: true, centuries: true)).to be_a(Decade)
      end

      it 'rejects dates with qualified unspecified digits' do
        expect(EDTF.parse('1X84?')).to be_nil
        expect(EDTF.parse('2004-XX~')).to be_nil
      end
    end
  end
end
