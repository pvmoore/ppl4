module ppl4.ast.stmt.Return;

import ppl4.all;

/**
 *  Return
 *      [Expression]
 */
final class Return : Statement {
public:
    this(Module mod) {
        super(mod);
    }

    @Implements("Node")
    override NodeId id() { return NodeId.RETURN; }

    /**
     *  "return" [ Expression ]
     */
    @Implements("Statement")
    override Statement parse(ParseState state) {

        // return
        state.skip("return");

        if(!state.isNewLine()) {
            add(Expression.parseExpression(state));
        }

        return this;
    }

    @Implements("Statement")
    override bool resolve() {
        todo();
        return false;
    }

    @Implements("Statement")
    override bool check() {
        todo();
        return false;
    }

    @Implements("Statement")
    override bool generate() {
        todo();
        return false;
    }

    override string toString() {
        return "Return";
    }
}