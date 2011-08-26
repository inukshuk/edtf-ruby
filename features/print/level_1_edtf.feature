Feature: Print Date/Time objects as Level 1 EDTF strings
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
		
		When I parse the string "1984~"
		When I convert the date
		Then the EDTF string should be "1984~"

		When I parse the string "1984?~"
		When I convert the date
		Then the EDTF string should be "1984?~"
		
	@102 @level1
	Scenario: Unspecified dates
		When I parse the string "199u"
		When I convert the date
		Then the EDTF string should be "199u"

		When I parse the string "19uu"
		When I convert the date
		Then the EDTF string should be "19uu"

		When I parse the string "1999-uu"
		When I convert the date
		Then the EDTF string should be "1999-uu"

		When I parse the string "1999-01-uu"
		When I convert the date
		Then the EDTF string should be "1999-01-uu"

		When I parse the string "1999-uu-uu"
		When I convert the date
		Then the EDTF string should be "1999-uu-uu"

	@103 @level1 @interval
	Scenario: Prints L1 Extended Intervals
		When I parse the string "unknown/2006"
		When I convert the date
		Then the EDTF string should be "unknown/2006"

		When I parse the string "2004-06-01/unknown"
		When I convert the date
		Then the EDTF string should be "2004-06-01/unknown"

		When I parse the string "2004-01-01/open"
		When I convert the date
		Then the EDTF string should be "2004-01-01/open"

		When I parse the string "1984~/2004-06"
		When I convert the date
		Then the EDTF string should be "1984~/2004-06"

		When I parse the string "1984/2004-06~"
		When I convert the date
		Then the EDTF string should be "1984/2004-06~"

		When I parse the string "1984~/2004~"
		When I convert the date
		Then the EDTF string should be "1984~/2004~"

		When I parse the string "1984?/2004?~"
		When I convert the date
		Then the EDTF string should be "1984?/2004?~"

		When I parse the string "1984-06?/2004-08?"
		When I convert the date
		Then the EDTF string should be "1984-06?/2004-08?"

		When I parse the string "1984-06-02?/2004-08-08~"
		When I convert the date
		Then the EDTF string should be "1984-06-02?/2004-08-08~"

		When I parse the string "1984-06-02?/unknown"
		When I convert the date
		Then the EDTF string should be "1984-06-02?/unknown"

	@104 @level1
	Scenario: Prints years with more than four digits
		When I parse the string "y170000002"
		When I convert the date
		Then the EDTF string should be "y170000002"

		When I parse the string "y-170000002"
		When I convert the date
		Then the EDTF string should be "y-170000002"

	@105 @level1 @season
	Scenario: Prints seasons
		When I parse the string "2001-21"
		When I convert the date
		Then the EDTF string should be "2001-21"
		