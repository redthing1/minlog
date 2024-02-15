import std.stdio;

import minlog;

void main() {
	auto log1 = Logger(LoggerVerbosity.debug_);
	log1.cri("this is a critical message");
	log1.err("this is an error message");
	log1.wrn("this is a warning message");
	log1.inf("this is an info message");
	log1.vrb("this is a verbose message");
	log1.trc("this is a trace message");
	log1.dbg("this is a debug message");

	auto log2 = Logger(LoggerVerbosity.info);
	auto log2_test2 = log2.for_source("Test2");
	log2_test2.inf("this is an info message from Test2");

	auto log3 = Logger(LoggerVerbosity.info);
	auto log3_test3 = log3.for_source("Test3");

	log3.set_format(LoggerFormat.raw);
	log3.inf("hello, raw format");

	log3.set_format(LoggerFormat.basic);
	log3.inf("hello, basic format");

	log3.set_format(LoggerFormat.standard);
	log3_test3.set_format(LoggerFormat.standard);
	log3.inf("hello, standard format");
	log3_test3.inf("hello, standard format from Test3");

	log3.set_format(LoggerFormat.fancy);
	log3_test3.set_format(LoggerFormat.fancy);
	log3.inf("hello, fancy format");
	log3_test3.inf("hello, fancy format from Test3");
}
