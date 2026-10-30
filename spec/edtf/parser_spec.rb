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

    describe '#deprecations' do
      {
        '1984?~' => [:combined_qualifier],
        '2004-(06)?-11' => [:parentheses],
        '2004/open' => [:open],
        'unknown/2004' => [:unknown],
        '199u' => [:unspecified],
        '198x' => [:masked],
        'y170000002' => [:lowercase_y],
        'Y17e7' => [:lowercase_e],
        '-0000' => [:negative_zero],
        '2001-02-03^xyz' => [:caret],
        'XXXX' => [:unknown_date],
        'uuuu' => [:unspecified, :unknown_date],
        '1984%' => [],
        '2004/..' => [],
        '2004/' => [],
        '199X' => [],
        'Y17E7' => []
      }.each do |input, deprecations|
        it "are #{deprecations.inspect} for #{input.inspect}" do
          parser.parse!(input)
          expect(parser.deprecations).to eq(deprecations)
        end
      end

      it 'are reset by each parse' do
        parser.parse!('1984?~')
        parser.parse!('1984%')
        expect(parser.deprecations).to be_empty
      end
    end

    describe '#legacy?' do
      it 'is true for legacy syntax' do
        parser.parse!('2004/open')
        expect(parser).to be_legacy
      end

      it 'is false for input that only changes meaning' do
        parser.parse!('XXXX')
        expect(parser).not_to be_legacy
      end
    end

    describe 'deprecation warnings' do
      around do |example|
        enabled = Warning[:deprecated]
        example.run
      ensure
        Warning[:deprecated] = enabled
      end

      it 'are silent by default' do
        Warning[:deprecated] = false
        expect { parser.parse!('1984?~') }.not_to output.to_stderr
      end

      it 'name the input and the replacement when enabled' do
        Warning[:deprecated] = true
        expect { parser.parse!('1984?~') }
          .to output(/EDTF "1984\?~": `\?~` is legacy syntax, use `%`/).to_stderr
      end

      it 'are emitted once per parse' do
        Warning[:deprecated] = true
        expect { parser.parse!('199u/unknown') }
          .to output(/\A[^\n]*`u`[^\n]*`unknown`[^\n]*\n\z/).to_stderr
      end

      it 'are not emitted for ISO 8601-2 input' do
        Warning[:deprecated] = true
        expect { parser.parse!('1984%/..') }.not_to output.to_stderr
      end

      it 'can be turned off per parser' do
        Warning[:deprecated] = true
        expect { Parser.new(warn: false).parse!('1984?~') }.not_to output.to_stderr
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
