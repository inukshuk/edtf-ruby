# Features describe parse results in terms of values,
# qualified parts, unspecified digits and bounds.
module EDTFHelpers
  PARTS = %i[year month day].freeze

  def parse(string)
    EDTF.parse!(string)
  end

  # "2004-06" -> [2004, 6]; "-0999" -> [-999]
  def values(date)
    date.match(/\A(-?\d+)(?:-(\d\d))?(?:-(\d\d))?\z/).captures.compact.map(&:to_i)
  end

  # "year, month" -> [:year, :month]; "none" -> []
  def parts(list)
    list == 'none' ? [] : list.split(/,\s*/).map(&:to_sym)
  end

  def qualified_parts(predicate)
    PARTS.select { |part| @result.public_send(predicate, part) }
  end
end

World(EDTFHelpers)

Given('the date {string}') do |date|
  v = values(date)
  @result = Date.new(*v)
  @result.precision = EDTFHelpers::PARTS[v.length - 1]
end

Given('the date {string} with {word} precision') do |date, precision|
  @result = Date.parse(date)
  @result.precision = precision
end

When('the uncertain parts are {string}') do |list|
  parts(list).each { |part| @result.uncertain!(part) }
end

When('the approximate parts are {string}') do |list|
  parts(list).each { |part| @result.approximate!(part) }
end

When('I parse {string}') do |string|
  @result = parse(string)
end

Then('it should be the date {string}') do |date|
  expect(@result.values).to eq(values(date))
end

Then('it should be the date-time {string}') do |date_time|
  expect(@result.strftime('%FT%T')).to eq(date_time)
end

Then('in UTC it should be {string}') do |date_time|
  expect(@result.to_time.utc.strftime('%FT%T')).to eq(date_time)
end

Then('the uncertain parts should be {string}') do |list|
  expect(qualified_parts(:uncertain?)).to eq(parts(list))
end

Then('the approximate parts should be {string}') do |list|
  expect(qualified_parts(:approximate?)).to eq(parts(list))
end

# The mask marks unspecified digits with X, e.g. "YYYX-MM-DD".
Then('the unspecified digits should be {string}') do |mask|
  expect(@result.unspecified.to_s).to eq(mask.tr('YMD', 's'))
end

Then('it should be unknown') do
  expect(@result).to be_an(EDTF::Unknown)
end

Then('it should cover {string}') do |date|
  expect(@result).to be_cover(Date.parse(date))
end

Then('it should span {string} to {string}') do |from, to|
  expect([@result.begin, @result.end].map(&:iso8601)).to eq([from, to])
end

Then('the following strings should be rejected:') do |table|
  table.raw.flatten.each do |string|
    expect { parse(string) }.to raise_error(ArgumentError)
  end
end

Then('its EDTF string should be {string}') do |edtf|
  expect(@result.edtf).to eq(edtf)
end
