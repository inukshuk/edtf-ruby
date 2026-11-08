describe 'EDTF.legacy?' do
  it 'is true for valid input using legacy syntax' do
    expect(EDTF.legacy?('1984?~')).to be true
  end

  it 'is false for ISO 8601-2 input' do
    expect(EDTF.legacy?('1984%')).to be false
  end

  it 'is false for invalid input' do
    expect(EDTF.legacy?('1984?~x')).to be false
  end

  it 'does not emit deprecation warnings' do
    original = Warning[:deprecated]
    Warning[:deprecated] = true
    expect { EDTF.legacy?('1984?~') }.not_to output.to_stderr
  ensure
    Warning[:deprecated] = original
  end
end

describe 'Migrating legacy strings with EDTF(string).edtf' do
  {
    '1984?~' => '1984%',
    '2004-(06)?-11' => '2004-?06-11',
    '2004/open' => '2004/..',
    'unknown/2004' => '/2004',
    '199u' => '199X',
    '19xx' => '19XX',
    '196x' => '196X',
    'y17e7' => 'Y170000000',
    '-0000' => '0000',
    '{1960, 1961-12}' => '{1960,1961-12}',
    '2001-21^southern' => '2001-29',
    '2016-05-02T24:00:00' => '2016-05-03T00:00:00',
    '2004T10:10:10' => '2004-01-01T10:10:10'
  }.each do |legacy, iso|
    it "writes #{legacy} as #{iso}" do
      expect(EDTF(legacy).edtf).to eq(iso)
      expect(EDTF.parse(iso, legacy: false)).to eql(EDTF(legacy))
    end
  end

  it 'keeps calendars, which ISO 8601-2 strings do not name' do
    expect(EDTF('1500-02-29^julian').edtf).to eq('1500-02-29')
    expect(EDTF('1500-02-29^julian')).to eql(EDTF.parse('1500-02-29', calendar: :julian))
  end

  it 'raises for reversed intervals' do
    expect { EDTF('2008/2004') }.to raise_error(ArgumentError, /reversed/)
  end
end
