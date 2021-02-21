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
            add(parseExpression(state));
        }

        return this;
    }

    @Implements("Statement")
    override void resolve(ResolveState state) {
        this.isResolved = true;
        if(hasChildren()) {
            first().resolve(state);
        }
    }

    @Implements("Statement")
    override bool check() {
        // Nothing to do
        return super.check();
    }

    @Implements("Statement")
    override void generate(GenState state) {

    }

    override string toString() {
        return "Return";
    }
}