When /^I parse the date(?:\/time)? string "([^"]*)"$/ do |string|
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