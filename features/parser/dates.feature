Feature: EDTF parser parses date strings

	In order to use dates in EDTF
	As a user of edtf-ruby
	I want to parse date strings formatted in EDTF

	Scenario Outline: EDTF parses a date string
		When I parse the string "<string>"
		Then the year should be "<year>"
		And the month should be "<month>"
		And the day should be "<day>"

	@date @basic_features
	Scenarios: simple dates
		| string     | year | month | day |
		| 2001-02-03 | 2001 | 2     | 3   |
		| 2008-12    | 2008 | 12    | 1   |
		| 2008       | 2008 | 1     | 1   |
		| -0999      | -999 | 1     | 1   |
		| 0000       | 0    | 1     | 1   |


	Scenario Outline: EDTF parses uncertain date strings
		When I parse the string "<string>"
		Then the year should be "<year>"
		And the year should be uncertain? "<uncertain-year>"
		And the month should be "<month>"
		And the month should be uncertain? "<uncertain-month>"
		And the day should be "<day>"
		And the day should be uncertain? "<uncertain-day>"

	@date @extended_features
	Scenarios: uncertain dates
		| string     | year | uncertain-year | month | uncertain-month | day | uncertain-day |
		| 1992?      | 1992 | yes            | 1     | no              | 1   | no            |