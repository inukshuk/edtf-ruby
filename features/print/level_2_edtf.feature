Feature: Print Date/Time objects as Level 2 EDTF strings
  As a Ruby programmer
  I want to convert Date/Time objects to EDTF strings
  
  @202 @level2
	Scenario: Prints internal unspecified dates
		When I parse the string "156u-12-25"
		When I convert the date
		Then the EDTF string should be "156u-12-25"
