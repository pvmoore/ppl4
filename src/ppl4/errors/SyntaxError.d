module ppl4.errors.SyntaxError;

import ppl4.all;

final class SyntaxError : Exception {
    Module mod;
    int line;
    int column;

    this(Module mod, int line, int column) {
        super("Syntax error %s %s:%s".format(mod, line, column));
        this.mod = mod;
        this.line = line;
        this.column = column;
    }
    this(ParseState state) {
        this(state.mod, state.line(), state.column());
    }
}