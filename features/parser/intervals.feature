Feature: EDTF parses ISO 8601 interval strings
	As a user of edtf-ruby
	I want to parse ISO 8601 interval strings
	
	Scenario Outline: parse intervals
		When I parse the string "<string>"
		Then the interval should start at "<from>"
		And the interval should end at "<to>"
	
	@interval @standard_features
	Scenarios: intervals
		| string                | from                      | to                        |
		| 1964/2008             | 1964-01-01T00:00:00+00:00 | 2008-01-01T00:00:00+00:00 |
		| 2004-06/2006-08       | 2004-06-01T00:00:00+00:00 | 2006-08-01T00:00:00+00:00 |
		| 2004-01-01/2004-01-02 | 2004-01-01T00:00:00+00:00 | 2004-01-02T00:00:00+00:00 |
		| 2004-02-01/2005-02-08 | 2004-02-01T00:00:00+00:00 | 2005-02-08T00:00:00+00:00 |
		| 2004-02-01/2005-02    | 2004-02-01T00:00:00+00:00 | 2005-02-01T00:00:00+00:00 |
		| 2004-02-01/2005       | 2004-02-01T00:00:00+00:00 | 2005-01-01T00:00:00+00:00 |
		| 2005/2006-02          | 2005-01-01T00:00:00+00:00 | 2006-02-01T00:00:00+00:00 |
		| 2004-01-01/P5D        | 2004-01-01T00:00:00+00:00 | 2004-01-06T00:00:00+00:00 |