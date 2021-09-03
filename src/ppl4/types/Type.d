module ppl4.types.Type;

import ppl4.all;

abstract class Type {
    TypeKind kind;
    int ptrDepth;

    this(TypeKind kind, int ptrDepth) {
        this.kind = kind;
        this.ptrDepth = ptrDepth;
    }

    final bool isPtr() { return ptrDepth > 0; }
    final bool isBool() { return kind == TypeKind.BOOL; }
    final bool isVoid() { return kind == TypeKind.VOID; }
    final bool isReal() { return kind.isOneOf(TypeKind.FLOAT, TypeKind.DOUBLE); }
    final bool isInteger() { with(TypeKind) return kind.isOneOf(BYTE, SHORT, INT, LONG); }
    final bool isStruct() { return kind == TypeKind.STRUCT; }
    final bool isFunction() { return kind == TypeKind.FUNCTION; }
    final bool isVoidPtr() { return isVoid() && isPtr(); }

    bool isResolved() { return kind != TypeKind.UNKNOWN; }

    abstract bool exactlyMatches(Type other);
    abstract bool canImplicitlyCastTo(Type other);

    // TODO - parse here
    Type parse(ParseState state) {
        return null;
    }

    /**
     * @return a new resolved Type or this.
     */
    Type resolve(ResolveState state) {
        if(!isResolved()) {
            todo("resolve type %s".format(this));
        }
        return this;
    }

    final LLVMTypeRef getLLVMType() {
        expect(isResolved());

        LLVMTypeRef t;
        final switch(kind) with(TypeKind) {
            case BOOL:
            case BYTE: t = i8Type(); break;
            case SHORT: t = i16Type(); break;
            case INT: t = i32Type(); break;
            case LONG: t = i64Type(); break;
            case FLOAT: t = f32Type(); break;
            case DOUBLE: t = f64Type(); break;
            case VOID: t = voidType(); break;
            case STRUCT:
                t = this.as!StructType.struct_.llvmType;
                break;
            case FUNCTION:
                todo();
                t = null;
                break;
            case UNKNOWN:
                expect(false, "type kind is %s".format(kind));
                break;
        }
        if(ptrDepth > 0) {
            if(kind == TypeKind.VOID) {
                t = i8Type();
            }
            foreach(i; 0..ptrDepth) {
                t = pointerType(t);
            }
        }
        return t;
    }

    int size() {
        if(isPtr()) return 8;
        final switch(kind) with(TypeKind) {
            case BOOL:
            case BYTE:
                return 1;
            case SHORT:
                return 2;
            case INT:
            case FLOAT:
                return 4;
            case LONG:
            case DOUBLE:
                return 8;
            case STRUCT:
                todo();
                return 0;
            case UNKNOWN:
            case VOID:
            case FUNCTION:
                expect(false, "type kind is %s".format(kind));
                break;
        }
        assert(false);
    }
}