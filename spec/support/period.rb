# The interface every EDTF type implements. Include it with
#   it_behaves_like 'a period' do
#     let(:period) { ... }
#   end
# Pass parses: false for syntax the grammar doesn't read yet.
shared_examples 'a period' do |parses: true|
  it 'is frozen' do
    expect(period).to be_frozen
  end

  it 'has plain dates as bounds' do
    [period.begin, period.end].compact.each do |bound|
      expect(bound).to be_instance_of(::Date)
    end
  end

  it 'begins no later than it ends' do
    expect(period.begin).to be <= period.end if period.begin && period.end
  end

  it 'covers its bounds' do
    [period.begin, period.end].compact.each do |bound|
      expect(period).to be_cover(bound)
    end
  end

  it 'has the nominal bounds as earliest and latest' do
    expect([period.earliest, period.latest]).to eq([period.begin, period.end])
  end

  it 'converts to a range of its bounds' do
    expect(period.to_range).to eq(period.begin..period.end)
  end

  it 'has a precision' do
    expect(EDTF::Period::PRECISIONS).to include(period.precision)
  end

  it 'round-trips through its EDTF string' do
    pending 'the grammar reads it from step 4' unless parses
    expect(EDTF.parse(period.edtf)).to eql(period)
  end

  it 'equals itself' do
    expect(period <=> period).to eq(0)
  end
end
