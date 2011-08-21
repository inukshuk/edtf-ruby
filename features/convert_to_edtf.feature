Feature: Convert Date/Time objects to EDTF strings
  As a Ruby programmer
  I want to convert Date/Time objects to EDTF strings
  
  Scenario: Convert simple dates
    Given the date "2004-08-12"
    When I convert the date
    Then the EDTF string should be "2004-08-12"

	Scenario: Convert simple dates with precision
		Given the date "1980-08-24" with precision set to "month"
		When I convert the date
		Then the EDTF string should be "1980-08"
	