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
      | 2003-23 | 2003-23 | no        | no          |

    @ext-season-uncertainty
    Examples: Uncertain or approximate seasons
      | string   | season  | uncertain | approximate |
      | 2003-23? | 2003-23 | yes       | no          |
      | 2003-23~ | 2003-23 | no        | yes         |
      | 2003-23% | 2003-23 | yes       | yes         |

    @legacy
    Examples: Draft syntax: combined qualifiers
      | string    | season  | uncertain | approximate |
      | 2003-23?~ | 2003-23 | yes       | yes         |

  Scenario Outline: Season qualifiers
    When I parse "<string>"
    Then it should be the season "<season>"
    And the season qualifier should be "<qualifier>"

    @legacy
    Examples: EDTF-Ruby extensions: season qualifiers
      | string           | season  | qualifier |
      | 2003-23^european | 2003-23 | european  |
