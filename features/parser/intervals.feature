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
      | string    | start | end  |
      | 2007/2008 | 2007  | 2008 |

    @level1
    Examples: Uncertain or approximate dates
      | string                  | start       | end         |
      | 1984-06-02?/2004-08-08~ | 1984-06-02? | 2004-08-08~ |

    @level1
    Examples: Open or unknown ends
      | string         | start      | end        |
      | 2004-01-01/..  | 2004-01-01 | open       |
      | ../2008-08-23  | open       | 2008-08-23 |
      | 2004-01-01/    | 2004-01-01 | unknown    |
      | /2004-01-01    | unknown    | 2004-01-01 |

    @level2
    Examples: Unspecified digits
      | string                | start      | end        |
      | 2004-06-XX/2004-07-03 | 2004-06-XX | 2004-07-03 |

    @level1 @legacy
    Examples: Draft syntax: open and unknown
      | string             | start      | end        |
      | 2004-01-01/open    | 2004-01-01 | open       |
      | open/2008-08-23    | open       | 2008-08-23 |
      | 2004-01-01/unknown | 2004-01-01 | unknown    |
      | unknown/2004-01-01 | unknown    | 2004-01-01 |

    @level2 @legacy
    Examples: Draft syntax: u for unspecified digits
      | string                | start      | end        |
      | 2004-06-uu/2004-07-03 | 2004-06-XX | 2004-07-03 |
