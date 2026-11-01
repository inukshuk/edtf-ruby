Feature: Print level 2 EDTF strings
  As a Ruby programmer
  I want to convert dates to EDTF strings

  Scenario Outline: Round trips
    When I parse "<string>"
    Then its EDTF string should be "<edtf>"

    @level2
    Examples: Unspecified digits anywhere
      | string     | edtf       |
      | 156X-12-25 | 156X-12-25 |

    @level2 @legacy
    Examples: Draft syntax: u for unspecified digits
      | string     | edtf       |
      | 156u-12-25 | 156X-12-25 |

    @level2
    Examples: Extended intervals
      | string                | edtf                  |
      | 2004-06-XX/2004-07-03 | 2004-06-XX/2004-07-03 |

    @level2 @legacy
    Examples: Draft syntax: u in extended intervals
      | string                | edtf                  |
      | 2004-06-uu/2004-07-03 | 2004-06-XX/2004-07-03 |

    # Hemisphere qualifiers become ISO 8601-2 hemisphere seasons;
    # other season qualifiers and calendars have no equivalent,
    # the upgrade path will report the loss (step 4).
    @level2 @legacy
    Examples: Draft syntax: qualified seasons and calendars
      | string                     | edtf                       |
      | 2001-21^southernHemisphere | 2001-29                    |
      | 2001-02-03^xyz             | 2001-02-03                 |
