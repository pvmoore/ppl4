module ppl4.Operator;

import ppl4.all;

/**
 *  Operator precedence. Lower is higher.
 */
enum Operator {
    NONE,

    DOT,            // .
    CALL,           // call()
    //INDEX,        // get(), set() same as call()

    CAST,           // as Type

    DIV,            // /
    MUL,            // *
    MOD,            // %
    ADD,            // +
    SUB,            // -
    SHL,            // shl
    SHR,            // shr
    USHR,           // ushr
    ROL,            // rol
    ROR,            // ror
    UGT,            // ugt
    UGTE,           // ugte
    ULT,            // ult
    ULTE,           // ulte
    BITAND,         // &
    BITOR,          // |
    BITXOR,         // ^

    ASSIGN,         // =        // do we need this here?
    REASSIGN,       // :=
    DIV_ASSIGN,     // /=
    MUL_ASSIGN,     // *=
    MOD_ASSIGN,     // %=
    ADD_ASSIGN,     // +=
    SUB_ASSIGN,     // -=
    SHL_ASSIGN,     // shl=
    SHR_ASSIGN,     // shr=
    USHR_ASSIGN,    // ushr=
    BITAND_ASSIGN,  // &=
    BITOR_ASSIGN,   // |=
    BITXOR_ASSIGN,  // ^=

    EQ,             // ==   // operator overloadable
    NE,             // !=   // operator overloadable
    IS,             // is
    LT,             // <
    LTE,            // <=
    GT,             // >
    GTE,            // >=
    AND,            // and
    OR,             // or

    ASSERT,         // assert
    NUMBER,         //
    TYPE_EXPRESSION,//
    IDENTIFIER,     //
    PARENS,         //
    NULL            // null
}

int precedenceOf(Operator o) {
    final switch(o) with(Operator) {
        case DOT: return 2;
        case CALL: return 2;

        case CAST: return 5;

        case DIV: return 14;
        case MUL: return 14;
        case MOD: return 14;

        case ADD: return 15;
        case SUB: return 15;
        case SHL: return 15;
        case SHR: return 15;
        case USHR: return 15;
        case ROL: return 15;
        case ROR: return 15;

        case BITAND: return 15;
        case BITOR: return 15;
        case BITXOR: return 15;

        case EQ: return 18;
        case NE: return 18;
        case IS: return 18;
        case LT: return 18;
        case LTE: return 18;
        case GT: return 18;
        case GTE: return 18;
        case UGT: return 15;
        case UGTE: return 15;
        case ULT: return 15;
        case ULTE: return 15;

        case AND: return 21;
        case OR: return 21;

        case ASSIGN: return 40;
        case REASSIGN: return 40;
        case DIV_ASSIGN: return 40;
        case MUL_ASSIGN: return 40;
        case MOD_ASSIGN: return 40;
        case ADD_ASSIGN: return 40;
        case SUB_ASSIGN: return 40;
        case SHL_ASSIGN: return 40;
        case SHR_ASSIGN: return 40;
        case USHR_ASSIGN: return 40;
        case BITAND_ASSIGN: return 40;
        case BITOR_ASSIGN: return 40;
        case BITXOR_ASSIGN: return 40;

        case ASSERT: return 50;
        case NUMBER: return 50;
        case TYPE_EXPRESSION: return 50;
        case IDENTIFIER: return 50;
        case PARENS: return 50;
        case NULL: return 50;
        case NONE: return 50;
    }
}

Operator toOperator(ParseState state) {
    auto k = state.kind();

    switch(k) with(TokenKind) {
        case FSLASH: return Operator.DIV;
        case ASTERISK: return Operator.MUL;
        case PERCENT: return Operator.MOD;
        case PLUS: return Operator.ADD;
        case MINUS: return Operator.SUB;
        case PIPE: return Operator.BITOR;
        case AMPERSAND: return Operator.BITAND;
        case HAT: return Operator.BITXOR;
        case COLON_EQUALS: return Operator.REASSIGN;
        case LARROW: return Operator.LT;
        case LARROW_EQ: return Operator.LTE;
        case RARROW: return Operator.GT;
        case RARROW_EQ: return Operator.GTE;
        case DBL_EQUALS: return Operator.EQ;
        case BANG_EQUALS: return Operator.NE;

        default: break;
    }

    switch(state.text()) {
        case "and": return Operator.AND;
        case "or": return Operator.OR;
        case "shl": return Operator.SHL;
        case "shr": return Operator.SHR;
        case "ushr": return Operator.USHR;
        case "rol": return Operator.ROL;
        case "ror": return Operator.ROR;
        case "ugt": return Operator.UGT;
        case "ugte": return Operator.UGTE;
        case "ult": return Operator.ULT;
        case "ulte": return Operator.ULTE;
        default: break;
    }

    return Operator.NONE;
}

bool isBoolean(Operator o) {
    switch(o) with(Operator) {
        case OR:
        case AND:
        case EQ:
        case NE:
        case GT:
        case GTE:
        case LT:
        case LTE:
        case UGT:
        case UGTE:
        case ULT:
        case ULTE:
            return true;
        default:
            return false;
    }
    assert(false);
}

bool isAssign(Operator o) {
    switch(o) with(Operator) {
        case ASSIGN:
        case REASSIGN:
        case DIV_ASSIGN:
        case MUL_ASSIGN:
        case MOD_ASSIGN:
        case ADD_ASSIGN:
        case SUB_ASSIGN:
        case SHL_ASSIGN:
        case SHR_ASSIGN:
        case USHR_ASSIGN:
        case BITAND_ASSIGN:
        case BITOR_ASSIGN:
        case BITXOR_ASSIGN:
            return true;
        default:
            return false;
    }
    assert(false);
}

bool isPtrArithmetic(Operator o) {
    // todo
    return false;
}