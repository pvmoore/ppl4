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

    if(c.hasErrors()) {
        writefln("Fail");

        auto errors = c.getErrors();

        foreach(e; errors) {
            writefln("%s", e);
        }

    } else {
        writefln("Ok");
        auto r = c.getReport();
        writefln("\n%s", r);
    }
    return 0;
}