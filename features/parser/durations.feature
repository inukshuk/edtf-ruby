Feature: EDTF parsers parses ISO 8601 durations

	As a user of edtf-ruby
	I want to parse duration strings specified in ISO 8601
	
	Scenario Outline: EDTF parses duration string
		When I parse the string "<string>"
		Then the duration should last "<years>" years
		And the duration should last "<months>" months
		And the duration should last "<weeks>" weeks
		And the duration should last "<days>" days
		And the duration should last "<hours>" hours
		And the duration should last "<minutes>" minutes
		And the duration should last "<seconds>" seconds
		
	
	@duration @basic_features
	Scenarios: durations
		| string               | years | months | weeks | days | hours | minutes | seconds |
		| P5Y                  | 5     | 0      | 0     | 0    | 0     | 0       | 0       |
		| PT15H                | 0     | 0      | 0     | 0    | 15    | 0       | 0       |
		| P5Y2M10DT15H         | 5     | 2      | 0     | 10   | 15    | 0       | 0       |
		