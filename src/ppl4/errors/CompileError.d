module ppl4.errors.CompileError;

import ppl4.all;

final class CompileError {
public:
    Module mod;
    int line, column;
    string message;

    this(Module mod, int line, int column, string message) {
        this.mod = mod;
        this.line = line;
        this.column = column;
        this.message = message;
    }

    override string toString() {
        return "%s %s:%s %s".format(mod.name, line+1, column+1, message);
    }
}

void syntaxError(ParseState state) {
    state.mod.addError(new CompileError(state.mod, state.line(), state.column(), "Syntax error"));
    throw new SyntaxError();
}
void returnTypeMismatch(Statement stmt) {
    stmt.mod.addError(new CompileError(stmt.mod, stmt.line(), stmt.column(), "Return type mismatch"));
}
void linkError(Module mainModule, string msg) {
    mainModule.addError(new CompileError(mainModule, 0, 0, msg));
}