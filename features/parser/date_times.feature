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

  Scenario Outline: Date-times with a time zone
    When I parse "<string>"
    Then it should be the date-time "<date-time>"
    And in UTC it should be "<utc>"

    @level0
    Examples:
      | string                    | date-time           | utc                 |
      | 2004-01-01T10:10:10Z      | 2004-01-01T10:10:10 | 2004-01-01T10:10:10 |
      | 2004-01-01T10:10:10+05:00 | 2004-01-01T10:10:10 | 2004-01-01T05:10:10 |
      | 2004-01-01T02:10:10+05:00 | 2004-01-01T02:10:10 | 2003-12-31T21:10:10 |
      | 2011-08-15T11:19:00+01:00 | 2011-08-15T11:19:00 | 2011-08-15T10:19:00 |
