Feature: Forwards

  Scenario: A
    When I start "/work/logtee --plotStart -- true"
    Then I get
      """
      {"timestamp": "2021-\d+-\d+T\d+:\d+:.*", "message": "start"}
      """

  Scenario Outline: requires program
    When I start "/work/<command>"
    Then it fails

    Examples: invalid calls
      | command   |
      | logtee -- |
      | logtee    |
