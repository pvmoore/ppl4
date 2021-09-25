module ppl4.ast.expr.Cast;

import ppl4.all;

/**
 *  Cast (type)
 *      Expression
 */
final class Cast : Expression {
private:
    Type _type;
public:
    Expression expr() { return first().as!Expression; }

    //==============================================================================================
    this(Module mod) {
        super(mod);
    }

    static Cast make(Module mod, Type t) {
        auto c = new Cast(mod);
        c._type = t;
        return c;
    }

    //=================================================================================== Expression
    override Type type() { return _type; }

    override int precedence() { return precedenceOf(Operator.CAST); }

    //========================================================================================= Node

    override NodeId id() { return NodeId.CAST; }

    /**
     * Type "(" Expression ")"
     */
    override Cast parse(ParseState state) {
        // type
        _type = parseType(state, this);

        // (
        state.skip(TokenKind.LBRACKET);

        // Expression
        parseExpression(state, this);

        // )
        state.skip(TokenKind.RBRACKET);

        return this;
    }

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

    override void check() {
        super.check();
    }

    override void generate(GenState state) {

        expr().generate(state);

        state.rhs = state.castType(state.rhs, expr().type(), _type, "cast");
    }

    //======================================================================================= Object
    override string toString() {
        return "As (%s)".format(_type);
    }
}