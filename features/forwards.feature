Feature: Forwards

  Scenario: stdout
    When I start "/work/logtee -- echo hello world"
    Then I get
      """
      hello world
      """

  Scenario: exit code
    When I start "/work/logtee -- false"
    Then it fails

  Scenario Outline: signals
    Given "src/logtee.d --plotStart -- features/support/print_signal" is started
    When <signal> is sent
    Then the program stops

    Examples: supported signals
      | signal   |
      | sig term |
      | sig kill |

  Scenario: forwarder
     When I start "/work/logtee --forward 'cat - > foo.json' -- echo {}"
     Then I get
      """
      {}
      """
    And I get logs.json
      """
      huhu
      """
