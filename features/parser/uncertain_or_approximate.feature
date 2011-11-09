Feature: Parse partial uncertain or approximate dates
  As a Ruby programmer
  I want to convert Date/Time objects to EDTF strings

  @201 @level2
  Scenario Outline: Prints uncertain or approximate dates
    When I parse the string "<string>"
    Then the year should be uncertain? "<?-year>"
    And the month should be uncertain? "<?-month>"
    And the day should be uncertain? "<?-day>"
    And the year should be approximate? "<~-year>"
    And the month should be approximate? "<~-month>"
    And the day should be approximate? "<~-day>"

    Scenarios: Uncertain or approximate dates, day precision
      | date       | precision | string            | ?-year  | ?-month | ?-day   | ~-year  | ~-month | ~-day   |
      | 2004-06-01 | day       | 2004-06-01?~      | yes     | yes     | yes     | yes     | yes     | yes     |
      | 2004-06-01 | day       | 2004-06~-01?      | yes     | yes     | yes     | yes     | yes     | no      |
      | 2004-06-01 | day       | (2004~-06-(01)~)? | yes     | yes     | yes     | yes     | no      | yes     |
      | 2004-06-01 | day       | 2004~-06?-(01)?~  | yes     | yes     | yes     | yes     | no      | yes     |
      | 2004-06-01 | day       | 2004~-06-01?      | yes     | yes     | yes     | yes     | no      | no      |
      | 2004-06-01 | day       | (2004-(06-01)~)?  | yes     | yes     | yes     | no      | yes     | yes     |
      | 2004-06-01 | day       | 2004?-(06-01)?~   | yes     | yes     | yes     | no      | yes     | yes     |
      | 2004-06-01 | day       | (2004-(06)~-01)?  | yes     | yes     | yes     | no      | yes     | no      |
      | 2004-06-01 | day       | 2004?-(06)?~-01?  | yes     | yes     | yes     | no      | yes     | no      |
      | 2004-06-01 | day       | (2004-06-(01)~)?  | yes     | yes     | yes     | no      | no      | yes     |
      | 2004-06-01 | day       | 2004-06?-(01)?~   | yes     | yes     | yes     | no      | no      | yes     |
      | 2004-06-01 | day       | 2004-06-01?       | yes     | yes     | yes     | no      | no      | no      |
      | 2004-06-01 | day       | 2004-06?-01~      | yes     | yes     | no      | yes     | yes     | yes     |
      | 2004-06-01 | day       | 2004-06?~-01      | yes     | yes     | no      | yes     | yes     | no      |
      | 2004-06-01 | day       | 2004~-06?-(01)~   | yes     | yes     | no      | yes     | no      | yes     |
      | 2004-06-01 | day       | 2004~-06?-01      | yes     | yes     | no      | yes     | no      | no      |
#     | 2004-06-01 | day       | 2004-(06?-01)~    | yes     | yes     | no      | no      | yes     | yes     | is this correct?
#     | 2004-06-01 | day       | 2004?-((06)?-01)~ | yes     | yes     | no      | no      | yes     | yes     |
      | 2004-06-01 | day       | 2004?-(06)?~-01~  | yes     | yes     | no      | no      | yes     | yes     |
#      | 2004-06-01 | day       | (2004-(06)~)?-01  | yes     | yes     | no      | no      | yes     | no      |
      | 2004-06-01 | day       | 2004?-(06)?~-01   | yes     | yes     | no      | no      | yes     | no      |
      | 2004-06-01 | day       | 2004-06?-(01)~    | yes     | yes     | no      | no      | no      | yes     |
      | 2004-06-01 | day       | 2004-06?-01       | yes     | yes     | no      | no      | no      | no      |
      | 2004-06-01 | day       | (2004?-06-(01)?)~ | yes     | no      | yes     | yes     | yes     | yes     |
      | 2004-06-01 | day       | 2004?-06~-(01)?~  | yes     | no      | yes     | yes     | yes     | yes     |
      | 2004-06-01 | day       | 2004?-06~-(01)?   | yes     | no      | yes     | yes     | yes     | no      |
      | 2004-06-01 | day       | 2004?~-06-(01)?~  | yes     | no      | yes     | yes     | no      | yes     |
      | 2004-06-01 | day       | 2004?~-06-(01)?   | yes     | no      | yes     | yes     | no      | no      |
      | 2004-06-01 | day       | 2004?-(06-(01)?)~ | yes     | no      | yes     | no      | yes     | yes     |
      | 2004-06-01 | day       | 2004?-(06)~-01?~  | yes     | no      | yes     | no      | yes     | yes     |
      | 2004-06-01 | day       | 2004?-(06)~-01?   | yes     | no      | yes     | no      | yes     | no      |
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
      | 2004-06-01 | day       | 2004~-(06-01)?~   | no      | yes     | yes     | yes     | yes     | yes     |
#     | 2004-06-01 | day       | 2004-(06~-01)?    | no      | yes     | yes     | yes     | yes     | no      | is this correct?
#     | 2004-06-01 | day       | 2004~-((06)~-01)? | no      | yes     | yes     | yes     | yes     | no      |
      | 2004-06-01 | day       | 2004~-(06)?~-01?  | no      | yes     | yes     | yes     | yes     | no      |
      | 2004-06-01 | day       | 2004~-(06-(01)~)? | no      | yes     | yes     | yes     | no      | yes     |
      | 2004-06-01 | day       | 2004~-(06)?-01?~  | no      | yes     | yes     | yes     | no      | yes     |
      | 2004-06-01 | day       | 2004~-(06-01)?    | no      | yes     | yes     | yes     | no      | no      |
      | 2004-06-01 | day       | 2004-(06-01)?~    | no      | yes     | yes     | no      | yes     | yes     |
#      | 2004-06-01 | day       | 2004-((06)~-01)?  | no      | yes     | yes     | no      | yes     | no      |
      | 2004-06-01 | day       | 2004-(06)?~-01?   | no      | yes     | yes     | no      | yes     | no      |
      | 2004-06-01 | day       | 2004-(06-(01)~)?  | no      | yes     | yes     | no      | no      | yes     |
      | 2004-06-01 | day       | 2004-(06)?-01?~   | no      | yes     | yes     | no      | no      | yes     |
      | 2004-06-01 | day       | 2004-(06-01)?     | no      | yes     | yes     | no      | no      | no      |
      | 2004-06-01 | day       | (2004-(06)?-01)~  | no      | yes     | no      | yes     | yes     | yes     |
      | 2004-06-01 | day       | 2004~-(06)?~-01~  | no      | yes     | no      | yes     | yes     | yes     |
#      | 2004-06-01 | day       | (2004-(06)?)~-01  | no      | yes     | no      | yes     | yes     | no      |
      | 2004-06-01 | day       | 2004~-(06)?~-01   | no      | yes     | no      | yes     | yes     | no      |
      | 2004-06-01 | day       | 2004~-(06)?-01~   | no      | yes     | no      | yes     | no      | yes     |
      | 2004-06-01 | day       | 2004~-(06)?-01    | no      | yes     | no      | yes     | no      | no      |
#     | 2004-06-01 | day       | 2004-((06)?-01)~  | no      | yes     | no      | no      | yes     | yes     |
      | 2004-06-01 | day       | 2004-(06)?~-01~   | no      | yes     | no      | no      | yes     | yes     |
      | 2004-06-01 | day       | 2004-(06)?~-01    | no      | yes     | no      | no      | yes     | no      |
      | 2004-06-01 | day       | 2004-(06)?-01~    | no      | yes     | no      | no      | no      | yes     |
      | 2004-06-01 | day       | 2004-(06)?-01     | no      | yes     | no      | no      | no      | no      |
      | 2004-06-01 | day       | (2004-06-(01)?)~  | no      | no      | yes     | yes     | yes     | yes     |
      | 2004-06-01 | day       | 2004-06~-(01)?~   | no      | no      | yes     | yes     | yes     | yes     |
      | 2004-06-01 | day       | 2004-06~-(01)?    | no      | no      | yes     | yes     | yes     | no      |
      | 2004-06-01 | day       | 2004~-06-(01)?~   | no      | no      | yes     | yes     | no      | yes     |
      | 2004-06-01 | day       | 2004~-06-(01)?    | no      | no      | yes     | yes     | no      | no      |
      | 2004-06-01 | day       | 2004-(06-(01)?)~  | no      | no      | yes     | no      | yes     | yes     |
      | 2004-06-01 | day       | 2004-(06)~-01?~   | no      | no      | yes     | no      | yes     | yes     |
      | 2004-06-01 | day       | 2004-(06)~-01?    | no      | no      | yes     | no      | yes     | no      |
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

    Scenarios: Uncertain or approximate dates, month precision
      | date       | precision | string            | ?-year  | ?-month | ?-day   | ~-year  | ~-month | ~-day   |
      | 2004-06-01 | month     | 2004-06?~         | yes     | yes     | no      | yes     | yes     | no      |
      | 2004-06-01 | month     | 2004~-06?         | yes     | yes     | no      | yes     | no      | no      | 
      | 2004-06-01 | month     | (2004-(06)~)?     | yes     | yes     | no      | no      | yes     | no      |
      | 2004-06-01 | month     | 2004?-(06)?~      | yes     | yes     | no      | no      | yes     | no      |
      | 2004-06-01 | month     | 2004-06?          | yes     | yes     | no      | no      | no      | no      |
      | 2004-06-01 | month     | 2004?-06~         | yes     | no      | no      | yes     | yes     | no      |
      | 2004-06-01 | month     | 2004?~-06         | yes     | no      | no      | yes     | no      | no      |
      | 2004-06-01 | month     | 2004?-(06)~       | yes     | no      | no      | no      | yes     | no      |
      | 2004-06-01 | month     | 2004?-06          | yes     | no      | no      | no      | no      | no      |
      | 2004-06-01 | month     | (2004-(06)?)~     | no      | yes     | no      | yes     | yes     | no      |
      | 2004-06-01 | month     | 2004~-(06)?~      | no      | yes     | no      | yes     | yes     | no      |
      | 2004-06-01 | month     | 2004~-(06)?       | no      | yes     | no      | yes     | no      | no      |
      | 2004-06-01 | month     | 2004-(06)?~       | no      | yes     | no      | no      | yes     | no      |
      | 2004-06-01 | month     | 2004-(06)?        | no      | yes     | no      | no      | no      | no      |
      | 2004-06-01 | month     | 2004-06~          | no      | no      | no      | yes     | yes     | no      |
      | 2004-06-01 | month     | 2004~-06          | no      | no      | no      | yes     | no      | no      |
      | 2004-06-01 | month     | 2004-(06)~        | no      | no      | no      | no      | yes     | no      |
      | 2004-06-01 | month     | 2004-06           | no      | no      | no      | no      | no      | no      |


    Scenarios: Uncertain or approximate dates, year precision
      | date       | precision | string            | ?-year  | ?-month | ?-day   | ~-year  | ~-month | ~-day   |
      | 2004-06-01 | year      | 2004?~            | yes     | no      | no      | yes     | no      | no      |
      | 2004-06-01 | year      | 2004?             | yes     | no      | no      | no      | no      | no      |
      | 2004-06-01 | year      | 2004~             | no      | no      | no      | yes     | no      | no      |
      | 2004-06-01 | year      | 2004              | no      | no      | no      | no      | no      | no      |
