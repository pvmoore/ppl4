module ppl4.lexing.Scanner;

import ppl4.all;

struct ScannerResults {
public:
    Module mod;
    bool[string] structs;
    bool[string] enums;
    bool[string] functions;

    bool containsStruct(string name, bool includePrivate) {
        auto p = name in structs;
        return includePrivate ? p !is null : *p;
    }
    bool containsEnum(string name, bool includePrivate) {
        auto p = name in enums;
        return includePrivate ? p !is null : *p;
    }
    bool containsFunction(string name, bool includePrivate) {
        auto p = name in functions;
        return includePrivate ? p !is null : *p;
    }

    string toString() {
        string s = "[ScannerResults '%s'\n".format(mod.name);
        s ~= " +struct .. %s\n".format(structs.byKeyValue().filter!(it=>it.value).map!(it=>it.key).array);
        s ~= "  struct .. %s\n".format(structs.byKeyValue().filter!(it=>!it.value).map!(it=>it.key).array);
         s ~= " +fn ...... %s\n".format(functions.byKeyValue().filter!(it=>it.value).map!(it=>it.key).array);
         s ~= "  fn ...... %s\n".format(functions.byKeyValue().filter!(it=>!it.value).map!(it=>it.key).array);
         s ~= " +enum .... %s\n".format(enums.byKeyValue().filter!(it=>it.value).map!(it=>it.key).array);
         s ~= "  enum .... %s\n".format(enums.byKeyValue().filter!(it=>!it.value).map!(it=>it.key).array);
        return s ~ "]";
    }
}

/**
 *  Scans a Module for functions, classes, structs and enums
 */
final class ModuleScanner {
private:
    Module mod;
    Token[] tokens;
    int pos;
    ScannerResults result;
public:
    this(Module mod) {
        this.mod = mod;
        this.tokens = mod.tokens;
        this.result.mod = mod;
    }
    ScannerResults scan() {
        for(pos = 0; pos <tokens.length; pos++) {

            auto pub = peek().text == "pub";
            if(pub) {
                pos++;
            }
            auto extern_ = peek().text == "extern";
            if(extern_) {
                pos++;
            }

            auto name = peek().kind == TokenKind.IDENTIFIER && peek(1).kind == TokenKind.EQUALS;
            if(name) {
                // [ 'pub' ] [ 'extern' ] name '='
                auto next = peek(2).text;

                if("struct" == next || "class" == next) {
                    result.structs[peek().text] = pub;
                } else if("enum" == next) {
                    result.enums[peek().text] = pub;
                } else if("fn" == next) {
                    result.functions[peek().text] = pub;
                }
                pos += 2;
            } else {
                if(peek().kind == TokenKind.LCURLY) {
                    skipScope();
                }
            }
        }
        result.structs.rehash();
        result.functions.rehash();
        result.enums.rehash();
        return result;
    }
private:
    void skipScope() {
        expect(peek().kind == TokenKind.LCURLY);

        int curly, br;
        while(pos < tokens.length) {
            switch(peek().kind) with(TokenKind) {
                case LBRACKET: br++; break;
                case RBRACKET: br--; break;
                case LCURLY: curly++; break;
                case RCURLY: curly--;
                    if(curly == 0) return;
                    break;
                default:
                    break;
            }
            pos++;
        }
    }
    Token peek(int offset = 0) {
        if(pos+offset >= tokens.length) return NO_TOKEN;
        return tokens[pos+offset];
    }
}