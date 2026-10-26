Feature: Parse date-times
  As a user of EDTF-Ruby
  I want to parse EDTF date-time strings

  Scenario Outline: Date-times without a time zone
    When I parse "<string>"
    Then it should be the date-time "<date-time>"

    @level0
    Examples:
      | string              | date-time           |
      | 2001-02-03T09:30:01 | 2001-02-03T09:30:01 |
      | 1985-04-12T23:20:30 | 1985-04-12T23:20:30 |

    # ISO 8601-1:2019/Amd 1 allows 24:00 as the end of a day.
    @level0
    Examples: Midnight at the end of a day
      | string              | date-time           |
      | 2016-05-02T24:00:00 | 2016-05-03T00:00:00 |

    @level0 @wip
    Examples: Fractional seconds
      | string                  | date-time               |
      | 2016-05-02T16:54:59.042 | 2016-05-02T16:54:59.042 |

  Scenario Outline: Date-times with a time zone
    When I parse "<string>"
    Then it should be the date-time "<date-time>"
    And in UTC it should be "<utc>"

    @level0
    Examples:
      | string                    | date-time           | utc                 |
      | 2004-01-01T10:10:10Z      | 2004-01-01T10:10:10 | 2004-01-01T10:10:10 |
      | 1985-04-12T23:20:30Z      | 1985-04-12T23:20:30 | 1985-04-12T23:20:30 |
      | 2004-01-01T10:10:10+05:00 | 2004-01-01T10:10:10 | 2004-01-01T05:10:10 |
      | 2004-01-01T02:10:10+05:00 | 2004-01-01T02:10:10 | 2003-12-31T21:10:10 |
      | 2011-08-15T11:19:00+01:00 | 2011-08-15T11:19:00 | 2011-08-15T10:19:00 |
      | 1985-04-12T23:20:30+04:30 | 1985-04-12T23:20:30 | 1985-04-12T18:50:30 |
      | 2016-05-02T16:54:59-12:00 | 2016-05-02T16:54:59 | 2016-05-03T04:54:59 |

    @level0 @wip
    Examples: Time zone offset in hours only
      | string                 | date-time           | utc                 |
      | 1985-04-12T23:20:30-04 | 1985-04-12T23:20:30 | 1985-04-13T03:20:30 |

    # EDTF requires the extended format; edtf.js also accepts +hhmm.
    @level0 @wip
    Examples: Time zone offset without a colon
      | string                   | date-time           | utc                 |
      | 2016-05-02T16:54:59+0230 | 2016-05-02T16:54:59 | 2016-05-02T14:24:59 |
