Feature: EDTF parser parses date strings

  In order to use dates in EDTF
  As a user of edtf-ruby
  I want to parse date strings formatted in EDTF
    
  Scenario Outline: EDTF parses a date string
    When I parse the string "<string>"
    Then the year should be "<year>"
    And the month should be "<month>"
    And the day should be "<day>"

    @001 @level0
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

    @101 @level1
    Scenarios: uncertain date examples from the specification
     | string      | year | uncertain-year | month | uncertain-month | day | uncertain-day |
     | 1992?       | 1992 | yes            | 1     | no              | 1   | no            |
     | 1984?       | 1984 | yes            | 1     | no              | 1   | no            |
     | 2004-06?    | 2004 | yes            | 6     | yes             | 1   | no            |
     | 2004-06-11? | 2004 | yes            | 6     | yes             | 11  | yes           |


  Scenario Outline: EDTF parses uncertain or approximate date strings
    When I parse the string "<string>"
    Then the year should be "<year>"
    And the month should be "<month>"
    And the day should be "<day>"
    And the date should be uncertain? "<uncertain>"
    And the date should be approximate? "<approximate>"

    @101 @level1
    Scenarios: uncertain date examples from the specification
      | string      | year | month | day | uncertain | approximate |
      | 1984~       | 1984 | 1     | 1   | no        | yes         |
      | 1984?~      | 1984 | 1     | 1   | yes       | yes         |

  Scenario Outline: EDTF parses uncertain or approximate dates
    When I parse the string "<string>"
    And the year should be uncertain? "<?-year>"
    And the month should be uncertain? "<?-month>"
    And the day should be uncertain? "<?-day>"
    And the year should be approximate? "<~-year>"
    And the month should be approximate? "<~-month>"
    And the day should be approximate? "<~-day>"

  @201 @level2
  Scenarios: uncertain date examples from the specification
   | string          | ~-year | ?-year | ~-month | ?-month | ~-day | ?-day |
	 | 2004?-06-11     | no     | yes    | no      | no      | no    | no    |
	 | 2004-06~-11     | yes    | no     | yes     | no      | no    | no    |
	 | 2004-(06)?-11   | no     | no     | no      | yes     | no    | no    |
	 | 2004-06-(11)~   | no     | no     | no      | no      | yes   | no    |
	 | 2004-(06)?~     | no     | no     | yes     | yes     | no    | no    |
	 | 2004-(06-11)?   | no     | no     | no      | yes     | no    | yes   |
	 | 2004?-06-(11)~  | no     | yes    | no      | no      | yes   | no    |
	 | (2004-(06)~)?   | no     | yes    | yes     | yes     | no    | no    |
	 | 2004-06-(01)~   | no     | no     | no      | no      | yes   | no    |

