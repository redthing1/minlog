import std.stdio;

import minlog;

void main() {
	auto log1 = Logger(Verbosity.debug_);
	log1.cri("this is a critical message");
	log1.err("this is an error message");
	log1.wrn("this is a warning message");
	log1.inf("this is an info message");
	log1.vrb("this is a verbose message");
	log1.trc("this is a trace message");
	log1.dbg("this is a debug message");
}
