Given /^the date "([^"]*)"(?: with precision set to "([^"]*)")?$/ do |date, precision|
  @date = Date.parse(date)
	@date.precision = precision unless precision.nil?
end

When /^I convert the date$/ do
  @string = @date.edtf
end

Then /^the EDTF String should be "([^"]*)"$/i do |edtf|
  expect(@string).to eq(edtf)
end

When /^I parse the string "([^"]*)"$/ do |string|
  @date = EDTF.parse!(string)
end

Then /^the year should be "([^"]*)"$/ do |year|
  expect(@date.year).to eq(year.to_i)
end

Then /^the month should be "([^"]*)"$/ do |month|
  expect(@date.month).to eq(month.to_i)
end

Then /^the day should be "([^"]*)"$/ do |day|
  expect(@date.day).to eq(day.to_i)
end

Then /^the hours should be "([^"]*)"$/ do |hours|
  expect(@date.hour).to eq(hours.to_i)
end

Then /^the year should be "([^"]*)" UTC$/ do |year|
  expect(@date.to_time.utc.year).to eq(year.to_i)
end

Then /^the month should be "([^"]*)" UTC$/ do |month|
  expect(@date.to_time.utc.month).to eq(month.to_i)
end

Then /^the day should be "([^"]*)" UTC$/ do |day|
  expect(@date.to_time.utc.day).to eq(day.to_i)
end

Then /^the hours should be "([^"]*)" UTC$/ do |hours|
  expect(@date.to_time.utc.hour).to eq(hours.to_i)
end


Then /^the minutes should be "([^"]*)"$/ do |minutes|
  expect(@date.min).to eq(minutes.to_i)
end

Then /^the seconds should be "([^"]*)"$/ do |seconds|
  expect(@date.sec).to eq(seconds.to_i)
end

Then /^the duration should range from "([^"]*)" to "([^"]*)"$/ do |from,to|
  expect([@date.begin.year.to_s, @date.end.year.to_s]).to eq([from,to])
end

Then /^the interval should start at "([^"]*)"$/ do |date|
  expect(@date.begin.to_s).to eq(date)
end

Then /^the interval should end at "([^"]*)"$/ do |date|
  expect(@date.end.to_s).to eq(date)
end

Then /^the interval should include the date "([^"]*)"$/ do |date|
  expect(@date).to include(Date.parse(date))
end

Then /^the interval should cover the date "([^"]*)"$/ do |date|
  expect(@date).to be_cover(Date.parse(date))
end


Then /^the date should be uncertain\? "([^"]*)"$/ do |arg1|
  expect(@date.uncertain?).to eq(!!(arg1 =~ /y(es)?/i))
end

Then /^the year should be uncertain\? "([^"]*)"$/ do |arg1|
  expect(@date.uncertain?(:year)).to eq(!!(arg1 =~ /y(es)?/i))
end

Then /^the month should be uncertain\? "([^"]*)"$/ do |arg1|
  expect(@date.uncertain?(:month)).to eq(!!(arg1 =~ /y(es)?/i))
end

Then /^the day should be uncertain\? "([^"]*)"$/ do |arg1|
  expect(@date.uncertain?(:day)).to eq(!!(arg1 =~ /y(es)?/i))
end

Then /^the date should be approximate\? "([^"]*)"$/ do |arg1|
  expect(@date.approximate?).to eq(!!(arg1 =~ /y(es)?/i))
end

Then /^the year should be approximate\? "([^"]*)"$/ do |arg1|
  expect(@date.approximate?(:year)).to eq(!!(arg1 =~ /y(es)?/i))
end

Then /^the month should be approximate\? "([^"]*)"$/ do |arg1|
  expect(@date.approximate?(:month)).to eq(!!(arg1 =~ /y(es)?/i))
end

Then /^the day should be approximate\? "([^"]*)"$/ do |arg1|
  expect(@date.approximate?(:day)).to eq(!!(arg1 =~ /y(es)?/i))
end

Then /^the result should be an Unknown$/ do
  expect(@date).to be_an(EDTF::Unknown)
end

Then /^the unspecified string code be "([^"]*)"$/ do |arg1|
  expect(@date.unspecified.to_s).to eq(arg1)
end

When /^I parse the following strings an error should be raised:$/ do |table|
	table.raw.each do |row|
		expect { Date.edtf!(row[0]) }.to raise_error(ArgumentError)
	end
end

When /^the year is uncertain: "([^"]*)"$/ do |arg1|
	@date.uncertain!(:year) if arg1 =~ /y(es)?/i
end

When /^the month is uncertain: "([^"]*)"$/ do |arg1|
	@date.uncertain!(:month) if arg1 =~ /y(es)?/i
end

When /^the day is uncertain: "([^"]*)"$/ do |arg1|
	@date.uncertain!(:day) if arg1 =~ /y(es)?/i
end

When /^the year is approximate: "([^"]*)"$/ do |arg1|
	@date.approximate!(:year) if arg1 =~ /y(es)?/i
end

When /^the month is approximate: "([^"]*)"$/ do |arg1|
	@date.approximate!(:month) if arg1 =~ /y(es)?/i
end

When /^the day is approximate "([^"]*)"$/ do |arg1|
	@date.approximate!(:day) if arg1 =~ /y(es)?/i
end
