Given /^the date "([^"]*)"(?: with precision set to "([^"]*)")?$/ do |date, precision|
  @date = Date.parse(date)
	@date.precision = precision unless precision.nil?
end

When /^I convert the date$/ do
  @string = @date.edtf
end

Then /^the EDTF String should be "([^"]*)"$/i do |edtf|
  @string.should == edtf
end

When /^I parse the string "([^"]*)"$/ do |string|
  @date = EDTF.parse(string)
end

Then /^the year should be "([^"]*)"$/ do |year|
  @date.year.should == year.to_i
end

Then /^the month should be "([^"]*)"$/ do |month|
  @date.month.should == month.to_i
end

Then /^the day should be "([^"]*)"$/ do |day|
  @date.day.should == day.to_i
end

Then /^the hours should be "([^"]*)"$/ do |hours|
  @date.hour.should == hours.to_i
end

Then /^the year should be "([^"]*)" \(UTC\)$/ do |year|
  @date.to_time.utc.year.should == year.to_i
end

Then /^the month should be "([^"]*)" \(UTC\)$/ do |month|
  @date.to_time.utc.month.should == month.to_i
end

Then /^the day should be "([^"]*)" \(UTC\)$/ do |day|
  @date.to_time.utc.day.should == day.to_i
end

Then /^the hours should be "([^"]*)" \(UTC\)$/ do |hours|
  @date.to_time.utc.hour.should == hours.to_i
end


Then /^the minutes should be "([^"]*)"$/ do |minutes|
  @date.min.should == minutes.to_i
end

Then /^the seconds should be "([^"]*)"$/ do |seconds|
  @date.sec.should == seconds.to_i
end

Then /^the duration should range from "([^"]*)" to "([^"]*)"$/ do |from,to|
  [@date.begin.year.to_s, @date.end.year.to_s].should == [from,to]
end

Then /^the interval should start at "([^"]*)"$/ do |date|
  @date.begin.to_s.should == date
end

Then /^the interval should end at "([^"]*)"$/ do |date|
  @date.end.to_s.should == date
end

Then /^the interval should include the date "([^"]*)"$/ do |date|
  @date.should include(Date.parse(date))
end

Then /^the interval should cover the date "([^"]*)"$/ do |date|
  @date.should cover(Date.parse(date))
end


Then /^the date should be uncertain\? "([^"]*)"$/ do |arg1|
  @date.uncertain?.should == !!(arg1 =~ /y(es)?/i)
end

Then /^the year should be uncertain\? "([^"]*)"$/ do |arg1|
  @date.uncertain?(:year).should == !!(arg1 =~ /y(es)?/i)
end

Then /^the month should be uncertain\? "([^"]*)"$/ do |arg1|
  @date.uncertain?(:month).should == !!(arg1 =~ /y(es)?/i)
end

Then /^the day should be uncertain\? "([^"]*)"$/ do |arg1|
  @date.uncertain?(:day).should == !!(arg1 =~ /y(es)?/i)
end

Then /^the date should be approximate\? "([^"]*)"$/ do |arg1|
  @date.approximate?.should == !!(arg1 =~ /y(es)?/i)
end

Then /^the year should be approximate\? "([^"]*)"$/ do |arg1|
  @date.approximate?(:year).should == !!(arg1 =~ /y(es)?/i)
end

Then /^the month should be approximate\? "([^"]*)"$/ do |arg1|
  @date.approximate?(:month).should == !!(arg1 =~ /y(es)?/i)
end

Then /^the day should be approximate\? "([^"]*)"$/ do |arg1|
  @date.approximate?(:day).should == !!(arg1 =~ /y(es)?/i)
end


Then /^the unspecified string code be "([^"]*)"$/ do |arg1|
  @date.unspecified.to_s.should == arg1
end

When /^I parse the following strings an error should be raised:$/ do |table|
	table.raw.each do |row|
		expect { Date.edtf(row[0]) }.to raise_error(ArgumentError)
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
