module ppl4.ast.expr.Cast;

import ppl4.all;

/**
 *  Cast (type)
 */
final class Cast : Expression {
private:
    Type _type;
public:

    this(Module mod) {
        super(mod);
    }

    static Cast make(Module mod, Type t) {
        auto c = new Cast(mod);
        c._type = t;
        return c;
    }

    Expression expr() {
        return first().as!Expression;
    }

    @Implements("Node")
    override NodeId id() { return NodeId.CAST; }

    @Implements("Expression")
    override Type type() { return _type; }

    @Implements("Expression")
    override int precedence() { return precedenceOf(Operator.CAST); }

    /**
     * Type "(" Expression ")"
     */
    @Implements("Node")
    override Cast parse(ParseState state) {
        // type
        _type = parseType(state);

        // (
        state.skip(TokenKind.LBRACKET);

        // Expression
        parseExpression(state, this);

        // )
        state.skip(TokenKind.RBRACKET);

        return this;
    }

    @Implements("Node")
    override void resolve(ResolveState state) {
        if(!isResolved) {
            if(_type.isResolved()) {
                setResolved();
            } else {
                todo("parse the type");
            }
        }

        super.resolve(state);
    }

    @Implements("Node")
    override void check() {

    }

    @Implements("Node")
    override void generate(GenState state) {

        expr().generate(state);

        state.rhs = state.castType(state.rhs, expr().type(), _type, "cast");
    }

    override string toString() {
        return "Cast (%s)".format(_type);
    }
}