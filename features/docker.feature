Feature: Docker

  Scenario:
    Given a dockerfile stage with
      """
      FROM dlanguage/dmd

      COPY src/ /work
      WORKDIR /work
      RUN dmd logtee.d
      """
    When building the docker image
    Then there is a binary under /work/logtee

  Scenario: Data Ingestion
    Given a user specific logging
      """
      import std.json;
      import std.stdio;
      void onLineJson(JSONValue value) {
        stdout.writeln("huhu");
      }
      """
    And a dockerfile stage with
      """
      FROM dlanguage/dmd

      COPY src/ /work
      COPY user_specific.d /work
      WORKDIR /work
      RUN dmd logtee.d user_specific.d
      """
    When building the docker image
    Then there is a binary under /work/logtee
    When I start "/work/logtee -- echo {}"
    Then I get
      """
      {}huhu
      """