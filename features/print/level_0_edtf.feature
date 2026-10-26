Feature: Print level 0 EDTF strings
  As a Ruby programmer
  I want to convert dates to EDTF strings

  Scenario Outline: Dates
    Given the date "<date>"
    Then its EDTF string should be "<edtf>"

    @level0
    Examples:
      | date        | edtf        |
      | 2004-08-12  | 2004-08-12  |
      | -0300-08-12 | -0300-08-12 |

  Scenario Outline: Dates with reduced precision
    Given the date "<date>" with <precision> precision
    Then its EDTF string should be "<edtf>"

    @level0
    Examples:
      | date       | precision | edtf       |
      | 1980-08-24 | day       | 1980-08-24 |
      | 1980-08-24 | month     | 1980-08    |
      | 1980-08-24 | year      | 1980       |

  Scenario Outline: Round trips
    When I parse "<string>"
    Then its EDTF string should be "<edtf>"

    @level0
    Examples: Dates
      | string     | edtf       |
      | 2001-02-03 | 2001-02-03 |
      | 2001-02    | 2001-02    |
      | 2001       | 2001       |
      | -9909      | -9909      |
      | 0000       | 0000       |

    @level0
    Examples: Date-times
      | string                    | edtf                      |
      | 2001-02-03T09:30:01       | 2001-02-03T09:30:01       |
      | 2004-01-01T10:10:10Z      | 2004-01-01T10:10:10+00:00 |
      | 2004-01-01T10:10:10+05:00 | 2004-01-01T10:10:10+05:00 |

    @level0
    Examples: Intervals
      | string                | edtf                  |
      | 1964/2008             | 1964/2008             |
      | 2004-06/2006-08       | 2004-06/2006-08       |
      | 2004-02-01/2005-02-08 | 2004-02-01/2005-02-08 |
      | 2004-02-01/2005-02    | 2004-02-01/2005-02    |
      | 2004-02-01/2005       | 2004-02-01/2005       |
      | 2005/2006-02          | 2005/2006-02          |
