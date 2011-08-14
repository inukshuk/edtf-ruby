Feature: Parse masked precision strings

  As a user of edtf-ruby
  I want to parse masked precision strings
  
  Scenario Outline: Masked precision strings
    When I parse the string "<string>"
    Then the duration should range from "<start>" to "<end>"
  
  @level2 @2041
  Scenarios: decades and centuries
    | string | start | end  |
    | 196x   | 1960  | 1970 |
    | 19xx   | 1900  | 2000 |