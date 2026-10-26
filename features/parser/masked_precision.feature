Feature: Parse masked precision
  As a user of EDTF-Ruby
  I want to parse decades and centuries written with masked precision

  Scenario Outline: Decades and centuries
    When I parse "<string>"
    Then it should span "<from>" to "<to>"

    @level2 @legacy
    Examples: Draft syntax: x for masked digits
      | string | from       | to         |
      | 196x   | 1960-01-01 | 1969-12-31 |
      | 19xx   | 1900-01-01 | 1999-12-31 |
      | 198x   | 1980-01-01 | 1989-12-31 |
      | 18xx   | 1800-01-01 | 1899-12-31 |
