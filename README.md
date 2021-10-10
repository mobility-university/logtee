# Logtee

A program which forwards stdout from a child and applies custom forward logic. 

## Motivation 

Intercepting logs can be difficult. Full blown solutions like k8s services meshes exists. We aimed for a simple solution.

## How it works
![architecture](architecture.png?raw=true "Architecture")

Logtee executes a child program and intercepts the stdout of the child.
It redirects the stdout of the parent (logtee) and applies custom forward logic.
Forward logic could be filtering specific events.

## Usage

### General

```rdmd -Jfeatures/support src/logtee.d --forwarder features/support/forward -- executable-child-program```.

### Mongo

- start mongodb
- provide forward
- write the data of your child program (in this example '{}') to stdout and to mongodb
  ```src/logtee.d --forwarder features/support/mongo/forward -- echo {}```.

## TODO

- forward stdin
- connect stderr
