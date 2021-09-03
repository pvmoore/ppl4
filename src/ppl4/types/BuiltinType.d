module ppl4.types.BuiltinType;

import ppl4.all;

final class BuiltinType : Type {
private:

public:
    this(TypeKind kind, int ptrDepth = 0) {
        super(kind, ptrDepth);
    }

    override bool exactlyMatches(Type other) {
        return kind == other.kind && ptrDepth == other.ptrDepth;
    }

    override bool canImplicitlyCastTo(Type other) {
        if(!.canImplicitlyCastTo(this, other)) return false;

        if(!other.isA!BuiltinType) return false;

        auto right = other.as!BuiltinType;

        if(isVoid() || right.isVoid()) return false;

        if(isReal()==right.isReal()) {
            /// Allow bool -> any other BasicType
            return kind <= right.kind;
        }
        return right.isReal();
    }

    override string toString() {
        return kind.toString() ~ repeat("*", ptrDepth);
    }
}