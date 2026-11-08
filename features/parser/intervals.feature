Feature: Parse intervals
  As a user of EDTF-Ruby
  I want to parse EDTF interval strings

  Scenario Outline: Intervals
    When I parse "<string>"
    Then it should cover "<date>"

    @level0
    Examples:
      | string                | date       |
      | 1964/2008             | 1964-01-01 |
      | 2004-06/2006-08       | 2006-08-31 |
      | 2004-01-01/2004-01-02 | 2004-01-01 |
      | 2004-02-01/2005-02-08 | 2005-02-08 |
      | 2004-02-01/2005-02    | 2004-12-01 |
      | 2004-02-01/2005       | 2005-12-31 |
      | 2005/2006-02          | 2005-01-01 |

  Scenario Outline: Interval ends
    When I parse "<string>"
    Then the start should be "<start>"
    And the end should be "<end>"

    @level0
    Examples: Dates
      | string          | start   | end        |
      | 2007/2008       | 2007    | 2008       |
      | 1980-08/1994    | 1980-08 | 1994       |
      | 1075/1137-12-04 | 1075    | 1137-12-04 |
      | -0060/-0055     | -0060   | -0055      |

    @level1
    Examples: Uncertain or approximate dates
      | string                  | start       | end         |
      | 1984-06-02?/2004-08-08~ | 1984-06-02? | 2004-08-08~ |
      | 1980?/1994~             | 1980?       | 1994~       |
      | 1985~/1990?             | 1985~       | 1990?       |
      | 1964/2008?              | 1964        | 2008?       |
      | 2004-06-11?/2004-06-12  | 2004-06-11? | 2004-06-12  |
      | 1640%/1650%             | 1640%       | 1650%       |

    @level1
    Examples: Open or unknown ends
      | string        | start      | end        |
      | 2004-01-01/.. | 2004-01-01 | open       |
      | ../2008-08-23 | open       | 2008-08-23 |
      | 2004-01-01/   | 2004-01-01 | unknown    |
      | /2004-01-01   | unknown    | 2004-01-01 |
      | 1985-04-12/.. | 1985-04-12 | open       |
      | 1985-04/..    | 1985-04    | open       |
      | 1985/..       | 1985       | open       |
      | ../1985-04-12 | open       | 1985-04-12 |
      | ../1985-04    | open       | 1985-04    |
      | ../1985       | open       | 1985       |
      | 1985-04-12/   | 1985-04-12 | unknown    |
      | 1985-04/      | 1985-04    | unknown    |
      | 1985/         | 1985       | unknown    |
      | /1985-04-12   | unknown    | 1985-04-12 |
      | /1985-04      | unknown    | 1985-04    |
      | /1985         | unknown    | 1985       |
      | 1930~/..      | 1930~      | open       |
      | 1922?/        | 1922?      | unknown    |

    @level2
    Examples: Unspecified digits
      | string                | start      | end        |
      | 2004-06-XX/2004-07-03 | 2004-06-XX | 2004-07-03 |
      | 05XX/15XX             | 05XX       | 15XX       |

    @level1 @legacy
    Examples: Draft syntax: open and unknown
      | string             | start      | end        |
      | 2004-01-01/open    | 2004-01-01 | open       |
      | open/2008-08-23    | open       | 2008-08-23 |
      | 2004-01-01/unknown | 2004-01-01 | unknown    |
      | unknown/2004-01-01 | unknown    | 2004-01-01 |
      | 1960/open          | 1960       | open       |
      | open/1960          | open       | 1960       |

    @level2 @legacy
    Examples: Draft syntax: u for unspecified digits
      | string                | start      | end        |
      | 2004-06-uu/2004-07-03 | 2004-06-XX | 2004-07-03 |

    @level2
    Examples: Qualification to the left of a part
      | string                  | start       | end         |
      | 2004-06-~01/2004-06-~20 | 2004-06-~01 | 2004-06-~20 |

  # ISO 8601-1 allows 24:00, the end of a day, only as an interval's end;
  # it is the next day's 00:00.
  Scenario Outline: Midnight at the end of an interval
    When I parse "<string>"
    Then its EDTF string should be "<edtf>"

    @level0
    Examples:
      | string                                    | edtf                                      |
      | 2016-05-02T10:00/2016-05-02T24:00         | 2016-05-02T10:00/2016-05-03T00:00         |
      | 2016-12-31T10:00:00Z/2016-12-31T24:00:00Z | 2016-12-31T10:00:00Z/2017-01-01T00:00:00Z |
      | 2016-05-02/2016-05-02T24                  | 2016-05-02/2016-05-03T00                  |
