module EDTF
  # Individual parse results are listed in spec/fixtures/compatibility.yml
  # (see compatibility_spec.rb). These examples cover the parser itself.
  describe Parser do
    let(:parser) { Parser.new }

    describe '#parse' do
      it 'returns nil for invalid input' do
        expect(parser.parse('xyz')).to be_nil
      end

      it 'can be called repeatedly on the same instance' do
        expect(parser.parse('2001-02-03').edtf).to eq('2001-02-03')
        expect(parser.parse('xyz')).to be_nil
        expect(parser.parse('1984?').edtf).to eq('1984?')
      end
    end

    describe '#parse!' do
      it 'raises an ArgumentError for invalid input' do
        expect { parser.parse!('xyz') }.to raise_error(ArgumentError, /failed to parse date/)
      end
    end

    it 'handles the Gregorian 10-day correction' do
      (4..15).each do |mday|
        date = parser.parse('1582-10-%02d' % mday)
        expect(date).to be_gregorian
        expect(date.values).to eq([1582, 10, mday])
      end
    end
  end
end
