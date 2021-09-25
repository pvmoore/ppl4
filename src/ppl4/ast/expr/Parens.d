module ppl4.ast.expr.Parens;

import ppl4.all;

/**
 *  Parens
 *      Expression
 */
final class Parens : Expression {
private:

public:
    Expression expr() { return first().as!Expression; }

    //==============================================================================================
    this(Module mod) {
        super(mod);
    }

    //=================================================================================== Expression
    override Type type() { return expr().type(); }

    override int precedence() { return precedenceOf(Operator.PARENS); }

    //========================================================================================= Node
    override NodeId id() { return NodeId.PARENS; }

    /**
     * '(' Expression ')'
     */
    override Parens parse(ParseState state) {
        // (
        state.skip(TokenKind.LBRACKET);

        // Expression
        parseExpression(state, this);

        // )
        state.skip(TokenKind.RBRACKET);

        return this;
    }

    override void resolve(ResolveState state) {
        setResolved();
        super.resolve(state);
    }

    override void check() {
        super.check();
    }

    override void generate(GenState state) {
        first().generate(state);
    }

    //======================================================================================= Object
    override string toString() {
        return "Parens";
    }
}