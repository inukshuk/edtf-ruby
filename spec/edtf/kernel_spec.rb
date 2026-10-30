describe 'EDTF()' do
  it 'parses strings' do
    expect(EDTF('2004-06?')).to eql(EDTF.parse('2004-06?'))
  end

  it 'raises an ArgumentError for invalid strings' do
    expect { EDTF('xyz') }.to raise_error(ArgumentError)
  end

  it 'converts times to date-times' do
    time = Time.utc(2004, 6, 11, 10, 30)
    expect(EDTF(time)).to be_a(DateTime)
    expect(EDTF(time).to_time).to eq(time)
  end

  it 'returns dates unchanged' do
    date = Date.new(2004, 6, 11)
    expect(EDTF(date)).to equal(date)
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
