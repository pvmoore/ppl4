module ppl4.ast.expr.Expression;

import ppl4.all;

abstract class Expression : Statement {
public:
    abstract Type type();

    this(Module mod) {
        super(mod);
    }
}

//==================================================================================================

Expression parseExpression(ParseState state, Statement parent) {
    auto expr = lhs(state, parent);
    rhs(state, parent);
    return expr;
}

private:
//==================================================================================================
// F I R S T
//==================================================================================================
Expression lhs(ParseState state, Statement parent) {
    switch(state.kind()) with(TokenKind) {
        case NUMBER:
            return state.make!Number().parse(state);
        default:
            todo("%s".format(state.kind()));
            break;
    }
    assert(false);
}

//==================================================================================================
// S E C O N D
//==================================================================================================
void rhs(ParseState state, Statement parent) {

}