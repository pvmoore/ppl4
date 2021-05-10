module ppl4.types.TypeKind;

import ppl4.all;

enum TypeKind {
    UNKNOWN,
    BOOL,
    BYTE,
    SHORT,
    INT,
    LONG,
    FLOAT,
    DOUBLE,

    VOID,

    STRUCT, // struct or class

    FUNCTION
}

string toString(TypeKind k) {
    final switch(k) with(TypeKind) {
        case UNKNOWN: return "UNKNOWN";
        case BOOL: return "bool";
        case BYTE: return "byte";
        case SHORT: return "short";
        case INT: return "int";
        case LONG: return "long";
        case FLOAT: return "float";
        case DOUBLE: return "double";

        case VOID: return "void";

        case STRUCT: return "struct";

        case FUNCTION: return "fn";
    }
}