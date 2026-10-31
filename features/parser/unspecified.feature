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
      | 201X        | 2010        | YYYX-MM-DD  |
      | 198X        | 1980        | YYYX-MM-DD  |
      | 19XX        | 1900        | YYXX-MM-DD  |
      | 20XX        | 2000        | YYXX-MM-DD  |
      | 1999-XX     | 1999-01     | YYYY-XX-DD  |
      | 2004-XX     | 2004-01     | YYYY-XX-DD  |
      | 1999-02-XX  | 1999-02-01  | YYYY-MM-XX  |
      | 2004-06-XX  | 2004-06-01  | YYYY-MM-XX  |
      | 1985-04-XX  | 1985-04-01  | YYYY-MM-XX  |
      | 1999-XX-XX  | 1999-01-01  | YYYY-XX-XX  |
      | 1985-XX-XX  | 1985-01-01  | YYYY-XX-XX  |
      | -199X       | -1990       | YYYX-MM-DD  |
      | -1999-XX-XX | -1999-01-01 | YYYY-XX-XX  |

    @level1
    Examples: Unspecified year
      | string     | date       | unspecified |
      | XXXX       | 0000       | XXXX-MM-DD  |

    @level1 @wip
    Examples: Unspecified year and month
      | string     | date       | unspecified |
      | XXXX-XX    | 0000-01    | XXXX-XX-DD  |
      | XXXX-XX-XX | 0000-01-01 | XXXX-XX-XX  |

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
      | 156X-12-31 | 1560-12-31 | YYYX-MM-DD  |
      | 15XX-12-25 | 1500-12-25 | YYXX-MM-DD  |
      | 15XX-12-XX | 1500-12-01 | YYXX-MM-XX  |
      | 15XX-XX-25 | 1500-01-25 | YYXX-XX-DD  |

    @level2 @wip
    Examples: Unspecified digits anywhere, not supported yet
      | string     | date       | unspecified |
      | XXXX-12-XX | 0000-12-01 | XXXX-MM-XX  |
      | 1XXX-XX    | 1000-01    | YXXX-XX-DD  |
      | 1XXX-12    | 1000-12    | YXXX-MM-DD  |
      | 1984-1X    | 1984-10    | YYYY-MX-DD  |
      | 1500-1X-25 | 1500-10-25 | YYYY-MX-DD  |
      | 15XX-01-3X | 1500-01-30 | YYXX-MM-DX  |
      | 1XX3       | 1003       | YXXY-MM-DD  |

    @level1 @legacy
    Examples: Draft syntax: u for unspecified digits from the right
      | string      | date        | unspecified |
      | 199u        | 1990        | YYYX-MM-DD  |
      | 198u        | 1980        | YYYX-MM-DD  |
      | uuuu        | 0000        | XXXX-MM-DD  |
      | 19uu        | 1900        | YYXX-MM-DD  |
      | 1999-uu     | 1999-01     | YYYY-XX-DD  |
      | 1999-02-uu  | 1999-02-01  | YYYY-MM-XX  |
      | 2004-06-uu  | 2004-06-01  | YYYY-MM-XX  |
      | 2016-05-uu  | 2016-05-01  | YYYY-MM-XX  |
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
