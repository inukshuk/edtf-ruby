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

      it 'rejects days the month cannot have' do
        expect { parser.parse!('2019-02-29') }.to raise_error(ArgumentError)
        expect { parser.parse!('156X-09-31') }.to raise_error(ArgumentError)
        expect(parser.parse!('15XX-02-29')[:values]).to eq([1500, 2, 29])
      end
    end

    describe 'results' do
      let(:parser) { Parser.new(warn: false) }

      def self.date(*values, level: 0, **attributes)
        { type: :date, values: values, level: level, **attributes }
      end

      {
        '2004' => date(2004),
        '2004-06-11' => date(2004, 6, 11),
        '-0999' => date(-999),
        '2004-06?' => date(2004, 6, uncertain: Bitmask::YM, level: 1),
        '2004-06-11%' => date(2004, 6, 11, uncertain: Bitmask::YMD, approximate: Bitmask::YMD, level: 1),
        '2004?-06~' => date(2004, 6, uncertain: Bitmask::YEAR, approximate: Bitmask::YM, level: 2),
        '2004-06-(11)~' => date(2004, 6, 11, approximate: Bitmask::DAY, level: 2, legacy: true),
        '199X' => date(1990, unspecified: Bitmask::YYYX, level: 1),
        '2004-XX-XX' => date(2004, 1, 1, unspecified: Bitmask::MD, level: 1),
        '19XX-06' => date(1900, 6, unspecified: Bitmask::YYXX, level: 2),
        'XXXX' => date(0, unspecified: Bitmask::XXXX, level: 1),
        '2001-02-03^julian' => date(2001, 2, 3, calendar: 'julian', level: 2, legacy: true),
        '2016-05-02T16:54:59' =>
          { type: :date_time, values: [2016, 5, 2, 16, 54, 59], level: 0 },
        '2016-05-02T16:54:59-04:00' =>
          { type: :date_time, values: [2016, 5, 2, 16, 54, 59], offset: -240, level: 0 },
        'Y170000002' => { type: :year, level: 1, values: [170000002] },
        'Y-17E7' => { type: :year, level: 2, values: [-170000000] },
        '196x' => { type: :decade, values: [196], level: 2, legacy: true },
        '19xx' => { type: :century, values: [19], level: 2, legacy: true },
        '2001-21' => { type: :season, values: [2001, 21], level: 1 },
        '2001-21?' => { type: :season, values: [2001, 21], uncertain: Bitmask::YM, level: 2 },
        '2001-21^southern' =>
          { type: :season, values: [2001, 21], qualifier: 'southern', level: 2, legacy: true },
        '1964/2008' => { type: :interval, values: [date(1964), date(2008)], level: 0 },
        '2004/..' => { type: :interval, values: [date(2004), :open], level: 1 },
        '/2004' => { type: :interval, values: [:unknown, date(2004)], level: 1 },
        '2004-06-XX/2004-07-03' => {
          type: :interval,
          values: [date(2004, 6, 1, unspecified: Bitmask::DAY, level: 1), date(2004, 7, 3)],
          level: 2
        },
        '[1667,1670..1672]' =>
          { type: :set, values: [date(1667), [date(1670), date(1672)]], level: 2 },
        '{..1984,1990..}' =>
          { type: :list, values: [date(1984), date(1990)], earlier: true, later: true, level: 2 }
      }.each do |input, result|
        it "for #{input}" do
          expect(parser.parse!(input)).to eq(result)
        end
      end

      it 'are deeply frozen' do
        result = parser.parse!('[1667,1670..1672]')
        expect(result).to be_frozen
        expect(result[:values]).to be_frozen
        expect(result[:values][1][0][:values]).to be_frozen
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
        '{1960, 1961-12}' => [:whitespace],
        '[1864 ..]' => [:whitespace],
        '2004/ ..' => [:whitespace],
        '2001-02-03^xyz' => [:caret],
        'XXXX' => [:unknown_date],
        'uuuu' => [:unspecified, :unknown_date],
        '1984%' => [],
        '2004/..' => [],
        '2004/' => [],
        '199X' => [],
        'Y17E7' => [],
        '{1960,1961-12}' => [],
        '[1864..]' => []
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
  end
end
