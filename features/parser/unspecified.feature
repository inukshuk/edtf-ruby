Feature: Parse unspecified dates
  As a user of EDTF-Ruby
  I want to parse dates with unspecified digits

  Scenario Outline: Unspecified digits
    When I parse "<string>"
    Then it should be the date "<date>"
    And the unspecified digits should be "<unspecified>"

    @level1
    Examples: Unspecified digits from the right
      | string     | date       | unspecified |
      | 199X       | 1990       | YYYX-MM-DD  |
      | 19XX       | 1900       | YYXX-MM-DD  |
      | 1999-XX    | 1999-01    | YYYY-XX-DD  |
      | 1999-02-XX | 1999-02-01 | YYYY-MM-XX  |
      | 1999-XX-XX | 1999-01-01 | YYYY-XX-XX  |

    @level1 @legacy
    Examples: Draft syntax: u for unspecified digits
      | string     | date       | unspecified |
      | 199u       | 1990       | YYYX-MM-DD  |
      | 19uu       | 1900       | YYXX-MM-DD  |
      | 1999-uu    | 1999-01    | YYYY-XX-DD  |
      | 1999-02-uu | 1999-02-01 | YYYY-MM-XX  |
      | 1999-uu-uu | 1999-01-01 | YYYY-XX-XX  |

  # Quirk: in ISO 8601-2, XXXX is a level 1 date with an unspecified year.
  @level1 @legacy
  Scenario Outline: Unknown dates
    When I parse "<string>"
    Then it should be unknown

    Examples:
      | string |
      | uuuu   |
      | XXXX   |
