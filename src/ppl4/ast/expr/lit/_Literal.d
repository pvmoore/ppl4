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

    //=================================================================================== Expression
    override int precedence() { return precedenceOf(Operator.LITERAL); }
}