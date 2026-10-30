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
