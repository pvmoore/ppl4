module ppl4.ast.expr.type.TypeExpression;

import ppl4.all;

/**
 *  TypeExpression
 */
final class TypeExpression : Expression {
private:
    Type _type;
public:
    this(Module mod) {
        super(mod);
        this._type = UNKNOWN_TYPE;
    }
    auto withType(Type type) {
        this._type = type;
        return this;
    }

    //=================================================================================== Expression
    override Type type() { return _type; }

    override int precedence() { return precedenceOf(Operator.TYPE_EXPRESSION); }

    //========================================================================================= Node
    override NodeId id() { return NodeId.TYPE_EXPRESSION; }

    override TypeExpression parse(ParseState state) {

        this._type = parseType(state, this);

        return this;
    }

    override void resolve(ResolveState state) {
        if(_type.isResolved()) {
            setResolved();
        } else {
            setUnresolved();
        }
    }

    override void check() {
        // 1) ...
    }

    override void generate(GenState state) {

    }

    //======================================================================================= Object
    override string toString() {
        return "TypeExpression %s %s".format(_type, isResolved() ? "✅" : "❌");
    }
}
