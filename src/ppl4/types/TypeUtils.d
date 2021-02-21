module ppl4.types.TypeUtils;

import ppl4.all;

__gshared {
    Type UNKNOWN = new BuiltinType(TypeKind.UNKNOWN);
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