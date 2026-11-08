Feature: Parse dates
  As a user of EDTF-Ruby
  I want to parse EDTF date strings

  Scenario Outline: Dates
    When I parse "<string>"
    Then it should be the date "<date>"

    @level0
    Examples: Year, month and day
      | string     | date       |
      | 2001-02-03 | 2001-02-03 |
      | 1985-04-12 | 1985-04-12 |
      | 2016-05-31 | 2016-05-31 |
      | 2008-12    | 2008-12    |
      | 1985-04    | 1985-04    |
      | 2008       | 2008       |
      | 1985       | 1985       |
      | 0409       | 0409       |
      | 9999       | 9999       |
      | 0000       | 0000       |
      | 0000-01-01 | 0000-01-01 |
      | -0002      | -0002      |
      | -0999      | -0999      |
      | -1985      | -1985      |
      | -2101      | -2101      |
      | -2323      | -2323      |
      | -9999      | -9999      |

    @level0
    Examples: Leap days and the Gregorian reform
      | string     | date       |
      | 2016-02-29 | 2016-02-29 |
      | 2000-02-29 | 2000-02-29 |
      | 1582-10-10 | 1582-10-10 |

    @level1
    Examples: Years with more than four digits
      | string      | date       |
      | Y10000      | 10000      |
      | Y170000002  | 170000002  |
      | Y-170000002 | -170000002 |

    @level2
    Examples: Years in exponential form
      | string | date       |
      | Y17E7  | 170000000  |
      | Y-17E7 | -170000000 |

    @level1 @legacy
    Examples: Draft syntax: lowercase y
      | string      | date       |
      | y170000002  | 170000002  |
      | y-170000002 | -170000002 |

    @level2 @legacy
    Examples: Draft syntax: lowercase y and e
      | string | date       |
      | y17e7  | 170000000  |
      | y-17e7 | -170000000 |
      | Y17e7  | 170000000  |

    # Quirk: edtf.js rejects -0000.
    @level0 @legacy
    Examples: Quirks: negative year zero
      | string | date |
      | -0000  | 0000 |

  @level2
  Scenario Outline: Significant digits
    When I parse "<string>"
    Then it should be the date "<date>"
    And the significant digits should be <digits>
    And it should span "<from>" to "<to>"

    Examples:
      | string       | date      | digits | from                | to                  |
      | 1950S2       | 1950      | 2      | 1900-01-01          | 1999-12-31          |
      | Y171010000S3 | 171010000 | 3      | 171000000-01-01     | 171999999-12-31     |
      | Y3388E2S3    | 338800    | 3      | 338000-01-01        | 338999-12-31        |

  # ISO 8601 numbers years astronomically: 0000 is 1 BC, -0001 is 2 BC.
  # Without year zero, years before 1 are written historically
  # (-0001 is 1 BC) but stored astronomically, and written as read.
  Scenario Outline: Years before 1 without year zero
    Given the year zero option is off
    When I parse "<string>"
    Then it should be the date "<date>"
    And its EDTF string should be "<string>"

    Examples:
      | string      | date        |
      | -0001       | 0000        |
      | -0002       | -0001       |
      | -0044-03-15 | -0043-03-15 |
      | -0001-02-29 | 0000-02-29  |
      | 0001        | 0001        |

  # Dates are proleptic Gregorian, unless parsed in another calendar.
  Scenario Outline: Calendars
    Given the calendar option is "<calendar>"
    When I parse "<string>"
    Then it should be the date "<date>"
    And it should be in the <calendar> calendar
    And its first day should be "<gregorian>" in the Gregorian calendar

    Examples:
      | string     | calendar  | date       | gregorian  |
      | 1500-02-29 | julian    | 1500-02-29 | 1500-03-10 |
      | 1500       | julian    | 1500       | 1500-01-10 |
      | 1582-10-04 | italy     | 1582-10-04 | 1582-10-14 |
      | 1582-10-15 | italy     | 1582-10-15 | 1582-10-15 |
      | 1752-09-02 | england   | 1752-09-02 | 1752-09-13 |
      | 2001-02-03 | gregorian | 2001-02-03 | 2001-02-03 |

  Scenario Outline: Calendar names
    When I parse "<string>"
    Then it should be the date "<date>"
    And it should be in the <calendar> calendar
    And the parse result should record the calendar "<calendar>"

    @legacy
    Examples: Draft syntax: calendar names
      | string            | date       | calendar |
      | 2001-02-03^julian | 2001-02-03 | julian   |
      | 1500-02-29^julian | 1500-02-29 | julian   |
