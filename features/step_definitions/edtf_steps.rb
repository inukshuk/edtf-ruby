When /^I parse the string "([^"]*)"$/ do |string|
  @edtf = EDTF.parse(string)
end

Then /^the year should be "([^"]*)"$/ do |year|
  @edtf.year.should == year.to_i
end

Then /^the month should be "([^"]*)"$/ do |month|
  @edtf.month.should == month.to_i
end

Then /^the day should be "([^"]*)"$/ do |day|
  @edtf.day.should == day.to_i
end

Then /^the hours should be "([^"]*)"$/ do |hours|
  @edtf.hour.should == hours.to_i
end

Then /^the year should be "([^"]*)" \(UTC\)$/ do |year|
  @edtf.to_time.utc.year.should == year.to_i
end

Then /^the month should be "([^"]*)" \(UTC\)$/ do |month|
  @edtf.to_time.utc.month.should == month.to_i
end

Then /^the day should be "([^"]*)" \(UTC\)$/ do |day|
  @edtf.to_time.utc.day.should == day.to_i
end

Then /^the hours should be "([^"]*)" \(UTC\)$/ do |hours|
  @edtf.to_time.utc.hour.should == hours.to_i
end


Then /^the minutes should be "([^"]*)"$/ do |minutes|
  @edtf.min.should == minutes.to_i
end

Then /^the seconds should be "([^"]*)"$/ do |seconds|
  @edtf.sec.should == seconds.to_i
end

Then /^the duration should range from "([^"]*)" to "([^"]*)"$/ do |*expected|
  [@edtf.begin.year.to_s, @edtf.end.year.to_s].should == expected
end

Then /^the interval should start at "([^"]*)"$/ do |date|
  @edtf.begin.to_s.should == date
end

Then /^the interval should end at "([^"]*)"$/ do |date|
  @edtf.end.to_s.should == date
end

Then /^the date should be uncertain\? "([^"]*)"$/ do |arg1|
  @edtf.uncertain?.should == !!(arg1 =~ /y(es)?/i)
end

Then /^the year should be uncertain\? "([^"]*)"$/ do |arg1|
  @edtf.uncertain?(:year).should == !!(arg1 =~ /y(es)?/i)
end

Then /^the month should be uncertain\? "([^"]*)"$/ do |arg1|
  @edtf.uncertain?(:month).should == !!(arg1 =~ /y(es)?/i)
end

Then /^the day should be uncertain\? "([^"]*)"$/ do |arg1|
  @edtf.uncertain?(:day).should == !!(arg1 =~ /y(es)?/i)
end

Then /^the date should be approximate\? "([^"]*)"$/ do |arg1|
  @edtf.approximate?.should == !!(arg1 =~ /y(es)?/i)
end

Then /^the unspecified string code be "([^"]*)"$/ do |arg1|
  @edtf.unspecified.to_s.should == arg1
end
