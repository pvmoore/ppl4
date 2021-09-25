module ppl4.types.StructType;

import ppl4.all;

/**
 * Can be one of:
 *  - struct        value type
 *  - class         pointer type multiple instance
 */
final class StructType : Type {
private:
public:
    StructLiteral struct_;

    this(StructLiteral struct_) {
        auto kind = struct_.isClass ? TypeKind.CLASS : TypeKind.STRUCT;
        auto isPtr = struct_.isClass;
        super(kind, isPtr ? 1 : 0);
        this.struct_ = struct_;
    }

    Type parse(ParseState state) {
        todo("parse unnamed struct");
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
        if(struct_.isNamed()) {
            return struct_.name ~ repeat("*", ptrDepth);
        } else {
            todo();
            return "struct()";
        }
    }
}