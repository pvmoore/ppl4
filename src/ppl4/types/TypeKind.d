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

    STRUCT,
    CLASS,
    COMPONENT,

    FUNCTION
}

bool isInteger(TypeKind k) { with(TypeKind) return k.isOneOf(BYTE, SHORT, INT, LONG); }
bool isReal(TypeKind k) { return k.isOneOf(TypeKind.FLOAT, TypeKind.DOUBLE); }

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
        case CLASS: return "class";
        case COMPONENT: return "component";

        case FUNCTION: return "fn";
    }
}