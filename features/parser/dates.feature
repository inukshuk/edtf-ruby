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
      | 2008-12    | 2008-12    |
      | 2008       | 2008       |
      | -0999      | -0999      |
      | -2101      | -2101      |
      | -2323      | -2323      |
      | 0000       | 0000       |

    @level1
    Examples: Years with more than four digits
      | string      | date       |
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

  Scenario Outline: Calendars
    When I parse "<string>"
    Then it should be the date "<date>"
    And the calendar should be "<calendar>"

    @legacy
    Examples: EDTF-Ruby extensions: calendar names
      | string         | date       | calendar |
      | 2001-02-03^xyz | 2001-02-03 | xyz      |

  Scenario: Invalid dates
    Then the following strings should be rejected:
      | xyz           |
      | x2009         |
      | 2004-04-(1)?1 |
