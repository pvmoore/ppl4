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

    COLON,          // :
    COMMA,          // ,
    EQUALS,         // =
    COLON_EQUALS,   // :=

    DBL_EQUALS,     // ==
    BANG_EQUALS,     // !=
    LARROW,         // <
    RARROW,         // >
    LARROW_EQ,      // <=
    RARROW_EQ,      // >=

    RT_ARROW,       // ->

    PLUS,           // +
    MINUS,          // -
    ASTERISK,       // *
    FSLASH,         // /
    PERCENT,        // %
    PIPE,           // |
    AMPERSAND,      // &
    HAT,            // ^

    PLUS_EQ,        // +=
    MINUS_EQ,       // -=
    ASTERISK_EQ,    // *=
    FSLASH_EQ,      // /=
    PERCENT_EQ,     // %=

    BSLASH,         // \
    LCURLY,         // {
    RCURLY,         // }
    LBRACKET,       // (
    RBRACKET,       // )
    LSQUARE,        // [
    RSQUARE,        // ]


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
        case COLON_EQUALS: return ":=";

        case DBL_EQUALS: return "==";
        case BANG_EQUALS: return "!=";
        case LARROW: return "<";
        case RARROW: return ">";
        case LARROW_EQ: return "<=";
        case RARROW_EQ: return ">=";

        case RT_ARROW: return "->";

        case PLUS: return "+";
        case MINUS: return "-";
        case ASTERISK: return "*";
        case FSLASH: return "/";
        case PERCENT: return "%";

        case PIPE: return "|";
        case AMPERSAND: return "&";
        case HAT: return "^";

        case PLUS_EQ: return "+=";
        case MINUS_EQ: return "-=";
        case ASTERISK_EQ: return "*=";
        case FSLASH_EQ: return "/=";
        case PERCENT_EQ: return "%=";

        case BSLASH: return "\\";
        case LCURLY: return "{";
        case RCURLY: return "}";
        case LBRACKET: return "(";
        case RBRACKET: return ")";
        case LSQUARE: return "[";
        case RSQUARE: return "]";
    }
}
