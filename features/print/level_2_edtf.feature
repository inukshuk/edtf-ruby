Feature: Print Date/Time objects as Level 2 EDTF strings
  As a Ruby programmer
  I want to convert Date/Time objects to EDTF strings
  
	Scenario: Uncertain or approximate dates
		When I parse the string "2001?"
		When I convert the date
		Then the EDTF string should be "2001?"
