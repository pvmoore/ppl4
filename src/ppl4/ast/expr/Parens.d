module ppl4.ast.expr.Parens;

import ppl4.all;

/**
 *  Parens
 *      Expression
 */
final class Parens : Expression {
private:

public:
    this(Module mod) {
        super(mod);
    }

    Expression expr() { return first().as!Expression; }

    @Implements("Node")
    override NodeId id() { return NodeId.PARENS; }

    @Implements("Expression")
    override Type type() { return expr().type(); }

    @Implements("Expression")
    override int precedence() { return precedenceOf(Operator.PARENS); }

    /**
     * '(' Expression ')'
     */
    @Implements("Statement")
    override Parens parse(ParseState state) {
        // (
        state.skip(TokenKind.LBRACKET);

        // Expression
        parseExpression(state, this);

        // )
        state.skip(TokenKind.RBRACKET);

        return this;
    }

    @Implements("Statement")
    override void resolve(ResolveState state) {
        setResolved();
        super.resolve(state);
    }

    @Implements("Statement")
    override void check() {

    }

    @Implements("Statement")
    override void generate(GenState state) {
        first().generate(state);
    }

    override string toString() {
        return "Parens";
    }
}