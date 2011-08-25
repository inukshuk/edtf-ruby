Feature: Print Date/Time objects as Level 2 EDTF strings
  As a Ruby programmer
  I want to convert Date/Time objects to EDTF strings
  
  @101 @level1
	Scenario: Uncertain or approximate dates
		When I parse the string "2001?"
		When I convert the date
		Then the EDTF string should be "2001?"
		When I parse the string "2004-06?"
		When I convert the date
		Then the EDTF string should be "2004-06?"
		When I parse the string "2004-06-11?"
		When I convert the date
		Then the EDTF string should be "2004-06-11?"