Feature: Print uncertain or approximate dates
  As a Ruby programmer
  I want to convert uncertain or approximate dates to EDTF strings

  Scenario Outline: Uncertain or approximate dates
    Given the date "<date>"
    When the uncertain parts are "<uncertain>"
    And the approximate parts are "<approximate>"
    Then its EDTF string should be "<edtf>"

    @level2
    Examples:
      | date       | uncertain        | approximate      | edtf          |
      | 2004-06-01 | year, month, day | year, month, day | 2004-06-01%   |
      | 2004-06-01 | year, month, day | year, month      | 2004-06~-01?  |
      | 2004-06-01 | year, month, day | year, day        | 2004~-06-~01? |
      | 2004-06-01 | year, month, day | year             | 2004~-06-01?  |
      | 2004-06-01 | year, month, day | month, day       | 2004-~06-~01? |
      | 2004-06-01 | year, month, day | month            | 2004-~06-01?  |
      | 2004-06-01 | year, month, day | day              | 2004-06-~01?  |
      | 2004-06-01 | year, month, day | none             | 2004-06-01?   |
      | 2004-06-01 | year, month      | year, month, day | 2004-06?-01~  |
      | 2004-06-01 | year, month      | year, month      | 2004-06%-01   |
      | 2004-06-01 | year, month      | year, day        | 2004~-06?-~01 |
      | 2004-06-01 | year, month      | year             | 2004~-06?-01  |
      | 2004-06-01 | year, month      | month, day       | 2004-~06?-~01 |
      | 2004-06-01 | year, month      | month            | 2004-~06?-01  |
      | 2004-06-01 | year, month      | day              | 2004-06?-~01  |
      | 2004-06-01 | year, month      | none             | 2004-06?-01   |
      | 2004-06-01 | year, day        | year, month, day | 2004?-06-?01~ |
      | 2004-06-01 | year, day        | year, month      | 2004?-06~-?01 |
      | 2004-06-01 | year, day        | year, day        | 2004%-06-%01  |
      | 2004-06-01 | year, day        | year             | 2004%-06-?01  |
      | 2004-06-01 | year, day        | month, day       | 2004?-~06-%01 |
      | 2004-06-01 | year, day        | month            | 2004?-~06-?01 |
      | 2004-06-01 | year, day        | day              | 2004?-06-%01  |
      | 2004-06-01 | year, day        | none             | 2004?-06-?01  |
      | 2004-06-01 | year             | year, month, day | 2004?-06-01~  |
      | 2004-06-01 | year             | year, month      | 2004?-06~-01  |
      | 2004-06-01 | year             | year, day        | 2004%-06-~01  |
      | 2004-06-01 | year             | year             | 2004%-06-01   |
      | 2004-06-01 | year             | month, day       | 2004?-~06-~01 |
      | 2004-06-01 | year             | month            | 2004?-~06-01  |
      | 2004-06-01 | year             | day              | 2004?-06-~01  |
      | 2004-06-01 | year             | none             | 2004?-06-01   |
      | 2004-06-01 | month, day       | year, month, day | 2004-?06-?01~ |
      | 2004-06-01 | month, day       | year, month      | 2004-?06~-?01 |
      | 2004-06-01 | month, day       | year, day        | 2004~-?06-%01 |
      | 2004-06-01 | month, day       | year             | 2004~-?06-?01 |
      | 2004-06-01 | month, day       | month, day       | 2004-%06-%01  |
      | 2004-06-01 | month, day       | month            | 2004-%06-?01  |
      | 2004-06-01 | month, day       | day              | 2004-?06-%01  |
      | 2004-06-01 | month, day       | none             | 2004-?06-?01  |
      | 2004-06-01 | month            | year, month, day | 2004-?06-01~  |
      | 2004-06-01 | month            | year, month      | 2004-?06~-01  |
      | 2004-06-01 | month            | year, day        | 2004~-?06-~01 |
      | 2004-06-01 | month            | year             | 2004~-?06-01  |
      | 2004-06-01 | month            | month, day       | 2004-%06-~01  |
      | 2004-06-01 | month            | month            | 2004-%06-01   |
      | 2004-06-01 | month            | day              | 2004-?06-~01  |
      | 2004-06-01 | month            | none             | 2004-?06-01   |
      | 2004-06-01 | day              | year, month, day | 2004-06-?01~  |
      | 2004-06-01 | day              | year, month      | 2004-06~-?01  |
      | 2004-06-01 | day              | year, day        | 2004~-06-%01  |
      | 2004-06-01 | day              | year             | 2004~-06-?01  |
      | 2004-06-01 | day              | month, day       | 2004-~06-%01  |
      | 2004-06-01 | day              | month            | 2004-~06-?01  |
      | 2004-06-01 | day              | day              | 2004-06-%01   |
      | 2004-06-01 | day              | none             | 2004-06-?01   |
      | 2004-06-01 | none             | year, month, day | 2004-06-01~   |
      | 2004-06-01 | none             | year, month      | 2004-06~-01   |
      | 2004-06-01 | none             | year, day        | 2004~-06-~01  |
      | 2004-06-01 | none             | year             | 2004~-06-01   |
      | 2004-06-01 | none             | month, day       | 2004-~06-~01  |
      | 2004-06-01 | none             | month            | 2004-~06-01   |
      | 2004-06-01 | none             | day              | 2004-06-~01   |
      | 2004-06-01 | none             | none             | 2004-06-01    |
      | 2004-06    | year, month      | year, month      | 2004-06%      |
      | 2004-06    | year, month      | year             | 2004~-06?     |
      | 2004-06    | year, month      | month            | 2004-~06?     |
      | 2004-06    | year, month      | none             | 2004-06?      |
      | 2004-06    | year             | year, month      | 2004?-06~     |
      | 2004-06    | year             | year             | 2004%-06      |
      | 2004-06    | year             | month            | 2004?-~06     |
      | 2004-06    | year             | none             | 2004?-06      |
      | 2004-06    | month            | year, month      | 2004-?06~     |
      | 2004-06    | month            | year             | 2004~-?06     |
      | 2004-06    | month            | month            | 2004-%06      |
      | 2004-06    | month            | none             | 2004-?06      |
      | 2004-06    | none             | year, month      | 2004-06~      |
      | 2004-06    | none             | year             | 2004~-06      |
      | 2004-06    | none             | month            | 2004-~06      |
      | 2004-06    | none             | none             | 2004-06       |
      | 2004       | year             | year             | 2004%         |
      | 2004       | year             | none             | 2004?         |
      | 2004       | none             | year             | 2004~         |
      | 2004       | none             | none             | 2004          |
