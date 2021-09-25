module ppl4.ast.stmt._Statement;

import ppl4.all;

abstract class Statement : Node {
public:
    Token startToken;

    this(Module mod) {
        super(mod);
    }

    final int line() { return startToken.line; }
    final int column() { return startToken.column; }
}