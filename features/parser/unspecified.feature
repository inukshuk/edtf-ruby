Feature: Parse unspecified date strings
  As a user of EDTF-Ruby
  I want to be able to parse date strings containing unspecified elements

  Scenario Outline: parse unspecified dates
    When I parse the string "<string>"
    Then the year should be "<year>"
    And the month should be "<month>"
    And the day should be "<day>"
    And the unspecified string code be "<unspecified>"

    @102 @level1 @draft
    Scenarios: examples from the specification draft
      | string     | year | month | day | unspecified |
      | 199u       | 1990 | 1     | 1   | sssX-ss-ss  |
      | 19uu       | 1900 | 1     | 1   | ssXX-ss-ss  |
      | 1999-uu    | 1999 | 1     | 1   | ssss-XX-ss  |
      | 1999-02-uu | 1999 | 2     | 1   | ssss-ss-XX  |
      | 1999-uu-uu | 1999 | 1     | 1   | ssss-XX-XX  |

    @102 @level1 @final
    Scenarios: examples from the specification draft
      | string     | year | month | day | unspecified |
      | 199X       | 1990 | 1     | 1   | sssX-ss-ss  |
      | 19XX       | 1900 | 1     | 1   | ssXX-ss-ss  |
      | 1999-XX    | 1999 | 1     | 1   | ssss-XX-ss  |
      | 1999-02-XX | 1999 | 2     | 1   | ssss-ss-XX  |
      | 1999-XX-XX | 1999 | 1     | 1   | ssss-XX-XX  |

  Scenario: Completely unknown
    When I parse the string "uuuu"
    Then the result should be an Unknown
    When I parse the string "XXXX"
    Then the result should be an Unknown
