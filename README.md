# Logtee
A program which writes data produced by its child program to stdout and forwards it to another service at the same time. 

## Motivation 
We want to forward the logs which are produced by a service to logstash and to mongodb as well. 

## How it works
Logtee executes a child program. The latter writes the logs to stdout of the parent program (logtee). At the same time, the logs are being filtered and consumed by another child program (forwarder), which ingests them into mongodb.

## Usage
- start mongodb with ```docker-compose up``` 
- write the data produced by your child program (in this example '{}') to stdout and to mongodb ```src/logtee.d --forwarder features/support/mongo/forward -- echo {}```.
