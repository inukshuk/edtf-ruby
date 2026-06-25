Given('the date {string}') do |date|
  @date = Date.parse(date)
end

Given('the date {string} with precision set to {string}') do |date, precision|
  @date = Date.parse(date)
  @date.precision = precision
end

When('I convert the date') do
  @string = @date.edtf
end

Then('the EDTF string should be {string}') do |edtf|
  expect(@string).to eq(edtf)
end

When('I parse the string {string}') do |string|
  @date = EDTF.parse!(string)
end

Then('the year should be {string}') do |year|
  expect(@date.year).to eq(year.to_i)
end

Then('the month should be {string}') do |month|
  expect(@date.month).to eq(month.to_i)
end

Then('the day should be {string}') do |day|
  expect(@date.day).to eq(day.to_i)
end

Then('the hours should be {string}') do |hours|
  expect(@date.hour).to eq(hours.to_i)
end

Then('the year should be {string} \(UTC)') do |year|
  expect(@date.to_time.utc.year).to eq(year.to_i)
end

Then('the month should be {string} \(UTC)') do |month|
  expect(@date.to_time.utc.month).to eq(month.to_i)
end

Then('the day should be {string} \(UTC)') do |day|
  expect(@date.to_time.utc.day).to eq(day.to_i)
end

Then('the hours should be {string} \(UTC)') do |hours|
  expect(@date.to_time.utc.hour).to eq(hours.to_i)
end

Then('the minutes should be {string}') do |minutes|
  expect(@date.min).to eq(minutes.to_i)
end

Then('the seconds should be {string}') do |seconds|
  expect(@date.sec).to eq(seconds.to_i)
end

Then('the duration should range from {string} to {string}') do |from, to|
  expect([@date.begin.year.to_s, @date.end.year.to_s]).to eq([from, to])
end

Then('the interval should start at {string}') do |date|
  expect(@date.begin.to_s).to eq(date)
end

Then('the interval should end at {string}') do |date|
  expect(@date.end.to_s).to eq(date)
end

Then('the interval should include the date {string}') do |date|
  expect(@date).to include(Date.parse(date))
end

Then('the interval should cover the date {string}') do |date|
  expect(@date).to be_cover(Date.parse(date))
end

Then('the date should be uncertain? {string}') do |answer|
  expect(@date.uncertain?).to eq(!!(answer =~ /y(es)?/i))
end

Then('the year should be uncertain? {string}') do |answer|
  expect(@date.uncertain?(:year)).to eq(!!(answer =~ /y(es)?/i))
end

Then('the month should be uncertain? {string}') do |answer|
  expect(@date.uncertain?(:month)).to eq(!!(answer =~ /y(es)?/i))
end

Then('the day should be uncertain? {string}') do |answer|
  expect(@date.uncertain?(:day)).to eq(!!(answer =~ /y(es)?/i))
end

Then('the date should be approximate? {string}') do |answer|
  expect(@date.approximate?).to eq(!!(answer =~ /y(es)?/i))
end

Then('the year should be approximate? {string}') do |answer|
  expect(@date.approximate?(:year)).to eq(!!(answer =~ /y(es)?/i))
end

Then('the month should be approximate? {string}') do |answer|
  expect(@date.approximate?(:month)).to eq(!!(answer =~ /y(es)?/i))
end

Then('the day should be approximate? {string}') do |answer|
  expect(@date.approximate?(:day)).to eq(!!(answer =~ /y(es)?/i))
end

Then('the result should be an Unknown') do
  expect(@date).to be_an(EDTF::Unknown)
end

Then('the unspecified string code be {string}') do |code|
  expect(@date.unspecified.to_s).to eq(code)
end

When('I parse the following strings an error should be raised:') do |table|
  table.raw.each do |row|
    expect { Date.edtf!(row[0]) }.to raise_error(ArgumentError)
  end
end

When('the year is uncertain: {string}') do |answer|
  @date.uncertain!(:year) if answer =~ /y(es)?/i
end

When('the month is uncertain: {string}') do |answer|
  @date.uncertain!(:month) if answer =~ /y(es)?/i
end

When('the day is uncertain: {string}') do |answer|
  @date.uncertain!(:day) if answer =~ /y(es)?/i
end

When('the year is approximate: {string}') do |answer|
  @date.approximate!(:year) if answer =~ /y(es)?/i
end

When('the month is approximate: {string}') do |answer|
  @date.approximate!(:month) if answer =~ /y(es)?/i
end

When('the day is approximate {string}') do |answer|
  @date.approximate!(:day) if answer =~ /y(es)?/i
end
