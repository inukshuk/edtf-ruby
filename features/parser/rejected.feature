Feature: Reject invalid strings
  As a user of EDTF-Ruby
  I want invalid strings to be rejected

  Scenario: Invalid dates
    Then the following strings should be rejected:
      | xyz           |
      | x2009         |
      | -             |
      | 12345         |
      | Y9999         |
      | -Y17E7        |
      | 2016-00       |
      | 2016-13       |
      | 2016-05-00    |
      | 2016-05-32    |
      | 2016-02-30    |
      | 2016-04-31    |
      | 2016-13-XX    |
      | 2004-04-(1)?1 |
      | (2004)?-06    |

  # edtf.js accepts these.
  Scenario: Invalid leap days
    Then the following strings should be rejected:
      | 2015-02-29 |
      | 1999-02-29 |
      | 1900-02-29 |

  Scenario: Invalid date-times
    Then the following strings should be rejected:
      | 2016-05-02T24:00:01        |
      | 2016-05-02T00:61:00        |
      | 2016-05-02T12:00:00-00:00  |
      | 2001-02-03T12:00:00^julian |

  Scenario: Invalid intervals
    Then the following strings should be rejected:
      | open            |
      | ..              |
      | open/open       |
      | unknown/unknown |

  Scenario: Invalid sets
    Then the following strings should be rejected:
      | []     |
      | {}     |
      | [1999} |
      | {1999] |
      | [1999  |
      | {1999  |
