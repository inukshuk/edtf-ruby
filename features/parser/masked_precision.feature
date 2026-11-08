Feature: Parse decades and centuries
  As a user of EDTF-Ruby
  I want to parse decades and centuries

  Scenario Outline: Decades and centuries
    When I parse "<string>"
    Then it should be a <type>
    And it should span "<from>" to "<to>"

    @level0
    Examples: Centuries
      | string | type    | from        | to          |
      | 19     | century | 1900-01-01  | 1999-12-31  |
      | -01    | century | -0199-01-01 | -0100-12-31 |

    @level2
    Examples: Decades
      | string | type   | from       | to         |
      | 196    | decade | 1960-01-01 | 1969-12-31 |
      | 196~   | decade | 1960-01-01 | 1969-12-31 |

    # Unspecified trailing digits only; turned off by strict: true.
    @level1
    Examples: Years with unspecified trailing digits
      | string | type    | from       | to         |
      | 19XX   | century | 1900-01-01 | 1999-12-31 |
      | 196X   | decade  | 1960-01-01 | 1969-12-31 |
      | 19XX?  | century | 1900-01-01 | 1999-12-31 |

    @level2
    Examples: Other unspecified digits are dates
      | string  | type | from       | to         |
      | 1X0X    | date | 1000-01-01 | 1909-12-31 |
      | 19XX-06 | date | 1900-06-01 | 1999-06-30 |

    @level2 @legacy
    Examples: Draft syntax: x for masked digits
      | string | type    | from       | to         |
      | 196x   | decade  | 1960-01-01 | 1969-12-31 |
      | 19xx   | century | 1900-01-01 | 1999-12-31 |
      | 198x   | decade  | 1980-01-01 | 1989-12-31 |
      | 18xx   | century | 1800-01-01 | 1899-12-31 |
