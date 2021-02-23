module main;

import std.stdio;
import ppl4.all;

int main(string[] args) {

    auto dir = "projects/test";
    auto file = "test.p4";

    auto config = new Config(dir, file)
        .withOutput("projects/test/target");

    writefln("%s", config);

    auto c = new Compiler(config);

    c.compile();

    if(c.hasErrors()) {

        auto errors = c.getErrors();

        writefln("");

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