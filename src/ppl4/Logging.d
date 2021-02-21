module ppl4.logging;

import ppl4.all;

void trace(A...)(string fmt, A args) {
	writefln(format(fmt, args));
}

void info(A...)(string fmt, A args) {
	writefln(format(fmt, args));
}

void warn(A...)(string fmt, A args) {
	writefln("[WARN] " ~ format(fmt, args));
}

void error(A...)(string fmt, A args) {
	writefln("[ERROR] " ~ format(fmt, args));
}