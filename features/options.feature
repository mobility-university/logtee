Feature: Options

  Scenario: plots start
    When I start "rdmd -Jfeatures/support/ src/logtee.d --forwarder true --plotStart -- true"
    Then I get
      """
      {"timestamp": "2021-\d+-\d+T\d+:\d+:.*", "message": "start"}
      """

  Scenario Outline: requires program
    When I start "rdmd -Jfeatures/support/ src/logtee.d --forwarder true <arguments>"
    Then it fails

    Examples: invalid calls
      | arguments |
      | --        |
      | -- -          |
