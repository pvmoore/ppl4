module ppl4.ParseState;

import ppl4.all;

final class ParseState {
private:
    int pos;
    Token[] tokens;
public:
    Module mod;

    this(Module mod, Token[] tokens) {
        this.mod = mod;
        this.tokens = tokens;
    }

    Token peek(int i = 0) {
        if(pos+i < 0) return NO_TOKEN;
        if(pos+i >= tokens.length) return NO_TOKEN;
        return tokens[pos+i];
    }
    auto next(int n = 1) {
        foreach(i; 0..n) {
            move();
        }
        return this;
    }
    TokenKind kind() {
        return peek().kind;
    }
    string text() {
        return peek().text;
    }
    int line() {
        return peek().line;
    }
    int column() {
        return peek().column;
    }
    bool isKind(TokenKind k) {
        return kind() == k;
    }
    bool isNotKind(TokenKind k) {
        return kind() != k;
    }
    bool isOneOf(TokenKind[] kinds...) {
        auto kk = kind();
        foreach(k; kinds) {
            if(kk==k) return true;
        }
        return false;
    }
    bool isNotOneOf(TokenKind[] kinds...) {
        return !isOneOf(kinds);
    }
    bool isEOF() {
        return pos >= tokens.length;
    }
    bool isNewLine() {
        if(pos==0) return false;
        return line() > tokens[pos-1].line;
    }
    auto skip(TokenKind k) {
        if(kind() != k) {
            syntaxError(this);
        }
        return next();
    }
    auto trySkip(TokenKind k) {
        if(kind() == k) next();
        return this;
    }
    auto skip(string kw) {
        if(text() != kw) {
            syntaxError(this);
        }
        return next();
    }
    void expectOneOf(TokenKind[] kinds...) {
        auto kk = kind();
        foreach(k; kinds) {
            if(kk==k) return;
        }
        //throw new Error("");
        syntaxError(this, "Expected one of %s".format(kinds));
    }
private:
    void move() {
        pos++;
    }
    /**
     * @return Tokens on the previous line
     */
    Token[] getPrevLineTokens() {
        int prevLine = line() - 1;
        if(prevLine < 0) return null;

        auto offset = pos-1;
        int start = int.max, end=int.min;
        while(offset >= 0) {
            auto line = tokens[offset].line;
            if(line == prevLine) {
                start = minOf(start, offset);
                end = maxOf(end, offset);
            } else if(line < prevLine) break;
            offset--;
        }
        if(start!=int.max) {
            return tokens[start..end+1];
        }
        return null;
    }
}