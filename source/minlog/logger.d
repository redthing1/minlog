module minlog.logger;

import std.stdio;
import std.format;
import std.conv;
import std.datetime;
import colorize;

/// how verbose the messages are
enum Verbosity {
    trace = 4,
    info = 3,
    warn = 2,
    error = 1,
    crit = 0
}

/// a utility class for displaying diagnostic messages
class Logger {
    /// maximum message verbosity
    public Verbosity verbosity;
    /// message output targets
    public ILogSink[] sinks;

    /**
    initialize a logger with a given verbosity
    */
    this(Verbosity verbosity) {
        this.verbosity = verbosity;
    }

    /// writes a message
    public void write_line(string log, Verbosity level) {
        if (level <= verbosity) {
            foreach (sink; sinks) {
                sink.write_line(log, level);
            }
        }
    }

    /// writes a message at trace verbosity
    public void trace(string log) {
        write_line(log, Verbosity.trace);
    }

    /// writes a message at INFO verbosity
    public void info(string log) {
        write_line(log, Verbosity.info);
    }

    /// writes a message at warn verbosity
    public void warn(string log) {
        write_line(log, Verbosity.warn);
    }

    /// writes a message at error verbosity
    public void err(string log) {
        write_line(log, Verbosity.error);
    }

    /// writes a message at crit verbosity
    public void crit(string log) {
        write_line(log, Verbosity.crit);
    }

    private static string shortVerbosity(Verbosity level) {
        switch (level) {
        case Verbosity.trace:
            return "trce";
        case Verbosity.info:
            return "info";
        case Verbosity.warn:
            return "warn";
        case Verbosity.error:
            return "err!";
        case Verbosity.crit:
            return "crit";
        default:
            return to!string(level);
        }
    }

    private static string formatMeta(Verbosity level) {
        auto time = cast(TimeOfDay) Clock.currTime();
        return format("[%s/%s]", shortVerbosity(level), time.toISOExtString());
    }

    /// a sink that accepts log messages
    public interface ILogSink {
        /// writes a message to the sink
        void write_line(string log, Verbosity level);
    }

    /// a sink that outputs to the console
    public static class ConsoleSink : ILogSink {
        public void write_line(string log, Verbosity level) {
            auto col = colorFor(level);
            colorize.cwritef(formatMeta(level).color(col, colorize.bg.black));
            colorize.cwritefln(" %s", log);
        }

        private colorize.fg colorFor(Verbosity level) {
            switch (level) {
            case Verbosity.trace:
                return colorize.fg.light_black;
            case Verbosity.info:
                return colorize.fg.green;
            case Verbosity.warn:
                return colorize.fg.yellow;
            case Verbosity.error:
                return colorize.fg.light_red;
            case Verbosity.crit:
                return colorize.fg.red;
            default:
                return colorize.fg.white;
            }
        }
    }

    /// a sink that outputs to a file
    public static class FileSink : ILogSink {
        public string path;
        private File of;

        this(string path) {
            this.path = path;
            this.of = File(path, "a");
        }

        public void write_line(string log, Verbosity level) {
            of.write(formatMeta(level));
            of.writeln(" {log}");
            of.flush();
        }
    }
}

unittest {
    auto log = new Logger(Verbosity.info);
    log.sinks ~= new Logger.ConsoleSink();
    log.verbosity = Verbosity.trace;

    log.info("hello world");
}