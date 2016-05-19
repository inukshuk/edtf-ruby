Feature: Print Date/Time objects as Level 0 EDTF strings
  As a Ruby programmer
  I want to convert Date/Time objects to EDTF strings

  @001 @level0
  Scenario: Convert simple dates
    Given the date "2004-08-12"
    When I convert the date
    Then the EDTF string should be "2004-08-12"

  @001 @level0
  Scenario: Convert simple negative dates
    Given the date "-0300-08-12"
    When I convert the date
    Then the EDTF string should be "-0300-08-12"

  @001 @level0
  Scenario: Convert simple dates with precision
    Given the date "1980-08-24" with precision set to "day"
    When I convert the date
    Then the EDTF string should be "1980-08-24"
    Given the date "1980-08-24" with precision set to "month"
    When I convert the date
    Then the EDTF string should be "1980-08"
    Given the date "1980-08-24" with precision set to "year"
    When I convert the date
    Then the EDTF string should be "1980"

  @001 @level0
  Scenario: Date Roundtrips
    When I parse the string "2001-02-03"
    When I convert the date
    Then the EDTF string should be "2001-02-03"
    When I parse the string "2001-02"
    When I convert the date
    Then the EDTF string should be "2001-02"
    When I parse the string "2001"
    When I convert the date
    Then the EDTF string should be "2001"
    When I parse the string "-9909"
    When I convert the date
    Then the EDTF string should be "-9909"
    When I parse the string "0000"
    When I convert the date
    Then the EDTF string should be "0000"

  @002 @level0
  Scenario: DateTime Roundtrips
    When I parse the string "2001-02-03T09:30:01"
    When I convert the date
    Then the EDTF string should be "2001-02-03T09:30:01"
    When I parse the string "2004-01-01T10:10:10Z"
    When I convert the date
    Then the EDTF string should be "2004-01-01T10:10:10+00:00"
    When I parse the string "2004-01-01T10:10:10+05:00"
    When I convert the date
    Then the EDTF string should be "2004-01-01T10:10:10+05:00"

  @004 @level0
  Scenario: Interval Roundtrips
    When I parse the string "1964/2008"
    When I convert the date
    Then the EDTF string should be "1964/2008"
    When I parse the string "2004-06/2006-08"
    When I convert the date
    Then the EDTF string should be "2004-06/2006-08"
    When I parse the string "2004-02-01/2005-02-08"
    When I convert the date
    Then the EDTF string should be "2004-02-01/2005-02-08"
    When I parse the string "2004-02-01/2005-02"
    When I convert the date
    Then the EDTF string should be "2004-02-01/2005-02"
    When I parse the string "2004-02-01/2005"
    When I convert the date
    Then the EDTF string should be "2004-02-01/2005"
    When I parse the string "2005/2006-02"
    When I convert the date
    Then the EDTF string should be "2005/2006-02"

