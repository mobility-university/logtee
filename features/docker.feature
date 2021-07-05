Feature: Docker

  Scenario: Usage
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

  Scenario: Static binary
    Given a customized logging filter is configured like
      """
      forwarder.writeln("customized");
      """
    Given a dockerfile stage with
      """
      FROM dlanguage/ldc

      COPY src/ /work
      COPY log_filter /work
      WORKDIR /work
      RUN ldc2 logtee.d -J. -static
      """
    When building the docker image
    Then there is a binary under /work/logtee

  Scenario: Log filter
    Given a customized logging filter is configured like
      """
      forwarder.writeln("customized");
      """
    Given a dockerfile stage with
      """
      FROM dlanguage/dmd

      COPY src/ /work
      COPY log_filter /work
      WORKDIR /work
      RUN dmd -J. logtee.d -oflogtee
      """
    When building the docker image
    Then there is a binary under /work/logtee
