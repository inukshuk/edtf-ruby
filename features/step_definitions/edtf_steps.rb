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

Then /^the century should be "([^"]*)"$/ do |century|
  @date.century.should == century.to_i
end

Then /^the duration should last "([^"]*)" (\w+)$/ do |value, part|
  @date.send(part).should == value.to_i
end

Then /^the interval should start at "([^"]*)"$/ do |date|
  @date.begin.to_s.should == date
end

Then /^the interval should end at "([^"]*)"$/ do |date|
  @date.end.to_s.should == date
end