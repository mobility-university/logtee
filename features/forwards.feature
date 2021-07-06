Feature: Forwards

  Scenario: stdout
    When I start "rdmd -Jfeatures/support/ src/logtee.d --forwarder true -- echo hello world"
    Then I get
      """
      hello world
      """

  Scenario: forwarding json
    When I start "rdmd -Jfeatures/support/ src/logtee.d --forwarder features/support/forward -- echo {}"
    Then I get
      """
      {}
      """
    And the following gets forwarded
      """
      custom json filter
      """

  Scenario: exit code
    When I start "rdmd -Jfeatures/support/ src/logtee.d --forwarder true -- false"
    Then it fails

  Scenario Outline: signals
    Given "rdmd -Jfeatures/support/ src/logtee.d --forwarder true --plotStart -- features/support/print_signal" is started
    When <signal> is sent
    Then the program stops

    Examples: supported signals
      | signal   |
      | sig term |
      | sig kill |

  Scenario: import into mongo
    Given I started the mongo db
    When I start "rdmd -Jfeatures/support/mongo src/logtee.d --forwarder features/support/mongo/forward -- echo {}"
    Then the line is inserted into mongo