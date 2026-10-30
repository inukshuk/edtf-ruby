# Parse results are specified in features/parser.
# These examples cover the Parser class itself.
module EDTF
  describe Parser do
    let(:parser) { Parser.new }

    describe '#parse' do
      it 'returns nil for invalid input' do
        expect(parser.parse('xyz')).to be_nil
      end
    end

    describe '#parse!' do
      it 'raises an ArgumentError for invalid input' do
        expect { parser.parse!('xyz') }.to raise_error(ArgumentError)
      end
    end

    it 'handles the Gregorian 10-day correction' do
      (4..15).each do |mday|
        date = parser.parse('1582-10-%02d' % mday)
        expect(date).to be_gregorian
        expect([date.year, date.month, date.mday]).to eq([1582, 10, mday])
      end
    end
  end
end
