Feature: Print uncertain or approximate dates
	As a Ruby programmer
	I want to convert Date/Time objects to EDTF strings

	@201 @level2
	Scenario Outline: Prints uncertain or approximate dates
		Given the date "<date>" with precision set to "<precision>"
		When the year is uncertain: "<?-year>"
		And the month is uncertain: "<?-month>"
		And the day is uncertain: "<?-day>"
		And the year is approximate: "<~-year>"
		And the month is approximate: "<~-month>"
		And the day is approximate "<~-day>"
		When I convert the date
		Then the EDTF string should be "<string>"

		@wip		
		Scenarios: Uncertain or approximate dates, day precision
			| date       | precision | string            | ?-year  | ?-month | ?-day   | ~-year  | ~-month | ~-day   |
			| 2004-06-01 | day       | 2004-06-01?~      | yes     | yes     | yes     | yes     | yes     | yes     |
			| 2004-06-01 | day       | 2004-06~-01?      | yes     | yes     | yes     | yes     | yes     | no      |
			| 2004-06-01 | day       | (2004~-06-(01)~)? | yes     | yes     | yes     | yes     | no      | yes     |
			| 2004-06-01 | day       | 2004~-06-01?      | yes     | yes     | yes     | yes     | no      | no      |
			| 2004-06-01 | day       | (2004-(06-01)~)?  | yes     | yes     | yes     | no      | yes     | yes     |
			| 2004-06-01 | day       | (2004-(06)~-01)?  | yes     | yes     | yes     | no      | yes     | no      |
			| 2004-06-01 | day       | (2004-06-(01)~)?  | yes     | yes     | yes     | no      | no      | yes     |
			| 2004-06-01 | day       | 2004-06-01?       | yes     | yes     | yes     | no      | no      | no      |
			| 2004-06-01 | day       | 2004-06?-01~      | yes     | yes     | no      | yes     | yes     | yes     |
			| 2004-06-01 | day       | 2004-06?~-01      | yes     | yes     | no      | yes     | yes     | no      |
			| 2004-06-01 | day       | 2004~-06?-(01)~   | yes     | yes     | no      | yes     | no      | yes     |
			| 2004-06-01 | day       | 2004~-06?-01      | yes     | yes     | no      | yes     | no      | no      |
#			| 2004-06-01 | day       | 2004-(06?-01)~    | yes     | yes     | no      | no      | yes     | yes     | is this correct?
			| 2004-06-01 | day       | 2004?-((06)?-01)~ | yes     | yes     | no      | no      | yes     | yes     |
			| 2004-06-01 | day       | (2004-(06)~)?-01  | yes     | yes     | no      | no      | yes     | no      |
			| 2004-06-01 | day       | 2004-06?-(01)~    | yes     | yes     | no      | no      | no      | yes     |
			| 2004-06-01 | day       | 2004-06?-01       | yes     | yes     | no      | no      | no      | no      |
			| 2004-06-01 | day       | (2004?-06-(01)?)~ | yes     | no      | yes     | yes     | yes     | yes     |
			| 2004-06-01 | day       | 2004?-06~-(01)?   | yes     | no      | yes     | yes     | yes     | no      |
			| 2004-06-01 | day       | 2004?~-06-(01)?~  | yes     | no      | yes     | yes     | no      | yes     |
			| 2004-06-01 | day       | 2004?~-06-(01)?   | yes     | no      | yes     | yes     | no      | no      |
			| 2004-06-01 | day       | 2004?-(06-(01)?)~ | yes     | no      | yes     | no      | yes     | yes     |
			| 2004-06-01 | day       | 2004?-(06)~-(01)? | yes     | no      | yes     | no      | yes     | no      |
			| 2004-06-01 | day       | 2004?-06-(01)?~   | yes     | no      | yes     | no      | no      | yes     |
			| 2004-06-01 | day       | 2004?-06-(01)?    | yes     | no      | yes     | no      | no      | no      |
			| 2004-06-01 | day       | 2004?-06-01~      | yes     | no      | no      | yes     | yes     | yes     |
			| 2004-06-01 | day       | 2004?-06~-01      | yes     | no      | no      | yes     | yes     | no      |
			| 2004-06-01 | day       | 2004?~-06-(01)~   | yes     | no      | no      | yes     | no      | yes     |
			| 2004-06-01 | day       | 2004?~-06-01      | yes     | no      | no      | yes     | no      | no      |
			| 2004-06-01 | day       | 2004?-(06-01)~    | yes     | no      | no      | no      | yes     | yes     |
			| 2004-06-01 | day       | 2004?-(06)~-01    | yes     | no      | no      | no      | yes     | no      |
			| 2004-06-01 | day       | 2004?-06-(01)~    | yes     | no      | no      | no      | no      | yes     |
			| 2004-06-01 | day       | 2004?-06-01       | yes     | no      | no      | no      | no      | no      |
			| 2004-06-01 | day       | (2004-(06-01)?)~  | no      | yes     | yes     | yes     | yes     | yes     |
#			| 2004-06-01 | day       | 2004-(06~-01)?    | no      | yes     | yes     | yes     | yes     | no      | is this correct?
			| 2004-06-01 | day       | 2004~-((06)~-01)? | no      | yes     | yes     | yes     | yes     | no      |
			| 2004-06-01 | day       | 2004~-(06-(01)~)? | no      | yes     | yes     | yes     | no      | yes     |
			| 2004-06-01 | day       | 2004~-(06-01)?    | no      | yes     | yes     | yes     | no      | no      |
			| 2004-06-01 | day       | 2004-(06-01)?~    | no      | yes     | yes     | no      | yes     | yes     |
			| 2004-06-01 | day       | 2004-((06)~-01)?  | no      | yes     | yes     | no      | yes     | no      |
			| 2004-06-01 | day       | 2004-(06-(01)~)?  | no      | yes     | yes     | no      | no      | yes     |
			| 2004-06-01 | day       | 2004-(06-01)?     | no      | yes     | yes     | no      | no      | no      |
			| 2004-06-01 | day       | (2004-(06)?-01)~  | no      | yes     | no      | yes     | yes     | yes     |
			| 2004-06-01 | day       | (2004-(06)?)~-01  | no      | yes     | no      | yes     | yes     | no      |
			| 2004-06-01 | day       | 2004~-(06)?-(01)~ | no      | yes     | no      | yes     | no      | yes     |
			| 2004-06-01 | day       | 2004~-(06)?-01    | no      | yes     | no      | yes     | no      | no      |
			| 2004-06-01 | day       | 2004-((06)?-01)~  | no      | yes     | no      | no      | yes     | yes     |
			| 2004-06-01 | day       | 2004-(06)?~-01    | no      | yes     | no      | no      | yes     | no      |
			| 2004-06-01 | day       | 2004-(06)?-(01)~  | no      | yes     | no      | no      | no      | yes     |
			| 2004-06-01 | day       | 2004-(06)?-01     | no      | yes     | no      | no      | no      | no      |
			| 2004-06-01 | day       | (2004-06-(01)?)~  | no      | no      | yes     | yes     | yes     | yes     |
			| 2004-06-01 | day       | 2004-06~-(01)?    | no      | no      | yes     | yes     | yes     | no      |
			| 2004-06-01 | day       | 2004~-06-(01)?~   | no      | no      | yes     | yes     | no      | yes     |
			| 2004-06-01 | day       | 2004~-06-(01)?    | no      | no      | yes     | yes     | no      | no      |
			| 2004-06-01 | day       | 2004-(06-(01)?)~  | no      | no      | yes     | no      | yes     | yes     |
			| 2004-06-01 | day       | 2004-(06)~-(01)?  | no      | no      | yes     | no      | yes     | no      |
			| 2004-06-01 | day       | 2004-06-(01)?~    | no      | no      | yes     | no      | no      | yes     |
			| 2004-06-01 | day       | 2004-06-(01)?     | no      | no      | yes     | no      | no      | no      |
			| 2004-06-01 | day       | 2004-06-01~       | no      | no      | no      | yes     | yes     | yes     |
			| 2004-06-01 | day       | 2004-06~-01       | no      | no      | no      | yes     | yes     | no      |
			| 2004-06-01 | day       | 2004~-06-(01)~    | no      | no      | no      | yes     | no      | yes     |
			| 2004-06-01 | day       | 2004~-06-01       | no      | no      | no      | yes     | no      | no      |
			| 2004-06-01 | day       | 2004-(06-01)~     | no      | no      | no      | no      | yes     | yes     |
			| 2004-06-01 | day       | 2004-(06)~-01     | no      | no      | no      | no      | yes     | no      |
			| 2004-06-01 | day       | 2004-06-(01)~     | no      | no      | no      | no      | no      | yes     |
			| 2004-06-01 | day       | 2004-06-01        | no      | no      | no      | no      | no      | no      |
