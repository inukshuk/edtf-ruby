Feature: Parse sets
  As a user of EDTF-Ruby
  I want to parse EDTF sets: one of a set, or all of a list

  Scenario Outline: Sets
    When I parse "<string>"
    Then it should be "<kind>" the members "<members>"
    And the open end should be "<open>"

    @level2
    Examples:
      | string                      | kind   | members                      | open    |
      | {1667,1668,1670..1672}      | all of | 1667, 1668, 1670, 1671, 1672 | none    |
      | {1960,1961-12}              | all of | 1960, 1961-12                | none    |
      | [1667,1668,1670..1672]      | one of | 1667, 1668, 1670, 1671, 1672 | none    |
      | [..1760-12-03]              | one of | 1760-12-03                   | earlier |
      | [1760-12..]                 | one of | 1760-12                      | later   |
      | [1760-01,1760-02,1760-12..] | one of | 1760-01, 1760-02, 1760-12    | later   |
      | [..1984]                    | one of | 1984                         | earlier |
      | [1760..]                    | one of | 1760                         | later   |
      | {..1984}                    | all of | 1984                         | earlier |
      | {1760..}                    | all of | 1760                         | later   |

    # Quirk: ISO 8601-2 allows no spaces,
    # but EDTF-Ruby and edtf.js accept them.
    @level2
    Examples: Spaces around commas
      | string                        | kind   | members                      | open  |
      | {1667,1668, 1670..1672}       | all of | 1667, 1668, 1670, 1671, 1672 | none  |
      | {1960, 1961-12}               | all of | 1960, 1961-12                | none  |
      | [1667,1668, 1670..1672]       | one of | 1667, 1668, 1670, 1671, 1672 | none  |
      | [1760-01, 1760-02, 1760-12..] | one of | 1760-01, 1760-02, 1760-12    | later |
      | [1667, 1672-12]               | one of | 1667, 1672-12                | none  |
      | {1667, 1670..1672}            | all of | 1667, 1670, 1671, 1672       | none  |
      | {1960 ,  1961-12}             | all of | 1960, 1961-12                | none  |
      | [1984, 1990?]                 | one of | 1984, 1990?                  | none  |

    @level2
    Examples: Qualified members
      | string       | kind   | members     | open |
      | [1984,1990?] | one of | 1984, 1990? | none |
      | {1984~,1985} | all of | 1984~, 1985 | none |
