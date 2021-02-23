module ppl4.types.StructType;

import ppl4.all;

final class StructType : Type {
private:
public:
    Struct struct_;

    this() {
        super(TypeKind.STRUCT, 0);
    }

    override bool exactlyMatches(Type other) {
        todo();
        return false;
    }

    override bool canImplicitlyCastTo(Type other) {
        if(!.canImplicitlyCastTo(this, other)) return false;
        
        return false;
    }

    override string toString() {
        return super.toString() ~ "StructType";
    }
}