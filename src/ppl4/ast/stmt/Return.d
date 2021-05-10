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

    Expression expr() {
        expect(hasChildren());
        return first().as!Expression;
    }

    @Implements("Node")
    override NodeId id() { return NodeId.RETURN; }

    /**
     *  "return" [ Expression ]
     */
    @Implements("Statement")
    override Return parse(ParseState state) {

        // return
        state.skip("return");

        if(!state.isNewLine()) {
            parseExpression(state, this);
        }

        return this;
    }

    @Implements("Statement")
    override void resolve(ResolveState state) {
        if(isResolved) return;
        if(hasChildren()) {
            expr().resolve(state);
            if(expr().isResolved) {
                // Ensure the type is cast to the function type

            }
        } else {
            setResolved();
        }
    }

    @Implements("Statement")
    override void check() {
        // Nothing to do
        super.check();
    }

    @Implements("Statement")
    override void generate(GenState state) {
        auto func = ancestor!Function;

        if(hasChildren()) {
            first().generate(state);

            state.builder.ret(state.rhs);
        } else {
            state.builder.retVoid();
        }
    }

    override string toString() {
        return "Return";
    }
}