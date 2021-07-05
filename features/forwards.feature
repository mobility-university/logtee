Feature: Forwards

  Scenario: stdout
    When I start "rdmd -Jfeatures/support/ src/logtee.d -- echo hello world"
    Then I get
      """
      hello world
      """

  Scenario: exit code
    When I start "rdmd -Jfeatures/support/ src/logtee.d -- false"
    Then it fails

  Scenario Outline: signals
    Given "rdmd -Jfeatures/support/ src/logtee.d --plotStart -- features/support/print_signal" is started
    When <signal> is sent
    Then the program stops

    Examples: supported signals
      | signal   |
      | sig term |
      | sig kill |
