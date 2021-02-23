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
        return "|%s %s:%s| %s".format(mod.name, line+1, column+1, message);
    }
}

void syntaxError(ParseState state) {
    state.mod.addError(new CompileError(state.mod, state.line(), state.column(), "Syntax error"));
    throw new SyntaxError();
}
void linkError(Module mainModule, string msg) {
    mainModule.addError(new CompileError(mainModule, 0, 0, msg));
}
void returnTypeMismatch(Statement stmt) {
    stmt.mod.addError(new CompileError(stmt.mod, stmt.line(), stmt.column(),
        "Return types cannot be converted to a common type"));
}
void entryFuncReturnTypeShouldBeInt(Statement stmt) {
    stmt.mod.addError(new CompileError(stmt.mod, stmt.line(), stmt.column(),
        "Program entry function return type is expected to be int"));
}