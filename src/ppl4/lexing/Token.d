module ppl4.lexing.Token;

import ppl4.all;

__gshared {
    Token NO_TOKEN = Token(TokenKind.NONE);
}

struct Token {
    TokenKind kind;
    string text;
    int start;
    int length;
    int line;
    int column;

    string toString() {
        //auto ks = From!"ppl4.lexing.TokenKind".toString(kind);
        auto ks = "%s".format(kind);
        return "[Token %s %s %s-%s %s:%s]".format(
            ks, text, start, start+length-1, line,column);
    }
}

string toString(Token[] tokens) {
    string s;
    foreach(t; tokens) {
        s ~= "\n%s".format(t);
    }
    return s;
}