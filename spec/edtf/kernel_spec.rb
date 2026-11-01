describe 'EDTF()' do
  it 'parses strings' do
    expect(EDTF('2004-06?')).to eql(EDTF.parse('2004-06?'))
  end

  it 'raises an ArgumentError for invalid strings' do
    expect { EDTF('xyz') }.to raise_error(ArgumentError)
  end

  it 'converts times to date-times with their offset' do
    time = Time.new(2004, 6, 11, 10, 30, Rational(15, 10), '+05:30')
    expect(EDTF(time)).to be_an(EDTF::DateTime)
    expect(EDTF(time)).to eq(time)
    expect(EDTF(time).edtf).to eq('2004-06-11T10:30:01.5+05:30')
  end

  it 'returns EDTF date-times unchanged' do
    time = EDTF.parse('2004-06-11T10:30:00')
    expect(EDTF(time)).to equal(time)
  end

  it 'returns EDTF dates unchanged' do
    date = EDTF.parse('2004-06?')
    expect(EDTF(date)).to equal(date)
  end

  it 'converts plain dates to EDTF dates with day precision' do
    date = EDTF(Date.new(2004, 6, 11))
    expect(date).to be_an(EDTF::Date)
    expect(date.edtf).to eq('2004-06-11')
  end

  %w[2004-06~ 2004-22 199X 2004/2006 {2004,2006} [2004,2006]].each do |string|
    it "returns #{string} unchanged" do
      value = EDTF.parse!(string)
      expect(EDTF(value)).to equal(value)
    end
  end

  describe 'parse results' do
    %w[2004-06? 2016-05-02T16:54:59+05:00 Y-17E7 196x 2001-21? 2004-06?/.. /2004 [..1667,1668?,1670..1672] {1984~,1985}]
      .each do |string|
      it "builds #{string} from its parse result" do
        result = EDTF::Parser.new(warn: false).parse!(string)
        expect(EDTF(result)).to eql(EDTF.parse(string))
      end
    end

    it 'builds results read back from JSON' do
      require 'json'
      result = JSON.parse(JSON.generate(EDTF::Parser.new.parse!('2004-06?/..')))
      expect(result['values'][1]).to eq('open')
      expect(EDTF(result)).to eql(EDTF.parse('2004-06?/..'))
    end

    it 'builds hand-written results' do
      expect(EDTF(type: :date, values: [2004, 6], uncertain: 63).edtf).to eq('2004-06?')
    end

    it 'builds only the known types' do
      expect { EDTF(type: :exit, values: []) }.to raise_error(ArgumentError, /type/)
      expect { EDTF('type' => 'send', 'values' => []) }.to raise_error(ArgumentError, /type/)
      expect { EDTF(values: [2004]) }.to raise_error(ArgumentError, /type/)
    end

    it 'raises an ArgumentError for invalid results' do
      expect { EDTF(type: :date) }.to raise_error(ArgumentError, /values/)
      expect { EDTF(type: :date, values: [2004, 13]) }.to raise_error(ArgumentError)
      expect { EDTF(type: :set, values: ['1667']) }.to raise_error(ArgumentError)
    end
  end

  [nil, 2004, :year, [2004]].each do |value|
    it "raises a TypeError for #{value.inspect}" do
      expect { EDTF(value) }.to raise_error(TypeError)
    end
  end

  # spec/active_support runs in its own process (rake spec:active_support).
  it 'needs no ActiveSupport' do
    expect(defined?(ActiveSupport)).to be_nil
  end

  it 'is the only core extension' do
    expect(::Date).not_to respond_to(:edtf)
    expect(::Date.new).not_to respond_to(:precision)
    expect(::Date.new).not_to respond_to(:edtf)
    expect(1..2).not_to respond_to(:edtf)
  end

  it 'lets plain dates compare with every kind of period' do
    expect(::Date.new(1980, 1, 1) <=> EDTF::Decade.new(196)).to eq(1)
    expect(::Date.new(2004, 6, 1) <=> EDTF('2004/2005')).to eq(1)
    expect(::Date.new(1667, 6, 1) <=> EDTF('{1667,1668}')).to eq(1)
    expect([EDTF('2001-21'), ::Date.new(2001, 1, 1)].sort.first).to eq(::Date.new(2001, 1, 1))
  end

  it 'converts plain dates by day, also from the Julian calendar' do
    julian = Date.new(1500, 1, 1)
    expect(EDTF(julian).edtf).to eq('1500-01-10')
    expect(EDTF(julian).jd).to eq(julian.jd)
  end

  it 'rejects times with offsets in seconds' do
    expect { EDTF(Time.new(1900, 1, 1, 0, 0, 0, '+00:53:28')) }.to raise_error(ArgumentError, /whole minutes/)
  end

  it 'is private' do
    expect { 'x'.EDTF('2004') }.to raise_error(NoMethodError)
  end
end
