Feature: Parse uncertain or approximate dates
  As a user of EDTF-Ruby
  I want to parse dates which are entirely or partly uncertain or approximate

  Scenario Outline: Uncertain or approximate dates
    When I parse "<string>"
    Then it should be the date "<date>"
    And the uncertain parts should be "<uncertain>"
    And the approximate parts should be "<approximate>"

    @level0
    Examples: Dates without qualification
      | string     | date       | uncertain | approximate |
      | 2004-06-01 | 2004-06-01 | none      | none        |
      | 2004-06    | 2004-06    | none      | none        |
      | 2004       | 2004       | none      | none        |

    @level1
    Examples: The whole date is qualified
      | string      | date       | uncertain        | approximate      |
      | 1992?       | 1992       | year             | none             |
      | 1984?       | 1984       | year             | none             |
      | 2004-06?    | 2004-06    | year, month      | none             |
      | 2004-06-11? | 2004-06-11 | year, month, day | none             |
      | 1984~       | 1984       | none             | year             |
      | 2004-06-01? | 2004-06-01 | year, month, day | none             |
      | 2004-06-01~ | 2004-06-01 | none             | year, month, day |
      | 2004-06~    | 2004-06    | none             | year, month      |
      | 2004?       | 2004       | year             | none             |
      | 2004~       | 2004       | none             | year             |

    @level2
    Examples: Parts of the date are qualified
      | string       | date       | uncertain        | approximate      |
      | 2004?-06-11  | 2004-06-11 | year             | none             |
      | 2004-06~-11  | 2004-06-11 | none             | year, month      |
      | 2004-06~-01? | 2004-06-01 | year, month, day | year, month      |
      | 2004~-06-01? | 2004-06-01 | year, month, day | year             |
      | 2004-06?-01~ | 2004-06-01 | year, month      | year, month, day |
      | 2004~-06?-01 | 2004-06-01 | year, month      | year             |
      | 2004-06?-01  | 2004-06-01 | year, month      | none             |
      | 2004?-06-01~ | 2004-06-01 | year             | year, month, day |
      | 2004?-06~-01 | 2004-06-01 | year             | year, month      |
      | 2004?-06-01  | 2004-06-01 | year             | none             |
      | 2004-06~-01  | 2004-06-01 | none             | year, month      |
      | 2004~-06-01  | 2004-06-01 | none             | year             |
      | 2004~-06?    | 2004-06    | year, month      | year             |
      | 2004?-06~    | 2004-06    | year             | year, month      |
      | 2004?-06     | 2004-06    | year             | none             |
      | 2004~-06     | 2004-06    | none             | year             |

    @level1 @legacy
    Examples: Draft syntax: combined qualifiers
      | string       | date       | uncertain        | approximate      |
      | 1984?~       | 1984       | year             | year             |
      | 2004-06-01?~ | 2004-06-01 | year, month, day | year, month, day |
      | 2004-06?~    | 2004-06    | year, month      | year, month      |
      | 2004?~       | 2004       | year             | year             |

    @level2 @legacy
    Examples: Draft syntax: parentheses and combined qualifiers
      | string            | date       | uncertain        | approximate      |
      | 2004-(06)?-11     | 2004-06-11 | month            | none             |
      | 2004-06-(11)~     | 2004-06-11 | none             | day              |
      | 2004-(06)?~       | 2004-06    | month            | month            |
      | 2004-(06-11)?     | 2004-06-11 | month, day       | none             |
      | 2004?-06-(11)~    | 2004-06-11 | year             | day              |
      | (2004-(06)~)?     | 2004-06    | year, month      | month            |
      | 2004-06-(01)~     | 2004-06-01 | none             | day              |
      | (2004-(06-01)~)?  | 2004-06-01 | year, month, day | month, day       |
      | (2004-(06)?-01)~  | 2004-06-01 | month            | year, month, day |
      | 2004-06?-(01)~    | 2004-06-01 | year, month      | day              |
      | 2004~-(06)?-01~   | 2004-06-01 | month            | year, day        |
      | 2004~-(06-(01)~)? | 2004-06-01 | month, day       | year, day        |
      | (2004~-06-(01)~)? | 2004-06-01 | year, month, day | year, day        |
      | 2004~-06?-(01)?~  | 2004-06-01 | year, month, day | year, day        |
      | 2004?-(06-01)?~   | 2004-06-01 | year, month, day | month, day       |
      | (2004-(06)~-01)?  | 2004-06-01 | year, month, day | month            |
      | 2004?-(06)?~-01?  | 2004-06-01 | year, month, day | month            |
      | (2004-06-(01)~)?  | 2004-06-01 | year, month, day | day              |
      | 2004-06?-(01)?~   | 2004-06-01 | year, month, day | day              |
      | 2004-06?~-01      | 2004-06-01 | year, month      | year, month      |
      | 2004~-06?-(01)~   | 2004-06-01 | year, month      | year, day        |
      | 2004?-(06)?~-01~  | 2004-06-01 | year, month      | month, day       |
      | 2004?-(06)?~-01   | 2004-06-01 | year, month      | month            |
      | (2004?-06-(01)?)~ | 2004-06-01 | year, day        | year, month, day |
      | 2004?-06~-(01)?~  | 2004-06-01 | year, day        | year, month, day |
      | 2004?-06~-(01)?   | 2004-06-01 | year, day        | year, month      |
      | 2004?~-06-(01)?~  | 2004-06-01 | year, day        | year, day        |
      | 2004?~-06-(01)?   | 2004-06-01 | year, day        | year             |
      | 2004?-(06-(01)?)~ | 2004-06-01 | year, day        | month, day       |
      | 2004?-(06)~-01?~  | 2004-06-01 | year, day        | month, day       |
      | 2004?-(06)~-01?   | 2004-06-01 | year, day        | month            |
      | 2004?-06-(01)?~   | 2004-06-01 | year, day        | day              |
      | 2004?-06-(01)?    | 2004-06-01 | year, day        | none             |
      | 2004?~-06-(01)~   | 2004-06-01 | year             | year, day        |
      | 2004?~-06-01      | 2004-06-01 | year             | year             |
      | 2004?-(06-01)~    | 2004-06-01 | year             | month, day       |
      | 2004?-(06)~-01    | 2004-06-01 | year             | month            |
      | 2004?-06-(01)~    | 2004-06-01 | year             | day              |
      | (2004-(06-01)?)~  | 2004-06-01 | month, day       | year, month, day |
      | 2004~-(06-01)?~   | 2004-06-01 | month, day       | year, month, day |
      | 2004~-(06)?~-01?  | 2004-06-01 | month, day       | year, month      |
      | 2004~-(06)?-01?~  | 2004-06-01 | month, day       | year, day        |
      | 2004~-(06-01)?    | 2004-06-01 | month, day       | year             |
      | 2004-(06-01)?~    | 2004-06-01 | month, day       | month, day       |
      | 2004-(06)?~-01?   | 2004-06-01 | month, day       | month            |
      | 2004-(06-(01)~)?  | 2004-06-01 | month, day       | day              |
      | 2004-(06)?-01?~   | 2004-06-01 | month, day       | day              |
      | 2004-(06-01)?     | 2004-06-01 | month, day       | none             |
      | 2004~-(06)?~-01~  | 2004-06-01 | month            | year, month, day |
      | 2004~-(06)?~-01   | 2004-06-01 | month            | year, month      |
      | 2004~-(06)?-01    | 2004-06-01 | month            | year             |
      | 2004-(06)?~-01~   | 2004-06-01 | month            | month, day       |
      | 2004-(06)?~-01    | 2004-06-01 | month            | month            |
      | 2004-(06)?-01~    | 2004-06-01 | month            | day              |
      | 2004-(06)?-01     | 2004-06-01 | month            | none             |
      | (2004-06-(01)?)~  | 2004-06-01 | day              | year, month, day |
      | 2004-06~-(01)?~   | 2004-06-01 | day              | year, month, day |
      | 2004-06~-(01)?    | 2004-06-01 | day              | year, month      |
      | 2004~-06-(01)?~   | 2004-06-01 | day              | year, day        |
      | 2004~-06-(01)?    | 2004-06-01 | day              | year             |
      | 2004-(06-(01)?)~  | 2004-06-01 | day              | month, day       |
      | 2004-(06)~-01?~   | 2004-06-01 | day              | month, day       |
      | 2004-(06)~-01?    | 2004-06-01 | day              | month            |
      | 2004-06-(01)?~    | 2004-06-01 | day              | day              |
      | 2004-06-(01)?     | 2004-06-01 | day              | none             |
      | 2004~-06-(01)~    | 2004-06-01 | none             | year, day        |
      | 2004-(06-01)~     | 2004-06-01 | none             | month, day       |
      | 2004-(06)~-01     | 2004-06-01 | none             | month            |
      | 2004?-(06)?~      | 2004-06    | year, month      | month            |
      | 2004?~-06         | 2004-06    | year             | year             |
      | 2004?-(06)~       | 2004-06    | year             | month            |
      | (2004-(06)?)~     | 2004-06    | month            | year, month      |
      | 2004~-(06)?~      | 2004-06    | month            | year, month      |
      | 2004~-(06)?       | 2004-06    | month            | year             |
      | 2004-(06)?        | 2004-06    | month            | none             |
      | 2004-(06)~        | 2004-06    | none             | month            |
