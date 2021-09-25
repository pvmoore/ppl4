module ppl4.errors.ResolutionError;

import ppl4.all;

final class ResolutionError : CompilationError {

    this(Module mod, int line, int column, string message) {
        super(mod, line, column, message);
    }
}

void resolutionError(ResolveState state) {

    foreach(i, stmt; state.getUnresolvedStatements()) {
        state.mod.addError(
            new CompilationError(state.mod, stmt.line(), stmt.column(),
                "Unresolved: " ~ stmt.toString())
        );
    }
}