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

  @level2 @wip
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

  Scenario Outline: Calendars
    When I parse "<string>"
    Then it should be the date "<date>"
    And the calendar should be "<calendar>"

    @legacy
    Examples: Draft syntax: calendar names
      | string            | date       | calendar |
      | 2001-02-03^xyz    | 2001-02-03 | xyz      |
      | 2001-02-03^julian | 2001-02-03 | julian   |
