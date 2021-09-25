module ppl4.errors.SemanticError;

import ppl4.all;

final class SemanticError : CompilationError {

    this(Module mod, int line, int column, string message) {
        super(mod, line, column, message);
    }
}

void errorShadowingDeclaration(Identifier id, Declaration[] decls) {
    auto mod = id.mod;

    auto msg = "Multiple Declarations found for %s".format(id.name);
    mod.addError(new SemanticError(mod, id.line(), id.column(), msg));
}