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
    override Statement parse(ParseState state) {

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

            this.type = Type.parseType(state);

        }

        // =
        if(state.isKind(TokenKind.EQUALS)) {
            state.next();

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
        return "Variable%s %s '%s'".format(isPublic?"(+)":"", type, name);
    }
}