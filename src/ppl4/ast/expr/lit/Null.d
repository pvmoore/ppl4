module ppl4.ast.expr.lit.Null;

import ppl4.all;

final class Null : Literal {
private:

public:

    //==============================================================================================
    this(Module mod) {
        super(mod);
    }

    //=================================================================================== Expression
    override Type type() { return _type; }

    //========================================================================================= Node
    override NodeId id() { return NodeId.NULL; }

    /**
     * "null"
     */
    override Null parse(ParseState state) {
        // name
        state.skip("null");

        return this;
    }

    override void resolve(ResolveState state) {
        if(!isResolved()) {
            this._type = resolveTypeFromParent();

            if(_type.isResolved) {
                setResolved();
            } else {
                setUnresolved();
            }
        }
    }

    override void check() {

    }

    override void generate(GenState state) {
        state.rhs = constNullPointer(_type.getLLVMType());
    }

    //======================================================================================= Object
    override string toString() {
        return "Null:%s".format(_isResolved ? _type.toString() : "?");
    }
}