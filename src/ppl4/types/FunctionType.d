module ppl4.types.FunctionType;

import ppl4.all;

/**
 *
 */
final class FunctionType : Type {
private:

public:
    Type[] params;
    Type returnType;

    this() {
        super(TypeKind.FUNCTION, 1);
    }
    this(Type[] params, Type returnType) {
        this();
        this.params = params;
        this.returnType = returnType;
    }

    Type parse(ParseState state) {
        todo();
        return this;
    }

    override bool exactlyMatches(Type other) {
        if(!.canImplicitlyCastTo(this, other)) return false;

        return false;
    }

    override bool canImplicitlyCastTo(Type other) {
        return false;
    }

    override string toString() {
        return "fn(%s):%s".format(typeString(params), returnType.toString());
    }
}