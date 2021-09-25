module ppl4.ast.stmt.Return;

import ppl4.all;

/**
 *  Return
 *      [Expression]
 */
final class Return : Statement {
public:
    Expression expr() { expect(hasChildren()); return first().as!Expression; }

    //==============================================================================================
    this(Module mod) {
        super(mod);
    }

    //========================================================================================= Node
    override NodeId id() { return NodeId.RETURN; }

    /**
     *  "return" [ Expression ]
     */
    override Return parse(ParseState state) {

        // return
        state.skip("return");

        if(!state.isNewLine()) {
            parseExpression(state, this);
        }

        return this;
    }

    override void resolve(ResolveState state) {

        if(hasChildren()) {
            expr().resolve(state);

            if(expr().isResolved) {
                // Ensure the type is cast to the function type

                setResolved();
            }
        } else {
            setResolved();
        }
    }

    override void check() {
        super.check();
    }

    override void generate(GenState state) {
        auto func = ancestor!FnLiteral;

        if(hasChildren()) {
            first().generate(state);

            state.builder.ret(state.rhs);
        } else {
            state.builder.retVoid();
        }
    }

    //======================================================================================= Object
    override string toString() {
        return "Return %s".format(isResolved() ? "✅" : "❌");
    }
}