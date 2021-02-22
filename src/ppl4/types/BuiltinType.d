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

    override string toString() {
        return super.toString() ~ kind.toString();
    }
}