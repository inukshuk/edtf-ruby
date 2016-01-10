Feature: Parse unspecified date strings
  As a user of EDTF-Ruby
  I want to be able to parse date strings containing unspecified elements

  Scenario Outline: parse unspecified dates
    When I parse the string "<string>"
    Then the year should be "<year>"
    And the month should be "<month>"
    And the day should be "<day>"
    And the unspecified string code be "<unspecified>"

    @102 @level1
    Scenarios: examples from the specification draft
      | string     | year | month | day | unspecified |
      | 199u       | 1990 | 1     | 1   | sssu-ss-ss  |
      | 19uu       | 1900 | 1     | 1   | ssuu-ss-ss  |
      | 1999-uu    | 1999 | 1     | 1   | ssss-uu-ss  |
      | 1999-02-uu | 1999 | 2     | 1   | ssss-ss-uu  |
      | 1999-uu-uu | 1999 | 1     | 1   | ssss-uu-uu  |

  Scenario: Completely unknown
    When I parse the string "uuuu"
    Then the result should be an Unknown
