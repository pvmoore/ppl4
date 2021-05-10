module ppl4.ast.stmt.Statement;

import ppl4.all;

abstract class Statement : Node {
protected:
    bool _isResolved;
public:
    Module mod;
    Token startToken;

    this(Module mod) {
        this.mod = mod;
    }

    final int line() { return startToken.line; }
    final int column() { return startToken.column; }
    bool isResolved() { return _isResolved; }
    final void setResolved() { this._isResolved = true; }

    //abstract Function findFunction(string name);
    //abstract Variable findVariable(string name);
    //abstract Type findType(string name);

    /**
     * Find all Variables or Functions with the specified _name_.
     * Assume the start node is an Identifier or a Call.
     */
    void findTarget(string name, ref ITarget[] targets, Expression src) {
        if(auto p = prev()) {
            //trace("p= %s", p);
            p.findTarget(name, targets, src);
        }
    }

    /**
     * Variable | Function | Enum | Import
     * TypeDef | Struct | Class
     */
    Statement parse(ParseState state) {
        expect(this.isA!Module || this.isA!Struct || this.isA!Function);

        bool publicAllowed      = this.isA!Module || this.isA!Struct;
        bool structAllowed      = this.isA!Module;
        bool enumAllowed        = this.isA!Module;
        bool returnAllowed      = this.isA!Function;
        bool expressionsAllowed = this.isA!Function;
        bool functionAllowed    = true;
        bool variableAllowed    = true;
        bool importAllowed      = true;

        // +
        auto pub = checkPublicAndConsume(state);
        if(pub && !publicAllowed) {
            publicNotAllowed(state);
        }

        if("import" == state.text()) {
            if(!importAllowed) syntaxError(state);
            todo();
        }
        if("assert" == state.text()) {
            add(state.make!Assert().parse(state));
            return this;
        }
        if("return" == state.text()) {
            if(!returnAllowed) statementNotAllowed(state, "return");
            add(state.make!Return().parse(state));
            return this;
        }

        auto kind1 = state.peek(1).kind;

        if(kind1 == TokenKind.EQUALS) {
            // name = struct
            // name = class
            // name = fn
            // name = expression

            auto text = state.peek(2).text;

            if("extern" == text) {
                if(!functionAllowed) syntaxError(state);

                //add(new Function(mod, pub).parse(state));
                add(state.make!Function(pub).parse(state));

            } else if("struct" == text) {
                if(!structAllowed) syntaxError(state);
                // Add Struct to tree before parsing so that we
                // can reference it while parsing the struct
                auto s = state.make!Struct(pub);
                add(s);
                s.parse(state);

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
        } else if(kind1 == TokenKind.COLON_EQUALS) {
            // reassign
            // name := Expression
            if(!expressionsAllowed) syntaxError(state);
            parseExpression(state, this);
        } else if(kind1 == TokenKind.LBRACKET) {
            // call
            // cast
            // name ( args )
            if(!expressionsAllowed) syntaxError(state);
            parseExpression(state, this);
        } else {
            todo("%s".format(state.peek()));
        }
        return this;
    }

    void resolve(ResolveState state) {
        //trace("Resolve %s (%s children)", this.id(), numChildren());
        foreach(stmt; children) {
            stmt.resolve(state);
        }
    }

    void check() {
        foreach(stmt; children) {
            stmt.check();
        }
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
    Type resolveTypeFromParent() {
        switch(parent.id()) with(NodeId) {
            case VARIABLE:
                auto var = parent.as!Variable;
                if(var.type().isResolved()) {
                    return var.type();
                }
                break;
            default:
                todo("implement %s.resolveTypeFromParent - parent is %s".format(this.id(), parent.id()));
                break;
        }
        return UNKNOWN_TYPE;
    }
}