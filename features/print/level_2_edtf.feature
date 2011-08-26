Feature: Print Date/Time objects as Level 2 EDTF strings
  As a Ruby programmer
  I want to convert Date/Time objects to EDTF strings
  
  @202 @level2
	Scenario: Prints internal unspecified dates
		When I parse the string "156u-12-25"
		When I convert the date
		Then the EDTF string should be "156u-12-25"

  @205 @level2 @interval
	Scenario: Prints L2 extended intervals
		# When I parse the string "2004-06-(01)~/2004-06-(20)~"
		# When I convert the date
		# Then the EDTF string should be "2004-06-(01)~/2004-06-(20)~"

		When I parse the string "2004-06-uu/2004-07-03"
		When I convert the date
		Then the EDTF string should be "2004-06-uu/2004-07-03"

  @209 @level2 @season
	Scenario: Prints qualified seasons
		When I parse the string "2001-21^southernHemisphere"
		When I convert the date
		Then the EDTF string should be "2001-21^southernHemisphere"

  @207 @level2 @calendar
	Scenario: Prints calendar string
		When I parse the string "2001-02-03^xyz"
		When I convert the date
		Then the EDTF string should be "2001-02-03^xyz"
