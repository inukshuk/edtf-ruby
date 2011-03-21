Feature: EDTF parser parses date strings

	In order to use dates in EDTF
	As a user of edtf-ruby
	I want to parse date strings formatted in EDTF

	Scenario Outline: EDTF parses a date string
		When I parse the date string "<string>"
		Then the year should be "<year>"
		And the month should be "<month>"

	@date @basic_features
	Scenarios: simple dates (with hyphen)
		| string     | year | month | day |
		| 2001-02-03 | 2001 | 2     | 3   |
		| 2008-12    | 2008 | 12    | 1   |
		| 2008       | 2008 | 1     | 1   |
		| -0999      | -999 | 1     | 1   |
