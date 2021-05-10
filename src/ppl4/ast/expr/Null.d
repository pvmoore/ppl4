module ppl4.ast.expr.Null;

import ppl4.all;

final class Null : Expression {
private:
    Type _type;
public:
    this(Module mod) {
        super(mod);
        this._type = UNKNOWN_TYPE;
    }

    @Implements("Node")
    override NodeId id() { return NodeId.NULL; }

    @Implements("Expression")
    override Type type() { return _type; }

    @Implements("Expression")
    override int precedence() { return precedenceOf(Operator.NULL); }

    /**
     * "null"
     */
    @Implements("Statement")
    override Null parse(ParseState state) {
        // name
        state.skip("null");

        return this;
    }

    @Implements("Statement")
    override void resolve(ResolveState state) {
        if(!_isResolved) {
            this._type = resolveTypeFromParent();

            if(_type.isResolved) {
                setResolved();
            } else {
                state.unresolved(this);
            }
        }
    }

    @Implements("Statement")
    override void check() {

    }

    @Implements("Statement")
    override void generate(GenState state) {
        state.rhs = constNullPointer(_type.getLLVMType());
    }

    override string toString() {
        return "Null:%s".format(_isResolved ? _type.toString() : "?");
    }
}