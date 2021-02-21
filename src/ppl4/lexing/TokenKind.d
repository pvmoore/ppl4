module ppl4.lexing.TokenKind;

import ppl4.all;

enum TokenKind {
    NONE,
    STRING,
    CHAR,
    NUMBER,
    IDENTIFIER,
    L_COMMENT,
    ML_COMMENT,

    COLON,      // :
    COMMA,      // ,
    EQUALS,     // =
    ASSIGN,     // :=
    DBL_EQUALS, // ==


    PLUS,       // +
    MINUS,      // -
    MUL,        // *
    DIV,        // /

    PLUS_EQ,    // +=
    MINUS_EQ,   // -=
    MUL_EQ,     // *=
    DIV_EQ,     // /=

    BSLASH,     // \
    LCURLY,     // {
    RCURLY,     // }
    LBRACKET,   // (
    RBRACKET,   // )

}

bool isComment(TokenKind k) {
    return k == TokenKind.L_COMMENT ||
           k == TokenKind.ML_COMMENT;
}

string toString(TokenKind k) {
    final switch(k) with(TokenKind) {
        case NONE: return "NONE";
        case STRING: return "";
        case CHAR: return "";
        case NUMBER: return "";
        case IDENTIFIER: return "";
        case L_COMMENT: return "";
        case ML_COMMENT: return "";
        case COLON: return ":";
        case COMMA: return ",";
        case EQUALS: return "=";
        case ASSIGN: return ":=";
        case DBL_EQUALS: return "==";
        case PLUS: return "+";
        case MINUS: return "-";
        case MUL: return "*";
        case DIV: return "/";

        case PLUS_EQ: return "+=";
        case MINUS_EQ: return "-=";
        case MUL_EQ: return "*=";
        case DIV_EQ: return "/=";

        case BSLASH: return "\\";
        case LCURLY: return "{";
        case RCURLY: return "}";
        case LBRACKET: return "(";
        case RBRACKET: return ")";
    }
}