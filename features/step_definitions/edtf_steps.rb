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

  def qualified_parts(predicate, date = @result)
    PARTS.select { |part| date.public_send(predicate, part) }
  end

  # The unspecified digits as a mask like "YYYX-MM-DD". 4.x dates
  # (still used as interval and set members) mark them as "sssX-ss-ss".
  def unspecified_mask(date)
    mask = date.unspecified.to_s
    return mask if date.is_a?(EDTF::Date)

    mask.chars.zip('YYYY-MM-DD'.chars).map { |c, m| c == 'X' ? c : m }.join
  end

  # Compares 4.x and 5.0 dates by values, qualifiers and unspecified digits.
  def describe(date)
    [date.values, qualified_parts(:uncertain?, date), qualified_parts(:approximate?, date), unspecified_mask(date)]
  end

  # "open" and "unknown" are interval ends without a date.
  def expect_endpoint(actual, expected)
    if %w[open unknown].include?(expected)
      expect(actual).to eq(expected.to_sym)
    else
      expect(describe(actual)).to eq(describe(parse(expected)))
    end
  end

  def yes?(answer)
    answer == 'yes'
  end
end

World(EDTFHelpers)

# Input in @legacy examples must be recognized as legacy syntax,
# all other input must not.
Before do |scenario|
  @legacy = scenario.source_tag_names.include?('@legacy')
end

Given('the date {string}') do |date|
  @result = EDTF::Date.new(*values(date))
end

Given('the date {string} with {word} precision') do |date, precision|
  @result = EDTF::Date.new(*values(date)).with(precision: precision)
end

When('the uncertain parts are {string}') do |list|
  @result = @result.with(uncertain: parts(list))
end

When('the approximate parts are {string}') do |list|
  @result = @result.with(approximate: parts(list))
end

When('I parse {string}') do |string|
  @result = parse(string)
  expect(EDTF.legacy?(string)).to eq(@legacy)
end

Then('it should be the date {string}') do |date|
  expect(@result.values).to eq(values(date))
end

# Fractional seconds are compared only when expected, e.g. "...T16:54:59.042".
Then('it should be the date-time {string}') do |date_time|
  format = date_time.include?('.') ? '%FT%T.%L' : '%FT%T'
  expect(@result.strftime(format)).to eq(date_time)
end

Then('in UTC it should be {string}') do |date_time|
  expect(@result.getutc.strftime('%FT%T')).to eq(date_time)
end

Then('the uncertain parts should be {string}') do |list|
  expect(qualified_parts(:uncertain?)).to eq(parts(list))
end

Then('the approximate parts should be {string}') do |list|
  expect(qualified_parts(:approximate?)).to eq(parts(list))
end

# The mask marks unspecified digits with X, e.g. "YYYX-MM-DD".
Then('the unspecified digits should be {string}') do |mask|
  expect(unspecified_mask(@result)).to eq(mask)
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

Then('the start should be {string}') do |date|
  expect_endpoint(@result.from, date)
end

Then('the end should be {string}') do |date|
  expect_endpoint(@result.to, date)
end

Then('it should be the season {string}') do |season|
  expect(@result.values).to eq(season.match(/\A(-?\d+)-(\d\d)\z/).captures.map(&:to_i))
end

Then('it should be uncertain: {word}') do |answer|
  expect(@result.uncertain?).to eq(yes?(answer))
end

Then('it should be approximate: {word}') do |answer|
  expect(@result.approximate?).to eq(yes?(answer))
end

Then('the season qualifier should be {string}') do |qualifier|
  expect(@result.qualifier).to eq(qualifier)
end

Then('the calendar should be {string}') do |calendar|
  expect(@result.calendar).to eq(calendar)
end

# "one of" is a choice; "all of" includes every member.
Then('it should be {string} the members {string}') do |kind, members|
  expect(@result).to be_an(kind == 'one of' ? EDTF::Set : EDTF::List)
  expected = members.split(/,\s*/)
  expect(@result.to_a.length).to eq(expected.length)
  @result.to_a.zip(expected).each { |actual, member| expect(describe(actual)).to eq(describe(parse(member))) }
end

Then('the open end should be {string}') do |open|
  expect([@result.earlier?, @result.later?]).to eq([open == 'earlier', open == 'later'])
end

Then('the significant digits should be {int}') do |digits|
  expect(@result.significant).to eq(digits)
end
