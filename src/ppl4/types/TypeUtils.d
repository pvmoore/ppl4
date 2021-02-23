module ppl4.types.TypeUtils;

import ppl4.all;

__gshared {
    Type UNKNOWN_TYPE = new BuiltinType(TypeKind.UNKNOWN);
    Type BOOL = new BuiltinType(TypeKind.BOOL);
    Type BYTE = new BuiltinType(TypeKind.BYTE);
    Type SHORT = new BuiltinType(TypeKind.SHORT);
    Type INT = new BuiltinType(TypeKind.INT);
    Type LONG = new BuiltinType(TypeKind.LONG);
    Type FLOAT = new BuiltinType(TypeKind.FLOAT);
    Type DOUBLE = new BuiltinType(TypeKind.DOUBLE);
    Type VOID = new BuiltinType(TypeKind.VOID);

    Type REF_BYTE = new BuiltinType(TypeKind.BYTE, 1);
    Type REF_VOID = new BuiltinType(TypeKind.VOID, 1);
}

bool areResolved(Type[] types) {
    foreach(t; types) {
        if(!t.isResolved()) return false;
    }
    return true;
}

bool canImplicitlyCastTo(Type left, Type right) {
    if(!left.isResolved() || !right.isResolved()) return false;
    if(left.ptrDepth != right.ptrDepth) return false;

    if(left.isPtr()) {
        if(right.isVoid()) {
            /// void* can contain any other pointer
            return true;
        }
        /// pointers must be exactly the same base type
        return left.kind==right.kind;
    }
    /// Do the base checks now
    return true;
}

/**
 *  Return the largest type of a or b.
 *  Return null if they are not compatible.
 */
Type getBestFit(Type a, Type b) {
    if((a.isVoid() && !a.isPtr()) || (b.isVoid() && !b.isPtr())) {
        return UNKNOWN_TYPE;
    }

    if(a.exactlyMatches(b)) return a;

    if(a.isPtr() || b.isPtr()) {
        return UNKNOWN_TYPE;
    }
    // if(a.isTuple || b.isTuple) {
    //     // todo - some clever logic here
    //     return UNKNOWN_TYPE;
    // }
    if(a.isClassPtr() || b.isClassPtr()) {
        // todo - some clever logic here
        return UNKNOWN_TYPE;
    }
    if(a.isStruct() || b.isStruct()) {
        // todo - some clever logic here
        return UNKNOWN_TYPE;
    }
    if(a.isFunctionPtr() || b.isFunctionPtr()) {
        return UNKNOWN_TYPE;
    }
    // if(a.isArray || b.isArray) {
    //     return UNKNOWN_TYPE;
    // }

    if(a.isReal() == b.isReal()) {
        return a.kind > b.kind ? a : b;
    }
    if(a.isReal()) return a;
    if(b.isReal()) return b;
    return a;
}
///
/// Get the largest type of all elements.
/// If there is no common type then return UNKNOWN_TYPE
///
Type getBestFit(Type[] types) {
    if(types.length==0) return UNKNOWN_TYPE;

    Type t = types[0];
    if(types.length==1) return t;

    foreach(e; types[1..$]) {
        t = getBestFit(t, e);
        if(t is UNKNOWN_TYPE) {
            return UNKNOWN_TYPE;
        }
    }
    return t;
}

/**
 * { ref } (bool|byte|int|etc..|StructType|FunctionType|EnumType)
 *
 */
Type parseType(ParseState state) {
    Type t;
    int numRefs;

    // consume any "ref"s
    while("ref" == state.text()) {
        numRefs++;
        state.next();
    }

    switch(state.text()) {
        case "bool":
            t = new BuiltinType(TypeKind.BOOL);
            break;
        case "byte":
            t = new BuiltinType(TypeKind.BYTE);
            break;
        case "short":
            t = new BuiltinType(TypeKind.SHORT);
            break;
        case "int":
            t = new BuiltinType(TypeKind.INT);
            break;
        case "long":
            t = new BuiltinType(TypeKind.LONG);
            break;
        case "float":
            t = new BuiltinType(TypeKind.FLOAT);
            break;
        case "double":
            t = new BuiltinType(TypeKind.DOUBLE);
            break;
        case "void":
            t = new BuiltinType(TypeKind.VOID);
            break;
        case "fn":
            t = new FunctionType().parse(state);
            break;
        default:
            // struct, class, enum
            t = new UnresolvedType().parse(state);
            break;
    }
    if(t) {
        state.next();
        t.ptrDepth = numRefs;

    } else if(numRefs > 0) {
        // "ref" followed by non-type
        todo();
    }

    return t;
}

void resolveType(ref Type type) {

}