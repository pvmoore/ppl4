module main;

import std.stdio;
import ppl4.all;

int main(string[] args) {

    auto dir = "projects/test";
    auto file = "test.p4";

    auto config = new Config(dir, file);
    writefln("%s", config);

    auto c = new Compiler(config);

    c.compile();


    auto e = c.getErrors();

    if(e.length > 0) {
        writefln("Fail");

        // todo - display errors
        writefln("errors = %s", e);

    } else {
        writefln("Ok");
        auto r = c.getReport();
        writefln("\n%s", r);
    }
    return 0;
}