# minlog

simple minimal logger for D

## usage

```cpp
import minlog;

auto log = new Logger(Verbosity.info);
log.sinks ~= new Logger.ConsoleSink();
log.verbosity = Verbosity.trace;

log.info("hello world");
````