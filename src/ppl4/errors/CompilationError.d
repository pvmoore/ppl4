module ppl4.errors.CompilationError;

import ppl4.all;

final class CompilationError {
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

void syntaxError(ParseState state, string msg = null) {
    string s = "Syntax error" ~ msg ? ": " ~ msg : "";
    state.mod.addError(new CompilationError(state.mod, state.line(), state.column(), s));
    throw new SyntaxError();
}
void publicNotAllowed(ParseState state) {
    state.mod.addError(new CompilationError(state.mod, state.line(), state.column(),
        "Public modifier not allowed here"));
}
void statementNotAllowed(ParseState state, string name) {
    state.mod.addError(new CompilationError(state.mod, state.line(), state.column(),
        "%s not allowed here".format(name)));
}


void linkError(Module mainModule, string msg) {
    mainModule.addError(new CompilationError(mainModule, 0, 0, msg));
}
void returnTypeMismatch(Statement stmt) {
    stmt.mod.addError(new CompilationError(stmt.mod, stmt.line(), stmt.column(),
        "Return types cannot be converted to a common type"));
}
void entryFuncReturnTypeShouldBeInt(Statement stmt) {
    stmt.mod.addError(new CompilationError(stmt.mod, stmt.line(), stmt.column(),
        "Program entry function return type is expected to be int"));
}
void singleExpressionExpected(Statement stmt) {
    stmt.mod.addError(new CompilationError(stmt.mod, stmt.line(), stmt.column(),
        "Single expression expected here"));
}

