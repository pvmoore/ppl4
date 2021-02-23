module ppl4.ast.stmt.Variable;

import ppl4.all;

/**
 *  Variable
 *      [ Expression ]
 */
final class Variable : Statement {
private:
public:
    string name;
    Type type;
    bool isPublic;

    this(Module mod, bool isPublic) {
        super(mod);
        this.isPublic = isPublic;
    }

    @Implements("Node")
    override NodeId id() { return NodeId.VARIABLE; }

    /**
     * name ":" Type
     * name ":" Type "=" Expression
     * name "=" Expression
     */
    @Implements("Statement")
    override Variable parse(ParseState state) {

        // + (public)
        if(state.isKind(TokenKind.PLUS)) {
            state.next();
            this.isPublic = true;
        }

        // name
        this.name = state.text(); state.next();

        // : Type
        if(state.kind() == TokenKind.COLON) {
            state.next();

            this.type = parseType(state);

        }

        // =
        if(state.isKind(TokenKind.EQUALS)) {
            state.next();

            add(parseExpression(state, this));
        }

        return this;
    }

    @Implements("Statement")
    override void resolve(ResolveState state) {
        if(!type.isResolved) {

            todo();

            state.unresolved(this);
        }
        super.resolve(state);
    }

    @Implements("Statement")
    override void check() {
        // 1) name must not be duplicate or shadow
        // 2) ...
        super.check();
    }

    @Implements("Statement")
    override void generate(GenState state) {
        super.generate(state);
    }

    override string toString() {
        return "Variable%s %s '%s'".format(isPublic?"(+)":"", type, name);
    }
}