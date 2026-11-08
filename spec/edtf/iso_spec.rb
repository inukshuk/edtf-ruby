# The features run through the legacy grammar until the parser
# tries the ISO grammar first; until then these examples check
# that both grammars read ISO 8601-2 input alike.
module EDTF
  describe ISO do
    let(:grammar) { ISO.new }
    let(:parser) { Parser.new(warn: false) }

    def parse(input)
      parser.send(:finish, grammar.parse(input))
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
        expect(parse(input)).to eq(parser.parse!(input))
      end
    end

    [
      '2004-06-(11)~', '1984?~', '2004/open', 'unknown/2004', '199u',
      '198x', 'y17e7', '-0000', '{1960, 1961}', '2001-21^southern',
      '2001-02-03^julian', '2004T10:10:10',
      '2004-06-11T24:00:00', '2004-06-11T10:10:10+14:01',
      '2004-06-11T10:10:10-00:00', '2004-06-31?', '2015-02-29~',
      'Y9999', 'Y01000', 'Y17E0', '..', '/', '../..', 'xyz', '2004 '
    ].each do |input|
      it "rejects #{input}" do
        expect { grammar.parse(input) }.to raise_error(ArgumentError)
      end
    end
  end
end
