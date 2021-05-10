module ppl4.ast.expr.Assert;

import ppl4.all;

/**
 *  Assert
 *      Expression
 */
final class Assert : Expression {
private:

public:
    this(Module mod) {
        super(mod);
    }

    @Implements("Node")
    override NodeId id() { return NodeId.ASSERT; }

    @Implements("Expression")
    override Type type() { return BOOL; }

    @Implements("Expression")
    override int precedence() { return precedenceOf(Operator.ASSERT); }

    /**
     * "assert" Expression
     */
    @Implements("Statement")
    override Assert parse(ParseState state) {
        // "assert"
        state.skip("assert");

        // Expression
        parseExpression(state, this);

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

    }

    override string toString() {
        return "Assert";
    }
}