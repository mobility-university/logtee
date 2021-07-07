# Logtee
A program which writes data produced by its child program to stdout and forwards it to another service at the same time. 

## Motivation 
We want to forward the logs which are produced by a service to logstash and to mongodb as well. 

## How it works
Logtee executes a child program and intercepts the stdout of the child.
After that, it redirects it to stdout of the parent (logtee) and to a provided custom filter method. The latter is located under ```/support``` and manipulates the intercepted data. The manipulated data is forwarded to the stdin of the forwarder which is located under ```/support``` as well. Needed input for the child program can be provided through the stdin of the logtee. The stderr of the child and forwarder are redirected to stderr of the parent.

## Usage
### General
```rdmd -Jfeatures/support src/logtee.d --forwarder features/support/forward -- executable-child-program```.
### Mongo
- start mongodb
- provide forward
- write the data of your child program (in this example '{}') to stdout and to mongodb ```src/logtee.d --forwarder features/support/mongo/forward -- echo {}```.


## TODO
- stdin to stdin geht noch nicht
- stderrs nicht zu stderr verbunden
- Forwarder oder forward? Datei umbenennen?