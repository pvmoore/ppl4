module ppl4.types.Type;

import ppl4.all;

abstract class Type {
    TypeKind kind;
    int ptrDepth;

    this(TypeKind kind, int ptrDepth) {
        this.kind = kind;
        this.ptrDepth = ptrDepth;
    }

    final bool isPtr() {
        return ptrDepth > 0;
    }

    bool isResolved() {
        return kind != TypeKind.UNKNOWN;
    }

    /**
     * @return a new resolved Type or this.
     */
    Type resolve() {
        if(!isResolved()) {
            todo("resolve type %s".format(this));
        }
        return this;
    }

    LLVMTypeRef getLLVMType() {
        todo();



        return null;
    }

    override string toString() {
        string s;
        foreach(i; 0..ptrDepth) {
            s ~= "ref ";
        }
        return s;
    }
}