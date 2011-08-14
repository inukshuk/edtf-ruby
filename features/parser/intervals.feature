Feature: EDTF parses ISO 8601 interval strings
	As a user of edtf-ruby
	I want to parse ISO 8601 interval strings
	
	Scenario Outline: parse intervals
		When I parse the string "<string>"
		Then the interval should start at "<from>"
		And the interval should end at "<to>"
	
	@004 @level0
	Scenarios: specification intervals
		| string                | from       | to         |
		| 1964/2008             | 1964-01-01 | 2008-01-01 |
		| 2004-06/2006-08       | 2004-06-01 | 2006-08-01 |
		| 2004-01-01/2004-01-02 | 2004-01-01 | 2004-01-02 |
		| 2004-02-01/2005-02-08 | 2004-02-01 | 2005-02-08 |
		| 2004-02-01/2005-02    | 2004-02-01 | 2005-02-01 |
		| 2004-02-01/2005       | 2004-02-01 | 2005-01-01 |
		| 2005/2006-02          | 2005-01-01 | 2006-02-01 |
