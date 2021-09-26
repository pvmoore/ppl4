module ppl4.ast.expr.lit._Literal;

import ppl4.all;

abstract class Literal : Expression {
protected:
    Type _type;
public:

    //==============================================================================================
    this(Module mod) {
        super(mod);
        this._type = UNKNOWN_TYPE;
    }

    Literal withType(Type type) {
        this._type = type;
        return this;
    }

    //=================================================================================== Expression
    override Type type() { return _type; }
    override int precedence() { return precedenceOf(Operator.LITERAL); }
}