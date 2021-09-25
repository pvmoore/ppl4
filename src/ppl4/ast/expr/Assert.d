module ppl4.ast.expr.Assert;

import ppl4.all;

/**
 *  Assert
 *      Expression
 */
final class Assert : Expression {
private:

public:

    //==============================================================================================
    this(Module mod) {
        super(mod);
    }

    //=================================================================================== Expression
    override Type type() { return BOOL; }

    override int precedence() { return precedenceOf(Operator.ASSERT); }

    //========================================================================================= Node
    override NodeId id() { return NodeId.ASSERT; }

    /**
     * "assert" Expression
     */
    override Assert parse(ParseState state) {
        // "assert"
        state.skip("assert");

        // Expression
        parseExpression(state, this);

        return this;
    }

    override void resolve(ResolveState state) {
        setResolved();

        super.resolve(state);
    }

    override void check() {

    }

    override void generate(GenState state) {

    }

    //======================================================================================= Object
    override string toString() {
        return "Assert";
    }
}