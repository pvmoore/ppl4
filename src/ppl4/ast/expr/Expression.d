module ppl4.ast.expr.Expression;

import ppl4.all;

abstract class Expression : Statement {
public:
    abstract Type type();

    this(Module mod) {
        super(mod);
    }

    static Expression parseExpression(ParseState state) {
        todo("%s".format(state.peek()));
        return null;
    }
}