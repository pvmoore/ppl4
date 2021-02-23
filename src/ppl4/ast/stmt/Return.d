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
            add(parseExpression(state, this));
        }

        return this;
    }

    @Implements("Statement")
    override void resolve(ResolveState state) {
        this.isResolved = true;
        super.resolve(state);
    }

    @Implements("Statement")
    override void check() {
        // Nothing to do
        super.check();
    }

    @Implements("Statement")
    override void generate(GenState state) {
        auto func = ancestor!Function;
        info("return %s", func);
        if(hasChildren()) {
            first().generate(state);
            state.rhs = state.castType(state.rhs, expr().type(), func.returnType);
            state.builder.ret(state.rhs);
        } else {
            state.builder.retVoid();
        }
    }

    override string toString() {
        return "Return";
    }
}