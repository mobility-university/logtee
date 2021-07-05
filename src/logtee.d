#!/usr/bin/env rdmd
import std.stdio;
import std.getopt;
import core.time : dur;
import std.process : Redirect, pipeProcess, wait, Pid;
import std.datetime;
import std.array;
import std.string;
import core.stdc.signal : signal, SIGTERM, SIGSEGV, SIGINT, SIGILL, SIGFPE, SIGABRT;

//import core.sys.posix.signal : kill;

/**
  TODO:
  forward sigterm
  ldc2 - static binary
  mongo?
  pv
  github workflow
  stderr
  stdin an Program weiterleiten

*/

void onLine(T)(T line)
{
    if (line.startsWith('{'))
    {
        import std.json;


        static if(__traits(compiles, foo)) {
            import user_specific: onLineJson;
            auto json = line.parseJSON;
            //json
            //static assert (compiles(onLineJson(json))) + Hilfe
            onLineJson(json);
        }
        
        
        
       
    }
}

__gshared int childPid = 0;

extern (C) void handler(int num) nothrow @nogc @system
{
    printf("Caught signal %d\n", num);
    assert(childPid != 0);
    version (Posix)
    {
        import core.sys.posix.signal : kill;

        childPid.kill(num);
        // while (true) {}
    }
    else
    {
        static assert(false, "not supported");
    }
}

int main(string[] args)
{
    bool plotStart = false;
    bool forward = false;

    auto options = getopt(args, "plotStart", &plotStart, "forward", &forward);
    string[] extraArgs = args[1 .. $];
    string extraArgs2;

    if (options.helpWanted || extraArgs.empty)
    {
        defaultGetoptPrinter("logtee - forward specific logs", options.options);
        return 1;
    }

    if (plotStart)
    {
        stdout.writefln!`{"timestamp": "%s", "message": "start"}`(Clock.currTime().toISOExtString);
    }

    if (forward) {
        extraArgs2 = extraArgs[0];
        writeln(extraArgs2);
        auto forwarder = pipeProcess(extraArgs2, Redirect.stdout | Redirect.stderrToStdout);
        childPid = forwarder.pid.processID;
    }
    extraArgs = extraArgs[1 .. $];
    writeln(extraArgs);

    auto pipes = pipeProcess(extraArgs, Redirect.stdout | Redirect.stderrToStdout);
    childPid = pipes.pid.processID;


    signal(SIGTERM, &handler);

    foreach (line; pipes.stdout.byLineCopy)
    {
        stdout.write(line);
        onLine(line);
    }
    return pipes.pid.wait;
    scope (exit)
    {
        pipes.pid.wait;
    }
}
