module ppl4.Logging;

import ppl4.all;

__gshared {
	// Logging enabled areas
	enum {
		LOG_LEX		= true,
		LOG_PARSE 	= true,
		LOG_RESOLVE = true,
		LOG_CHECK 	= true,
		LOG_GEN 	= true,
		LOG_LINK 	= true
	}
	// Areas
	enum : int {
		LEX,
		PARSE,
		RESOLVE,
		CHECK,
		GEN,
		LINK
	}
}

/**
 * This is for debugging only
 */
void trace(float n) {
	writefln("%s", n);
}

void trace(A...)(int area, string fmt, A args) {
	writefln(format(fmt, args));
}

void info(A...)(int area, string fmt, A args) {
	writefln(format(fmt, args));
}
void warn(A...)(string fmt, A args) {
	writefln("[WARN] " ~ format(fmt, args));
}
void error(A...)(string fmt, A args) {
	writefln("[ERROR] " ~ format(fmt, args));
}

