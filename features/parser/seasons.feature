Feature: Parse seasons
  As a user of EDTF-Ruby
  I want to parse EDTF season strings

  Scenario Outline: Seasons
    When I parse "<string>"
    Then it should be the season "<season>"
    And it should be uncertain: <uncertain>
    And it should be approximate: <approximate>

    @level1
    Examples: Seasons
      | string  | season  | uncertain | approximate |
      | 2001-21 | 2001-21 | no        | no          |
      | 2001-22 | 2001-22 | no        | no          |
      | 2001-23 | 2001-23 | no        | no          |
      | 2001-24 | 2001-24 | no        | no          |
      | 2003-23 | 2003-23 | no        | no          |

    @level2
    Examples: Sub-year groupings
      | string  | season  | uncertain | approximate |
      | 2001-25 | 2001-25 | no        | no          |
      | 2001-29 | 2001-29 | no        | no          |
      | 2001-33 | 2001-33 | no        | no          |
      | 2001-37 | 2001-37 | no        | no          |
      | 2001-40 | 2001-40 | no        | no          |
      | 2001-41 | 2001-41 | no        | no          |

    @ext-season-uncertainty
    Examples: Uncertain or approximate seasons
      | string   | season  | uncertain | approximate |
      | 2001-21? | 2001-21 | yes       | no          |
      | 2001-21~ | 2001-21 | no        | yes         |
      | 2001-21% | 2001-21 | yes       | yes         |
      | 2003-23? | 2003-23 | yes       | no          |
      | 2003-23~ | 2003-23 | no        | yes         |
      | 2003-23% | 2003-23 | yes       | yes         |
      | 2001?-21 | 2001-21 | yes       | no          |
      | 2001-~21 | 2001-21 | no        | yes         |

    @legacy
    Examples: Draft syntax: combined qualifiers
      | string    | season  | uncertain | approximate |
      | 2003-23?~ | 2003-23 | yes       | yes         |

  @ext-season-uncertainty
  Scenario Outline: Qualified parts of seasons
    When I parse "<string>"
    Then it should be the season "<season>"
    And the uncertain parts should be "<uncertain>"
    And the approximate parts should be "<approximate>"

    Examples:
      | string     | season  | uncertain   | approximate |
      | 2001?-21   | 2001-21 | year        | none        |
      | ?2001-21   | 2001-21 | year        | none        |
      | 2001-?21   | 2001-21 | month       | none        |
      | 2001-21?   | 2001-21 | year, month | none        |
      | ?2001-~21  | 2001-21 | year        | month       |
      | 2001~-21?  | 2001-21 | year, month | year        |

  @ext-season-uncertainty
  Scenario Outline: Seasons with unspecified year digits
    When I parse "<string>"
    Then it should span "<from>" to "<to>"
    And its EDTF string should be "<string>"

    Examples:
      | string   | from        | to          |
      | 200X-21  | 2000-03-01  | 2009-05-31  |
      | 20XX-24  | 2000-12-01  | 2100-02-28  |
      | -000X-21 | -0009-03-01 | -0001-05-31 |

  @ext-season-intervals
  Scenario Outline: Season intervals
    Given the extensions are on
    When I parse "<string>"
    Then it should span "<from>" to "<to>"
    And its EDTF string should be "<string>"

    Examples:
      | string          | from       | to         |
      | 2001-21/2002-22 | 2001-03-01 | 2002-08-31 |
      | 2001-24/2002-21 | 2001-12-01 | 2002-05-31 |
      | 2001-33/2001-36 | 2001-01-01 | 2001-12-31 |

  # The spec assigns no months to the seasons 21-24 or to the
  # hemisphere seasons 25-32; edtf.js maps 21-24 to quarters instead.
  Scenario Outline: Season bounds
    When I parse "<string>"
    Then it should span "<from>" to "<to>"

    @level1
    Examples: Seasons
      | string  | from       | to         |
      | 2001-21 | 2001-03-01 | 2001-05-31 |
      | 2001-22 | 2001-06-01 | 2001-08-31 |
      | 2001-23 | 2001-09-01 | 2001-11-30 |
      | 2001-24 | 2001-12-01 | 2002-02-28 |

    @level2
    Examples: Hemisphere seasons
      | string  | from       | to         |
      | 2001-25 | 2001-03-01 | 2001-05-31 |
      | 2001-28 | 2001-12-01 | 2002-02-28 |
      | 2001-29 | 2001-09-01 | 2001-11-30 |
      | 2001-30 | 2001-12-01 | 2002-02-28 |
      | 2001-31 | 2001-03-01 | 2001-05-31 |
      | 2001-32 | 2001-06-01 | 2001-08-31 |

    @level2
    Examples: Quarters, quadrimesters and semesters
      | string  | from       | to         |
      | 2001-33 | 2001-01-01 | 2001-03-31 |
      | 2001-37 | 2001-01-01 | 2001-04-30 |
      | 2001-38 | 2001-05-01 | 2001-08-31 |
      | 2001-39 | 2001-09-01 | 2001-12-31 |
      | 2001-40 | 2001-01-01 | 2001-06-30 |
      | 2001-41 | 2001-07-01 | 2001-12-31 |

  Scenario Outline: Season qualifiers
    When I parse "<string>"
    Then it should be the season "<season>"
    And the parse result should record the qualifier "<qualifier>"

    # Hemisphere qualifiers become ISO 8601-2 hemisphere seasons.
    @legacy
    Examples: Draft syntax: season qualifiers
      | string           | season  | qualifier |
      | 2003-23^european | 2003-23 | european  |
      | 2001-21^southern | 2001-29 | southern  |
      | 2001-23^northern | 2001-27 | northern  |
