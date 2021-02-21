module ppl4.ast.stmt.Statement;

import ppl4.all;

abstract class Statement : Node {
public:
    Module mod;
    Token startToken;
    bool isResolved;

    this(Module mod) {
        this.mod = mod;
    }

    final int line() { return startToken.line; }
    final int column() { return startToken.column; }

    //abstract Function findFunction(string name);
    //abstract Variable findVariable(string name);
    //asbtract ITarget findTarget(string name);  // ITarget is Variable | Function
    //abstract Type findType(string name);

    /**
     * Variable | Function | Enum | Import
     * TypeDef | Struct | Class
     */
    Statement parse(ParseState state) {
        expect(this.isA!Module || this.isA!Struct);

        bool structAllowed   = this.isA!Module;
        bool functionAllowed = true;
        bool variableAllowed = true;
        bool enumAllowed     = this.isA!Module;
        bool importAllowed   = true;

        // +
        auto pub = checkPublicAndConsume(state);

        if("import" == state.text()) {
            if(!importAllowed) syntaxError(state);
            todo();
        }

        auto kind1 = state.peek(1).kind;

        if(kind1 == TokenKind.EQUALS) {
            // name = struct
            // name = fn
            // name = expression

            auto text = state.peek(2).text;

            if("extern" == text) {
                if(!functionAllowed) syntaxError(state);

                //add(new Function(mod, pub).parse(state));
                add(state.make!Function(pub).parse(state));

            } else if("struct" == text) {
                if(!structAllowed) syntaxError(state);
                add(state.make!Struct(pub).parse(state));

            } else if("fn" == text) {
                if(!functionAllowed) syntaxError(state);
                add(state.make!Function(pub).parse(state));

            } else {
                // For now assume it is a Variable

                if(!variableAllowed) syntaxError(state);
                add(state.make!Variable(pub).parse(state));
            }
        } else if(kind1 == TokenKind.COLON) {
            // name : type [ = expression ]

            if(!variableAllowed) syntaxError(state);
            add(state.make!Variable(pub).parse(state));
        } else {
            todo("%s".format(state.peek()));
        }

        return this;
    }

    void resolve(ResolveState state) {
        foreach(stmt; children) {
            stmt.resolve(state);
        }
    }

    bool check() {
        bool result = true;
        foreach(stmt; children) {
            result &= stmt.check();
        }
        return result;
    }

    void generate(GenState state) {
        foreach(stmt; children) {
            stmt.generate(state);
        }
    }
protected:
    bool checkPublicAndConsume(ParseState state) {
        if(state.kind()==TokenKind.PLUS) {
            state.next();
            return true;
        }
        return false;
    }
}