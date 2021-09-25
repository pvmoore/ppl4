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

    Type BYTE_PTR = new BuiltinType(TypeKind.BYTE, 1);
    Type VOID_PTR = new BuiltinType(TypeKind.VOID, 1);
}

bool areResolved(Type[] types) {
    foreach(t; types) {
        if(!t.isResolved()) return false;
    }
    return true;
}

/**
 * "Type,Type,Type" etc...
 */
string typeString(Type[] types) {
    string s;
    foreach(i, t; types) {
        if(i>0) s~=",";
        s ~= t.toString();
    }
    return s;
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

    if(a.isClass() || b.isClass()) {
        // todo - some clever logic here
        return UNKNOWN_TYPE;
    }
    if(a.isComponent() || b.isComponent()) {
        // todo - some clever logic here
        return UNKNOWN_TYPE;
    }
    if(a.isFunction() || b.isFunction()) {
        return UNKNOWN_TYPE;
    }

    if(a.isPtr() || b.isPtr()) {
        return UNKNOWN_TYPE;
    }
    // if(a.isTuple || b.isTuple) {
    //     // todo - some clever logic here
    //     return UNKNOWN_TYPE;
    // }
    if(a.isStruct() || b.isStruct()) {
        // todo - some clever logic here
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

bool isBuiltinType(ParseState state) {
    string s;
    for(int i = 0; true; i++) {
        s = state.peek(i).text;
        if("ref" != s) break;
        i++;
    }

    switch(s) {
        case "bool":
        case "byte":
        case "short":
        case "int":
        case "float":
        case "long":
        case "double":
        case "void":
            return true;
        default:
            return false;
    }
    assert(false);
}

bool isType(ParseState state) {
    if(isBuiltinType(state)) return true;

    string s = state.text();

    if(state.mod.declaresType(s, true)) return true;

    return false;
}

/**
 * { * } (bool|byte|int|etc..|StructType|FunctionType|EnumType)
 *
 */
Type parseType(ParseState state, Node parent) {
    Type t;

    switch(state.text()) {
        case "bool":
            t = new BuiltinType(TypeKind.BOOL);
            state.next();
            break;
        case "byte":
            t = new BuiltinType(TypeKind.BYTE);
            state.next();
            break;
        case "short":
            t = new BuiltinType(TypeKind.SHORT);
            state.next();
            break;
        case "int":
            t = new BuiltinType(TypeKind.INT);
            state.next();
            break;
        case "long":
            t = new BuiltinType(TypeKind.LONG);
            state.next();
            break;
        case "float":
            t = new BuiltinType(TypeKind.FLOAT);
            state.next();
            break;
        case "double":
            t = new BuiltinType(TypeKind.DOUBLE);
            state.next();
            break;
        case "void":
            t = new BuiltinType(TypeKind.VOID);
            state.next();
            break;
        case "fn":
            t = new FunctionType().parse(state, parent);
            break;
        case "struct":
            todo("unnamed struct");
            break;
        case "array":
            todo("array");
            break;
        default:
            // struct, class, enum, typedef
            t = resolveType(state.text(), parent);

            if(!t) {
                t = new UnresolvedType(state.text());
            }
            break;
    }
    if(t) {
        while(TokenKind.ASTERISK == state.kind()) {
            t.ptrDepth++;
            state.next();
        }
    }

    return t;
}

bool declarationExists(string name, Node node) {
    bool[Declaration] decls;
    node.findDeclaration(name, decls, node);
    return decls.length > 0;
}

Type resolveType(string name, Node node) {
    bool[Declaration] decls;
    node.findDeclaration(name, decls, node);
    if(decls.length==1) {
        auto d = decls.keys()[0];
        if(d.isResolved()) {
            if(d.isA!StructDecl) {
                return new StructType(d.as!StructDecl.getStructLiteral());
            }
        }
        return null;
    } else if(decls.length>1) {
        // this is an error
        return null;
    }
    // error - not found
    return null;
}

Type resolveType(Node node, Type type) {
    if(type.isResolved()) return type;

    auto mod = node.mod;
    auto ut = type.as!UnresolvedType;

    if(ut) {
        auto t = resolveType(ut.name, node);
        if(t) return t;
    }
    return type;
}