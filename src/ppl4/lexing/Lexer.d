module ppl4.lexing.Lexer;

import ppl4.all;

final class Lexer {
private:
    Module mod;
    string text;
    int pos;
    int bufStart;
    int line, lineStart;
    int startLine = -1, startColumn = -1;
    Token[] tokens;
    Token[] commentTokens;
public:
    this(Module mod, string text) {
        this.mod = mod;
        this.text = text;
    }
    Token[] getCodeTokens() {
        return tokens;
    }
    Token[] getCommentTokens() {
        return commentTokens;
    }
    void lex() {

        while(pos < text.length) {

            auto last = pos;

            auto c = peek();

            if(c < 33) {
                addToken();
                if(!handleEOL()) {
                    pos++;
                }
                bufStart = pos;
            } else switch(c) with(TokenKind) {
                case '=':
                    if(peek(1)=='=') {
                        addToken(DBL_EQUALS);
                    } else {
                        addToken(EQUALS);
                    }
                    break;
                case '<':
                    if(peek(1)=='=') {
                        addToken(LARROW_EQ);
                    } else {
                        addToken(LARROW);
                    }
                    break;
                case '>':
                    if(peek(1)=='=') {
                        addToken(RARROW_EQ);
                    } else {
                        addToken(RARROW);
                    }
                    break;
                case '!':
                    if(peek(1)=='=') {
                        addToken(BANG_EQUALS);
                    }
                    break;
                case ':':
                    if(peek(1)=='=') {
                        addToken(COLON_EQUALS);
                    } else {
                        addToken(COLON);
                    }
                    break;
                case ',':
                    addToken(COMMA);
                    break;
                case '+':
                    if(peek(1)=='=') {
                        addToken(PLUS_EQ);
                    } else {
                        addToken(PLUS);
                    }
                    break;
                case '-':
                    if(bufStart==0 && peek(1)>='0' && peek(1)<='9') {
                        // negative number
                        pos++;
                    } else if(peek(1)=='=') {
                        addToken(MINUS_EQ);
                    } else {
                        addToken(MINUS);
                    }
                    break;
                case '*':
                    if(peek(1)=='=') {
                        addToken(ASTERISK_EQ);
                    } else {
                        addToken(ASTERISK);
                    }
                    break;
                case '/':
                    if(peek(1)=='*') {
                        parseMLComment();
                    } else if(peek(1)=='/') {
                        parseLComment();
                    } else if(peek(1)=='=') {
                        addToken(FSLASH_EQ);
                    } else {
                        addToken(FSLASH);
                    }
                    break;
                case '%':
                    if(peek(1)=='=') {
                        addToken(PERCENT_EQ);
                    } else {
                        addToken(PERCENT);
                    }
                    break;
                case '|':
                    addToken(PIPE);
                    break;
                case '&':
                    addToken(AMPERSAND);
                    break;
                case '^':
                    addToken(HAT);
                    break;
                case '{':
                    addToken(LCURLY);
                    break;
                case '}':
                    addToken(RCURLY);
                    break;
                case '(':
                    addToken(LBRACKET);
                    break;
                case ')':
                    addToken(RBRACKET);
                    break;
                case '[':
                    addToken(LSQUARE);
                    break;
                case ']':
                    addToken(RSQUARE);
                    break;
                default:
                    pos++;
                    break;
            }

            if(pos == last) {
                error("bail");
                break;
            }
        }
    }
private:
    char peek() {
        return text[pos];
    }
    char peek(int offset) {
        if(pos+offset>=text.length) return 0;
        return text[pos+offset];
    }
    bool handleEOL() {
        bool isEOL = false;
        if(peek()==13 && peek(1)==10) {
            pos += 2;
            isEOL = true;
        } else if(peek()==13) {
            pos++;
            isEOL = true;
        } else if(peek()==10) {
            pos++;
            isEOL = true;
        }
        if(isEOL) {
            line++;
            lineStart = pos;
        }
        return isEOL;
    }
    void parseMLComment() {
        assert(peek()=='/' && peek(1)=='*');
        addToken();

        startLine = line;
        startColumn = pos - lineStart;

        while(pos < text.length) {

             if(peek()=='*' && peek(1)=='/') {
                 pos+=2;
                 addToken();
                 return;
             }
             if(!handleEOL()) {
                pos++;
             }
        }
        // error
    }
    void parseLComment() {
        assert(peek()=='/' && peek(1)=='/');
        addToken();

        while(pos < text.length) {
            if(peek() == 10 || peek() == 13) {
                addToken();
                handleEOL();
                bufStart = pos;
                return;
            }
            pos++;
        }
        addToken();
    }
    auto determineTokenKind(string t) {
        if(t[0]=='/' && t[1]=='/') return TokenKind.L_COMMENT;
        if(t[0]=='/' && t[1]=='*') return TokenKind.ML_COMMENT;
        if(t[0] >= '0' && t[0] <= '9') return TokenKind.NUMBER;
        return TokenKind.IDENTIFIER;
    }
    void doAddToken(TokenKind k, string text) {
        auto column = startColumn == -1 ? bufStart - lineStart : startColumn;
        auto ln = startLine == -1 ? line : startLine;

        Token t = {
            kind: k,
            text: text,
            start: bufStart,
            length: pos - bufStart,
            line: ln,
            column: column
        };
        if(k.isComment()) {
            commentTokens ~= t;
        } else {
            tokens ~= t;
        }
        startLine = startColumn = -1;
    }
    void addToken(TokenKind k = TokenKind.NONE) {
        if(bufStart < pos) {
            auto t = text[bufStart..pos];
            doAddToken(determineTokenKind(t), t);
            bufStart = pos;
        }
        if(k != TokenKind.NONE) {
            auto t = From!"ppl4.lexing.TokenKind".toString(k);
            doAddToken(k, t);
            pos += t.length.as!int;
            bufStart = pos;
        }
    }
}