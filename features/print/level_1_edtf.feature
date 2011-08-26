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
