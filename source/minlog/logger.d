module minlog.logger;

import std.stdio;
import std.format;
import std.array;
import std.conv;
import std.datetime;
import std.uni;
import std.range;
import std.algorithm;
import colorize;

enum Verbosity : int {
    debug_ = 5,
    trace = 4,
    info = 3,
    warn = 2,
    error = 1,
    crit = 0,
}

struct Logger {
    public Verbosity verbosity = Verbosity.info;
    public bool use_colors = true;
    public bool use_meta = true;
    public bool meta_timestamp = true;
    public string source = null;

    this(Verbosity verbosity) {
        this.verbosity = verbosity;
    }

    private string formatMeta(Verbosity level) {
        auto time = cast(TimeOfDay) Clock.currTime();
        auto level_str = shortVerbosity(level);

        auto sb = appender!string;
        sb ~= "[";
        if (source !is null) {
            sb ~= source;
            sb ~= ":";
        }
        sb ~= level_str;
        if (meta_timestamp) {
            sb ~= "/";
            sb ~= time.toISOExtString();
        }
        sb ~= "]";

        return sb.data;
    }

    /// writes a message
    public void write_line(string log, Verbosity level) {
        if (level > verbosity)
            return;

        auto level_color = colorFor(level);
        auto meta_str = formatMeta(level);

        auto sb = appender!string;

        if (use_meta) {
            if (use_colors) {
                sb ~= meta_str.color(level_color, colorize.bg.black);
            } else {
                sb ~= meta_str;
            }
            sb ~= " ";
        }

        sb ~= log;

        if (use_colors) {
            cwriteln(sb.data);
        } else {
            writeln(sb.data);
        }

        stdout.flush();
    }

    public void put(T...)(T args, Verbosity level) {
        write_line(format(args), level);
    }

    public void debug_(T...)(T args) {
        put(args, Verbosity.debug_);
    }

    alias dbg = debug_;

    public void trace(T...)(T args) {
        put(args, Verbosity.trace);
    }

    alias trc = trace;

    public void info(T...)(T args) {
        put(args, Verbosity.info);
    }

    alias inf = info;

    public void warn(T...)(T args) {
        put(args, Verbosity.warn);
    }

    alias wrn = warn;

    public void error(T...)(T args) {
        put(args, Verbosity.error);
    }

    alias err = error;

    public void crit(T...)(T args) {
        put(args, Verbosity.crit);
    }

    alias cri = crit;

    private static string shortVerbosity(Verbosity level) {
        switch (level) {
        case Verbosity.debug_:
            return "dbg";
        case Verbosity.trace:
            return "trc";
        case Verbosity.info:
            return "inf";
        case Verbosity.warn:
            return "wrn";
        case Verbosity.error:
            return "err";
        case Verbosity.crit:
            return "crt";
        default:
            return to!string(level);
        }
    }

    private colorize.fg colorFor(Verbosity level) {
        switch (level) {
        case Verbosity.debug_:
            return colorize.fg.light_black;
        case Verbosity.trace:
            return colorize.fg.light_black;
        case Verbosity.info:
            return colorize.fg.green;
        case Verbosity.warn:
            return colorize.fg.yellow;
        case Verbosity.error:
            return colorize.fg.red;
        case Verbosity.crit:
            return colorize.fg.red;
        default:
            return colorize.fg.white;
        }
    }
}
