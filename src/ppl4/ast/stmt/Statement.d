module ppl4.ast.stmt.Statement;

import ppl4.all;

abstract class Statement : Node {
public:
    Module mod;
    bool isResolved;

    this(Module mod) {
        this.mod = mod;
    }

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
            if(!importAllowed) new SyntaxError(state.mod, state.line(), state.column());
            todo();
        }

        auto kind1 = state.peek(1).kind;

        if(kind1 == TokenKind.EQUALS) {
            // name = struct
            // name = fn
            // name = expression

            auto text = state.peek(2).text;

            if("extern" == text) {
                if(!functionAllowed) throw new SyntaxError(state);
                add(new Function(mod, pub).parse(state));

            } else if("struct" == text) {
                if(!structAllowed) throw new SyntaxError(state);
                add(new Struct(mod, pub).parse(state));

            } else if("fn" == text) {
                if(!functionAllowed) throw new SyntaxError(state);
                add(new Function(mod, pub).parse(state));

            } else {
                // For now assume it is a Variable

                if(!variableAllowed) throw new SyntaxError(state);
                add(new Variable(mod, pub).parse(state));
            }
        } else if(kind1 == TokenKind.COLON) {
            // name : type [ = expression ]

            if(!variableAllowed) throw new SyntaxError(state);
            add(new Variable(mod, pub).parse(state));
        } else {
            todo("%s".format(state.peek()));
        }

        return this;
    }

    bool resolve() {
        bool result = true;
        foreach(stmt; children) {
            result &= stmt.resolve();
        }
        return result;
    }

    bool check() {
        bool result = true;
        foreach(stmt; children) {
            result &= stmt.check();
        }
        return result;
    }

    bool generate() {
        bool result = true;
        foreach(stmt; children) {
            result &= stmt.generate();
        }
        return result;
    }

    bool checkPublicAndConsume(ParseState state) {
        if(state.kind()==TokenKind.PLUS) {
            state.next();
            return true;
        }
        return false;
    }
}