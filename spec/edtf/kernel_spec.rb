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

  [nil, 2004, :year].each do |value|
    it "raises a TypeError for #{value.inspect}" do
      expect { EDTF(value) }.to raise_error(TypeError)
    end
  end

  it 'is private' do
    expect { 'x'.EDTF('2004') }.to raise_error(NoMethodError)
  end
end
