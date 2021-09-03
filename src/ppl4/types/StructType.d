module ppl4.types.StructType;

import ppl4.all;

final class StructType : Type {
private:
public:
    Struct struct_;

    this(Struct struct_) {
        super(TypeKind.STRUCT, struct_.isClass ? 1 : 0);
        this.struct_ = struct_;
    }

    bool isClass() {
        return struct_.isClass;
    }

    override Type parse(ParseState state) {
        todo();
        return this;
    }

    override bool exactlyMatches(Type other) {
        // other must be a struct
        StructType otherType = other.as!StructType;
        if(!otherType) return false;

        return struct_ is otherType.struct_;
    }

    override bool canImplicitlyCastTo(Type other) {
        if(!.canImplicitlyCastTo(this, other)) return false;

        // other must be a struct
        StructType otherType = other.as!StructType;
        if(!otherType) return false;

        return struct_.name == otherType.struct_.name;
    }

    override string toString() {
        return struct_.name ~ repeat("*", ptrDepth);
    }
}