#!/usr/bin/env rdmd
import std.stdio : File, stdout, write, writeln;
import std.getopt;
import core.time : dur;
import std.process : Redirect, pipeProcess, wait, Pid;
import std.datetime : Clock;
import std.string : empty, split, startsWith;
import std.json : parseJSON, JSONValue;
import core.stdc.signal : signal, SIGTERM;

/**
  TODO:
  pv
  github workflow
  stderr
  stdin an Program weiterleiten
  README
  diagram
*/

void onLine(T)(T line, File forwarder)
{
    if (!line.startsWith('{'))
    {
        return;
    }

    static if (!__traits(compiles, import("log_filter")))
    {
        pragma(msg, "'log_filter' file is either not present or cannot be compiled.");
        static assert(false, "no customized filter defined");
    }
    const json = line.parseJSON;
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

    auto child = pipeProcess(extraArgs, Redirect.stdout | Redirect.stderrToStdout);
    childPid = child.pid.processID;

    auto forwarder = pipeProcess(forwardTo.split(' '), Redirect.stdin);
    forwarderPid = forwarder.pid.processID;

    SIGTERM.signal(&signalHandler);

    foreach (line; child.stdout.byLineCopy)
    {
        stdout.write(line);
        onLine(line, forwarder.stdin);
    }
    return child.pid.wait;
    scope (exit)
    {
        child.pid.wait;
    }
}
