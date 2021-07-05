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
    Then it fails with
      """
      please provide a 'log_filter' file to filter the logs.
      """

  Scenario: Data Ingestion
    Given a customized logging filter is configured like
      """
      import std.stdio : stdout;

      stdout.writeln("customized");
      """
    Given a dockerfile stage with
      """
      FROM dlanguage/dmd

      COPY src/ /work
      COPY log_filter /work
      WORKDIR /work
      RUN dmd -J. *.d -oflogtee
      """
    When building the docker image
    Then there is a binary under /work/logtee
