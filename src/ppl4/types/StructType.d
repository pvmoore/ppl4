module ppl4.types.StructType;

import ppl4.all;

final class StructType : Type {
private:
public:
    Struct struct_;

    this() {
        super(TypeKind.STRUCT, 0);
    }

    override string toString() {
        return super.toString() ~ "StructType";
    }
}