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

enum LoggerVerbosity : int {
    annoying = 8,
    pedantic = 7,
    debug_ = 6,
    trace = 5,
    verbose = 4,
    info = 3,
    warn = 2,
    error = 1,
    crit = 0,
}

enum LoggerFormat {
    raw,
    basic,
    standard,
    fancy,
}

struct Logger {
    public LoggerVerbosity verbosity = LoggerVerbosity.info;
    private LoggerFormat _format = LoggerFormat.standard;
    private string _source = null;

    this(LoggerVerbosity verbosity) {
        this.verbosity = verbosity;
    }

    private string format_meta(LoggerVerbosity level) {
        auto level_color = color_for(level);
        auto level_shortname = short_verbosity(level);
        auto time = cast(TimeOfDay) Clock.currTime();

        auto sb = appender!string;

        switch (_format) {
        case LoggerFormat.raw:
            sb ~= "";
            break;
        case LoggerFormat.basic:
            sb ~= ("[" ~ level_shortname ~ "]")
                .color(level_color, colorize.bg.black) ~ " ";
            break;
        case LoggerFormat.standard:
            auto sb0 = appender!string;
            sb0 ~= "[";
            if (_source !is null) {
                sb0 ~= _source;
                sb0 ~= ":";
            }
            sb0 ~= level_shortname;
            if (true) {
                sb0 ~= "/";
                sb0 ~= time.toISOExtString();
            }
            sb0 ~= "]";
            sb ~= sb0.data.color(level_color, colorize.bg.black) ~ " ";
            break;
        case LoggerFormat.fancy:
            if (_source !is null) {
                auto sb0 = appender!string;
                sb0 ~= "[";
                sb0 ~= _source;
                sb0 ~= "]";
                sb ~= sb0.data.color(colorize.fg.light_black, colorize.bg.black) ~ " ";
            }
            auto sb1 = appender!string;
            sb1 ~= "[";
            sb1 ~= time.toISOExtString().color(colorize.fg.light_black, colorize.bg.black);
            sb1 ~= " ";
            sb1 ~= level_shortname.color(level_color, colorize.bg.black);
            sb1 ~= "]";
            sb ~= sb1.data;
            sb ~= " ";
            break;
        default:
            assert(0, "invalid format");
        }

        return sb.data;
    }

    private static string short_verbosity(LoggerVerbosity level) {
        switch (level) {
        case LoggerVerbosity.annoying:
            return "ayg";
        case LoggerVerbosity.pedantic:
            return "ped";
        case LoggerVerbosity.debug_:
            return "dbg";
        case LoggerVerbosity.trace:
            return "trc";
        case LoggerVerbosity.verbose:
            return "vrb";
        case LoggerVerbosity.info:
            return "inf";
        case LoggerVerbosity.warn:
            return "wrn";
        case LoggerVerbosity.error:
            return "err";
        case LoggerVerbosity.crit:
            return "crt";
        default:
            return to!string(level);
        }
    }

    private colorize.fg color_for(LoggerVerbosity level) {
        switch (level) {
        case LoggerVerbosity.annoying:
        case LoggerVerbosity.pedantic:
        case LoggerVerbosity.debug_:
            return colorize.fg.light_black;
        case LoggerVerbosity.trace:
            return colorize.fg.light_white;
        case LoggerVerbosity.verbose:
            return colorize.fg.light_blue;
        case LoggerVerbosity.info:
            return colorize.fg.green;
        case LoggerVerbosity.warn:
            return colorize.fg.yellow;
        case LoggerVerbosity.error:
            return colorize.fg.red;
        case LoggerVerbosity.crit:
            return colorize.fg.magenta;
        default:
            return colorize.fg.white;
        }
    }

    public void set_format(LoggerFormat format) {
        this._format = format;
    }

    public Logger for_source(string source) {
        // copy the logger and set the source
        auto dup = this;
        dup._source = source;
        return dup;
    }

    /** write a line to the log */
    private void write_line(string log_str, LoggerVerbosity level) {
        auto sb = appender!string;

        auto meta_str = format_meta(level);
        sb ~= meta_str;
        sb ~= log_str;

        cwriteln(sb.data);

        stdout.flush();
    }

    /** write a line with a given verbosity */
    public void put(T...)(lazy T args, LoggerVerbosity level) {
        version (null_logger) {
            return;
        }
        if (level > verbosity)
            return;
        write_line(format(args), level);
    }

    public void annoying(T...)(lazy T args) {
        put(args, LoggerVerbosity.annoying);
    }

    alias ayg = annoying;

    public void pedantic(T...)(lazy T args) {
        put(args, LoggerVerbosity.pedantic);
    }

    alias ped = pedantic;

    public void debug_(T...)(lazy T args) {
        put(args, LoggerVerbosity.debug_);
    }

    alias dbg = debug_;

    public void trace(T...)(lazy T args) {
        put(args, LoggerVerbosity.trace);
    }

    alias trc = trace;

    public void verbose(T...)(lazy T args) {
        put(args, LoggerVerbosity.verbose);
    }

    alias vrb = verbose;

    public void info(T...)(lazy T args) {
        put(args, LoggerVerbosity.info);
    }

    alias inf = info;

    public void warn(T...)(lazy T args) {
        put(args, LoggerVerbosity.warn);
    }

    alias wrn = warn;

    public void error(T...)(lazy T args) {
        put(args, LoggerVerbosity.error);
    }

    alias err = error;

    public void crit(T...)(lazy T args) {
        put(args, LoggerVerbosity.crit);
    }

    alias cri = crit;
}
