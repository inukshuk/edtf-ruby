Feature: Parse unspecified dates
  As a user of EDTF-Ruby
  I want to parse dates with unspecified digits

  Scenario Outline: Unspecified digits
    When I parse "<string>"
    Then it should be the date "<date>"
    And the unspecified digits should be "<unspecified>"

    @level1
    Examples: Unspecified digits from the right
      | string      | date        | unspecified |
      | 199X        | 1990        | YYYX-MM-DD  |
      | 19XX        | 1900        | YYXX-MM-DD  |
      | 1999-XX     | 1999-01     | YYYY-XX-DD  |
      | 1999-02-XX  | 1999-02-01  | YYYY-MM-XX  |
      | 2004-06-XX  | 2004-06-01  | YYYY-MM-XX  |
      | 1999-XX-XX  | 1999-01-01  | YYYY-XX-XX  |
      | -199X       | -1990       | YYYX-MM-DD  |
      | -1999-XX-XX | -1999-01-01 | YYYY-XX-XX  |

    @level2
    Examples: Unspecified digits anywhere
      | string     | date       | unspecified |
      | 199X-01    | 1990-01    | YYYX-MM-DD  |
      | 199X-01-01 | 1990-01-01 | YYYX-MM-DD  |
      | 19XX-01-01 | 1900-01-01 | YYXX-MM-DD  |
      | 199X-XX-01 | 1990-01-01 | YYYX-XX-DD  |
      | 19XX-XX-01 | 1900-01-01 | YYXX-XX-DD  |
      | 199X-XX-XX | 1990-01-01 | YYYX-XX-XX  |
      | 19XX-XX-XX | 1900-01-01 | YYXX-XX-XX  |
      | 199X-01-XX | 1990-01-01 | YYYX-MM-XX  |
      | 19XX-01-XX | 1900-01-01 | YYXX-MM-XX  |
      | 1999-XX-01 | 1999-01-01 | YYYY-XX-DD  |

    @level1 @legacy
    Examples: Draft syntax: u for unspecified digits from the right
      | string      | date        | unspecified |
      | 199u        | 1990        | YYYX-MM-DD  |
      | 19uu        | 1900        | YYXX-MM-DD  |
      | 1999-uu     | 1999-01     | YYYY-XX-DD  |
      | 1999-02-uu  | 1999-02-01  | YYYY-MM-XX  |
      | 2004-06-uu  | 2004-06-01  | YYYY-MM-XX  |
      | 1999-uu-uu  | 1999-01-01  | YYYY-XX-XX  |
      | -199u       | -1990       | YYYX-MM-DD  |
      | -1999-uu-uu | -1999-01-01 | YYYY-XX-XX  |

    @level2 @legacy
    Examples: Draft syntax: u for unspecified digits anywhere
      | string     | date       | unspecified |
      | 199u-01    | 1990-01    | YYYX-MM-DD  |
      | 199u-01-01 | 1990-01-01 | YYYX-MM-DD  |
      | 19uu-01-01 | 1900-01-01 | YYXX-MM-DD  |
      | 199u-uu-01 | 1990-01-01 | YYYX-XX-DD  |
      | 19uu-uu-01 | 1900-01-01 | YYXX-XX-DD  |
      | 199u-uu-uu | 1990-01-01 | YYYX-XX-XX  |
      | 19uu-uu-uu | 1900-01-01 | YYXX-XX-XX  |
      | 199u-01-uu | 1990-01-01 | YYYX-MM-XX  |
      | 19uu-01-uu | 1900-01-01 | YYXX-MM-XX  |
      | 1999-uu-01 | 1999-01-01 | YYYY-XX-DD  |

  # Quirk: in ISO 8601-2, XXXX is a level 1 date with an unspecified year.
  @level1 @legacy
  Scenario Outline: Unknown dates
    When I parse "<string>"
    Then it should be unknown

    Examples:
      | string |
      | uuuu   |
      | XXXX   |
