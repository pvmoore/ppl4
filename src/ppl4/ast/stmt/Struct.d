module ppl4.ast.stmt.Struct;

import ppl4.all;

/**
 *  Struct
 *      { [ Variable ] }
 *      { [ Function ] }
 *      { [ Import ] }
 */
final class Struct : Statement {
private:

public:
    string name;
    bool isPublic;

    this(Module mod, bool isPublic) {
        super(mod);
        this.isPublic = isPublic;
    }

    @Implements("Node")
    override NodeId id() { return NodeId.STRUCT; }

    /**
     * name "=" "struct" "{" ( Function | Variable | Import ) "}"
     */
    @Implements("Statement")
    override Statement parse(ParseState state) {

        // name
        this.name = state.text(); state.next();

        // =
        state.skip(TokenKind.EQUALS);

        // struct
        state.skip("struct");

        // {
        state.skip(TokenKind.LCURLY);

        while(TokenKind.RCURLY != state.kind()) {
            // Variable | Function | Import

            super.parse(state);
        }

        // }
        state.skip(TokenKind.RCURLY);

        return this;
    }

    @Implements("Statement")
    override void resolve(ResolveState state) {
        this.isResolved = true;
        super.resolve(state);
    }

    @Implements("Statement")
    override bool check() {
        // 1) ...
        return super.check();
    }

    @Implements("Statement")
    override void generate(GenState state) {

    }

    override string toString() {
        return "Struct%s '%s'".format(isPublic ? "(+)":"", name);
    }
}