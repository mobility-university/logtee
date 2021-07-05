#!/usr/bin/env rdmd
import std.stdio;
import std.getopt;
import core.time : dur;
import std.process : Redirect, pipeProcess, wait, Pid;
import std.datetime;
import std.array;
import std.string;
import std.json : parseJSON, JSONValue;
import core.stdc.signal : signal, SIGTERM, SIGSEGV, SIGINT, SIGILL, SIGFPE, SIGABRT;

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

void onLine(T)(T line, File forwarder)
{
    if (!line.startsWith('{'))
    {
        return;
    }

    static if (!__traits(compiles, import("log_filter")))
    {
        pragma(msg, "please provide a 'log_filter' file to filter the logs.");
        static assert(false, "no customized filter defined");
    }
    auto json = line.parseJSON;
    mixin(import("log_filter"));
}

__gshared int childPid = 0;
__gshared int forwarderPid = 0;

extern (C) void signalHandler(int num) nothrow @nogc @system
{
    foreach (pid; [childPid, forwarderPid])
    {
        assert(pid != 0);
        version (Posix)
        {
            import core.sys.posix.signal : kill;

            pid.kill(num);
        }
        else
        {
            static assert(false, "not supported");
        }
    }
}

int main(string[] args)
{
    bool plotStart = false;
    string forwardTo;

    auto options = getopt(args, "plotStart", &plotStart, std.getopt.config.required,
            "forwarder", "where to forward filtered events to", &forwardTo);
    string[] extraArgs = args[1 .. $];

    if (options.helpWanted || extraArgs.empty)
    {
        defaultGetoptPrinter("logtee - forward specific logs", options.options);
        return 1;
    }

    if (plotStart)
    {
        stdout.writefln!`{"timestamp": "%s", "message": "start"}`(Clock.currTime().toISOExtString);
    }

    auto pipes = pipeProcess(extraArgs, Redirect.stdout | Redirect.stderrToStdout);
    childPid = pipes.pid.processID;

    auto forwarder = pipeProcess(forwardTo.split(' '), Redirect.stdin);
    forwarderPid = forwarder.pid.processID;

    SIGTERM.signal(&signalHandler);
    //forwarder.stdin.write("abc");

    foreach (line; pipes.stdout.byLineCopy)
    {
        stdout.write(line);
        onLine(line, forwarder.stdin);
    }
    return pipes.pid.wait;
    scope (exit)
    {
        pipes.pid.wait;
    }
}
