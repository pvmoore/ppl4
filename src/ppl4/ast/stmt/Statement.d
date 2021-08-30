module ppl4.ast.stmt.Statement;

import ppl4.all;

abstract class Statement : Node {
public:
    Module mod;
    Token startToken;

    this(Module mod) {
        this.mod = mod;
    }

    final int line() { return startToken.line; }
    final int column() { return startToken.column; }

    
}