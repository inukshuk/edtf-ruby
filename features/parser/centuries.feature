Feature: EDTF parses ISO 8601 century strings

	As a user of edtf-ruby
	I want to parse ISO century strings
	
	Scenario Outline: EDTF parses century string
		When I parse the string "<string>"
		Then the century should be "<century>"
	
	@century @standard_features
	Scenarios: centuries
		| string | century |
		| 00     | 1       |
		| 19     | 20      |