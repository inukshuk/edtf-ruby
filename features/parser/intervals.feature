Feature: EDTF parses ISO 8601 interval strings
	As a user of edtf-ruby
	I want to parse ISO 8601 interval strings

	Scenario Outline: parse intervals
		When I parse the string "<string>"
		Then the interval should cover the date "<date>"

	@004 @level0
	Scenarios: specification intervals
		| string                | date       |
		| 1964/2008             | 1964-01-01 |
		| 2004-06/2006-08       | 2006-08-31 |
		| 2004-01-01/2004-01-02 | 2004-01-01 |
		| 2004-02-01/2005-02-08 | 2005-02-08 |
		| 2004-02-01/2005-02    | 2004-12-01 |
		| 2004-02-01/2005       | 2005-12-31 |
		| 2005/2006-02          | 2005-01-01 |
