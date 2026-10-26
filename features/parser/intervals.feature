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
