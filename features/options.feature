Feature: Forwards

  Scenario: A
    When I start "rdmd -Jfeatures/support/ src/logtee.d --plotStart -- true"
    Then I get
      """
      {"timestamp": "2021-\d+-\d+T\d+:\d+:.*", "message": "start"}
      """

  Scenario Outline: requires program
    When I start "rdmd -Jfeatures/support/ src/<command>"
    Then it fails

    Examples: invalid calls
      | command     |
      | logtee.d -- |
      | logtee.d    |
