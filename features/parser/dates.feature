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
      | 0000       | 0000       |

  Scenario: Invalid dates
    Then the following strings should be rejected:
      | xyz           |
      | x2009         |
      | 2004-04-(1)?1 |
