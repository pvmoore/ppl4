module ppl4.types.BuiltinType;

import ppl4.all;

final class BuiltinType : Type {
private:

public:
    this(TypeKind kind, int ptrDepth = 0) {
        super(kind, ptrDepth);
    }

    override string toString() {
        return super.toString() ~ kind.toString();
    }
}