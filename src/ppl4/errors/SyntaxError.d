module ppl4.errors.SyntaxError;

import ppl4.all;

final class SyntaxError : Exception {
    this() {
        super("Syntax error");
    }
}