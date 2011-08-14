Feature: EDTF parses date/time strings

	As a user of edtf-ruby
	I want to parse date/time strings formatted in EDTF
	
	Scenario Outline: EDTF parses a date/time string
		When I parse the string "<string>"
		Then the year should be "<year>"
		And the month should be "<month>"
		And the day should be "<day>"
		And the hours should be "<hours>"
		And the minutes should be "<minutes>"
		And the seconds should be "<seconds>"

		@002 @level0
		Scenarios: simple dates
			| string               | year | month | day | hours | minutes | seconds |
			| 2001-02-03T09:30:01  | 2001 | 2     | 3   | 9     | 30      | 1       |


	Scenario Outline: EDTF parses a date/time string with timezone indicator
		When I parse the string "<string>"
		Then the year should be "<year>" (UTC)
		And the month should be "<month>" (UTC)
		And the day should be "<day>" (UTC)
		And the hours should be "<hours>" (UTC)
		And the minutes should be "<minutes>"
		And the seconds should be "<seconds>"

		@002 @level0
		Scenarios: date/times with timezone
			| string                    | year | month | day | hours | minutes | seconds |
			| 2004-01-01T10:10:10Z      | 2004 | 1     | 1   | 10    | 10      | 10      |
			| 2004-01-01T10:10:10+05:00 | 2004 | 1     | 1   | 5     | 10      | 10      |
			| 2004-01-01T02:10:10+05:00 | 2003 | 12    | 31  | 21    | 10      | 10      |