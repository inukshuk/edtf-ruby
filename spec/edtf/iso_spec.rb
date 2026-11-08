# Both grammars read ISO 8601-2 input alike,
# so the ISO grammar can take over from the legacy grammar.
module EDTF
  describe ISO do
    let(:grammar) { ISO.new(extensions: Grammar::EXTENSIONS) }
    let(:legacy) { Legacy.new }

    def parse(grammar, input)
      Parser.new.send(:finish, grammar.parse(input))
    end

    %w[
      2004 -0999 0000 2004-06 2004-06-11
      2004-06-11T10:10:10 2004-06-11T10:10:10Z
      2004-06-11T10:10:10+14:00 2004-06-11T10:10:10-04:30
      1984? 2004-06~ 2004-06-11% 2004?-06-11 2004-06~-01? 2004%-06
      XXXX 199X -199X 19XX-06 2004-XX 2004-XX-XX 2004-06-XX
      1999-XX-01 19XX-XX-01 199X-01-XX 15XX-02-29
      1964/2008 2004-06/.. ../2004 2004/ /2004 1984?/2004~ 05XX/15XX
      Y10000 Y-170000002 Y17E7 Y-17E7 Y170000002E3
      2001-21 2001-24 2001-21%
      [1667,1670..1672] {1960,1961-12} [..1984] [1760-12..]
      {..1984,1990..} [1984,1990?] [1760-01,1760-02,1760-12..]
    ].each do |input|
      it "reads #{input} like the legacy grammar" do
        expect(parse(grammar, input)).to eq(parse(legacy, input))
      end
    end

    describe 'dates made of parts' do
      def self.date(*values, **attributes)
        { type: :date, values: values, **attributes }
      end

      {
        '?2004-06-~11' =>
          date(2004, 6, 11, uncertain: Bitmask::YEAR, approximate: Bitmask::DAY, level: 2),
        '2001-?09~-09' =>
          date(2001, 9, 9, uncertain: Bitmask::MONTH, approximate: Bitmask::YM, level: 2),
        '?-2004' => date(-2004, uncertain: Bitmask::YEAR, level: 2),
        '1XX3' => date(1003, unspecified: Bitmask.compute('yxxymmdd')),
        '2016-01-X0' => date(2016, 1, 10, unspecified: Bitmask::XD),
        '1984-1X' => date(1984, 10, unspecified: Bitmask::MX),
        '2004-X2-3X' => date(2004, 12, 30, unspecified: Bitmask::XM | Bitmask::DX),
        '-00XX' => date(-1, unspecified: Bitmask::YYXX),
        '-00X0' => date(-10, unspecified: Bitmask.compute('yyxymmdd')),
        'XXXX-12-XX' => date(0, 12, 1, unspecified: Bitmask::XXXX | Bitmask::DAY),
        '199X?' => date(1990, unspecified: Bitmask::YYYX, uncertain: Bitmask::YEAR),
        '2001-33' => { type: :season, values: [2001, 33] },
        '2001-21~' => { type: :season, values: [2001, 21], approximate: Bitmask::YM },
        '?2001-~21' => {
          type: :season, values: [2001, 21], uncertain: Bitmask::YEAR, approximate: Bitmask::MONTH
        },
        '20XX-21' => { type: :season, values: [2000, 21], unspecified: Bitmask::YYXX },
        '-000X-21' => { type: :season, values: [-1, 21], unspecified: Bitmask::YYYX },
        '2001-21/2001-22' => {
          type: :interval,
          values: [{ type: :season, values: [2001, 21] }, { type: :season, values: [2001, 22] }]
        },
        '196' => { type: :decade, values: [196] },
        '009~' => { type: :decade, values: [9], approximate: Bitmask::YEAR },
        '19' => { type: :century, values: [19] },
        '?19' => { type: :century, values: [19], uncertain: Bitmask::YEAR },
        '19/20' => {
          type: :interval,
          values: [{ type: :century, values: [19] }, { type: :century, values: [20] }]
        }
      }.each do |input, result|
        it "reads #{input}" do
          expect(grammar.parse(input)).to eq(result)
        end
      end

      %w[
        12345 1 -00 -01 -196 -009~ 2004-2X 2004-00 2004-13 2004-42 2004-X4-31 2004-4X
        19-21 200X-21? 1X 2004?-06-11T10:10:10
        [2001-21,2001-22] 2001-21/.. 2001-21/2002 {..~-0662} [..0000%..] {..1600-08-20..}
        [1667,1670..1672-01]
      ].each do |input|
        it "rejects #{input}" do
          expect { grammar.parse(input) }.to raise_error(ArgumentError)
        end
      end
    end

    describe 'times and intervals' do
      def self.time(*values, offset: nil)
        { type: :date_time, values: [2004, 6, 11, *values], offset: offset }.compact
      end

      def self.interval(from, to)
        { type: :interval, values: [from, to] }
      end

      {
        '2004-06-11T10:10:10.042' => time(10, 10, 10, 42),
        '2004-06-11T10:10:10,5' => time(10, 10, 10, 500),
        '2004-06-11T10:10:10.000' => time(10, 10, 10, 0),
        '2004-06-11T10:10:10-04' => time(10, 10, 10, offset: -240),
        '2004-06-11T10:10:10+0230' => time(10, 10, 10, offset: 150),
        '2004-06-11T10:10:10+00' => time(10, 10, 10, offset: 0),
        '2004-06-11T10:10:10+14:01' => time(10, 10, 10, offset: 841),
        '2004-06-11T10:10:10-15:56' => time(10, 10, 10, offset: -956),
        '2004-06-11T10:10:10+23:59' => time(10, 10, 10, offset: 1439),
        '2004-06-11T10' => time(10),
        '2004-06-11T10:30-04' => time(10, 30, offset: -240),
        '2004-06-11T10/2004-06-11T24' =>
          interval(time(10), time(24)),
        '2004-12-31/2004-12-31T24:00:00Z' => interval(
          { type: :date, values: [2004, 12, 31] },
          { type: :date_time, values: [2004, 12, 31, 24, 0, 0], offset: 0 }
        ),
        '/' => interval(:unknown, :unknown),
        '../..' => interval(:open, :open),
        '../' => interval(:open, :unknown),
        '/..' => interval(:unknown, :open),
        '2004-06-11T10:10:10Z/2004-06-11T12:00:00Z' =>
          interval(time(10, 10, 10, offset: 0), time(12, 0, 0, offset: 0)),
        '2004-06-11/2004-06-11T12:00:00' =>
          interval({ type: :date, values: [2004, 6, 11] }, time(12, 0, 0))
      }.each do |input, result|
        it "reads #{input}" do
          expect(grammar.parse(input)).to eq(result)
        end
      end

      it 'turns off basic offsets with the extension' do
        grammar = ISO.new(extensions: [])
        expect { grammar.parse('2004-06-11T10:10:10+0230') }.to raise_error(ArgumentError)
        expect(grammar.parse('2004-06-11T10:10:10+02')).to include(offset: 120)
      end

      %w[
        2004-06-11T10:10:10.0421 2004-06-11T10:10:10. 2004-06-11T10:10:10-00
        2004-06-11T10:10:10-0000 2004-06-11T10:10:10+24:00 2004-06-11T10:10:10+12:60
        2004-06-11T10:10:10+2 2004-06-11T10:10:10+02:3 .. ../../.. 2004//2005
        2004-06-11T24 2004-06-11T24:00 2004-06-11T24/.. 2004-06-11T24:00:01/..
        ../2004-06-11T24:30 ../2004-06-11T24:00:00.000 2004-06-11T1030
      ].each do |input|
        it "rejects #{input}" do
          expect { grammar.parse(input) }.to raise_error(ArgumentError)
        end
      end
    end

    describe 'years with significant digits' do
      def self.year(value, level, significant = nil)
        { type: :year, level: level, values: [value], significant: significant }.compact
      end

      {
        '1950S2' => year(1950, 2, 2),
        '-1950S2' => year(-1950, 2, 2),
        'Y171010000S3' => year(171010000, 2, 3),
        'Y3388E2S3' => year(338800, 2, 3),
        'Y-17E7S2' => year(-170000000, 2, 2)
      }.each do |input, result|
        it "reads #{input}" do
          expect(grammar.parse(input)).to eq(result)
        end
      end

      %w[1950S0 1950S 1950S02 2004-06S2 1950?S2 199XS2 196S1 Y17S2].each do |input|
        it "rejects #{input}" do
          expect { grammar.parse(input) }.to raise_error(ArgumentError)
        end
      end
    end

    describe 'the minus sign U+2212' do
      {
        "−2004" => { type: :date, values: [-2004] },
        "−199X" => { type: :date, values: [-1990], unspecified: Bitmask::YYYX },
        "Y−170000002" => { type: :year, level: 1, values: [-170000002] },
        "Y−17E7" => { type: :year, level: 2, values: [-170000000] },
        "2004-06-11T10:10:10−04:00" =>
          { type: :date_time, values: [2004, 6, 11, 10, 10, 10], offset: -240 }
      }.each do |input, result|
        it "reads #{input}" do
          expect(grammar.parse(input)).to eq(result)
        end
      end

      it 'is not a separator' do
        expect { grammar.parse("2004−06") }.to raise_error(ArgumentError)
      end

      it 'is not read from other encodings' do
        expect { grammar.parse("−2004".b) }.to raise_error(Grammar::ParseError)
        expect { grammar.parse('2004'.encode('UTF-16LE')) }
          .to raise_error(Grammar::ParseError)
        expect(grammar.parse('2004'.b)).to eq(type: :date, values: [2004])
      end
    end

    [
      '2004-06-(11)~', '1984?~', '2004/open', 'unknown/2004', '199u',
      '198x', 'y17e7', '-0000', '{1960, 1961}', '2001-21^southern',
      '2001-02-03^julian', '2004T10:10:10',
      '2004-06-11T24:00:00', '2004-06-11T10:10:10-00:00',
      '2004-06-31?', 'Y9999', 'Y01000', 'Y17E0', '..',
      'xyz', '2004 '
    ].each do |input|
      it "rejects #{input}" do
        expect { grammar.parse(input) }.to raise_error(ArgumentError)
      end
    end
  end
end
