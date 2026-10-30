Feature: Print level 1 EDTF strings
  As a Ruby programmer
  I want to convert dates to EDTF strings

  Scenario Outline: Round trips
    When I parse "<string>"
    Then its EDTF string should be "<edtf>"

    @level1
    Examples: Uncertain or approximate dates
      | string      | edtf        |
      | 2001?       | 2001?       |
      | 2004-06?    | 2004-06?    |
      | 2004-06-11? | 2004-06-11? |
      | 1984~       | 1984~       |

    @level1 @legacy
    Examples: Draft syntax: combined qualifiers
      | string | edtf   |
      | 1984?~ | 1984?~ |

    @level1
    Examples: Unspecified dates
      | string     | edtf       |
      | 199X       | 199X       |
      | 19XX       | 19XX       |
      | 1999-XX    | 1999-XX    |
      | 1999-01-XX | 1999-01-XX |
      | 1999-XX-XX | 1999-XX-XX |

    @level1 @legacy
    Examples: Draft syntax: u for unspecified digits
      | string     | edtf       |
      | 199u       | 199X       |
      | 19uu       | 19XX       |
      | 1999-uu    | 1999-XX    |
      | 1999-01-uu | 1999-01-XX |

    @level1
    Examples: Extended intervals
      | string                  | edtf                    |
      | 1984~/2004-06           | 1984~/2004-06           |
      | 1984/2004-06~           | 1984/2004-06~           |
      | 1984~/2004~             | 1984~/2004~             |
      | 1984-06?/2004-08?       | 1984-06?/2004-08?       |
      | 1984-06-02?/2004-08-08~ | 1984-06-02?/2004-08-08~ |

    @level1 @legacy
    Examples: Draft syntax: unknown and open interval ends
      | string              | edtf                |
      | unknown/2006        | unknown/2006        |
      | 2004-06-01/unknown  | 2004-06-01/unknown  |
      | 2004-01-01/open     | 2004-01-01/open     |
      | 1984-06-02?/unknown | 1984-06-02?/unknown |
      | 1984?/2004?~        | 1984?/2004?~        |

    @level1
    Examples: Years with more than four digits
      | string      | edtf        |
      | Y170000002  | Y170000002  |
      | Y-170000002 | Y-170000002 |

    @level1 @legacy
    Examples: Draft syntax: lowercase y
      | string      | edtf        |
      | y170000002  | Y170000002  |
      | y-170000002 | Y-170000002 |

    @level1
    Examples: Seasons
      | string  | edtf    |
      | 2001-21 | 2001-21 |
