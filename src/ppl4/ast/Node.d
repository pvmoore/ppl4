module ppl4.ast.Node;

import ppl4.all;

enum NodeId {
    ASSERT,
    AT_FUNC,
    BINARY,
    CALL,
    CAST,
    FUNCTION,
    IDENTIFIER,
    IMPORT,
    MODULE,
    NULL,
    NUMBER,
    PARENS,
    RETURN,
    STRUCT,
    TYPE_REFERENCE,
    VARIABLE
}

abstract class Node {
protected:
    bool _isResolved;
public:
    Statement[] children;
    Node parent;
    int uid;    // unique id per Module

    abstract NodeId id();

    final bool hasParent() { return parent !is null; }
    final bool hasChildren() { return numChildren() > 0; }
    final int numChildren() { return children.length.as!int; }
    final Statement first() { return numChildren() > 0 ? children[0] : null; }
    final Statement last() { return numChildren() > 0 ? children[$-1] : null; }

    final void setResolved() { this._isResolved = true; }

    bool isResolved() { return _isResolved; }

    final Node add(Statement n) {
        n.detach();
        children ~= n;
        n.parent = this.as!Node;
        return this.as!Statement;
    }

    final Node insertAt(int i, Statement n) {
        expect(i>=0 && i<=children.length);
        n.detach();
        children.insertAt(i, n);
        n.parent = this.as!Node;
        return this.as!Statement;
    }
    /**
     *  Remove a child node at index. Default is the last child.
     */
    final Node remove(int index = -1) {
        expect(hasChildren());
        index = index==-1 ? children.length.as!int-1 : index;
        expect(index < children.length);

        auto ch = children.removeAt(index);
        ch.parent = null;

        return ch;
    }
    /**
     *  Detach this Node from its parent
     */
    final void detach() {
        if(!hasParent()) return;
        auto i = parent.indexOf(this);
        expect(i != -1);
        parent.remove(i);
        parent = null;
    }

    /**
     * Wraps _this_ and adds to tree in the same position.
     */
    final void wrapWith(Statement stmt) {
        expect(parent !is null);
        expect(!stmt.hasParent());
        auto p = parent;
        auto i = index();

        this.detach();
        p.insertAt(i, stmt);
        stmt.add(this.as!Statement);
    }

    /**
     *  Replace a child with another one.
     */
    final void replace(Statement me, Statement withMe) {
        auto i = me.index();
        expect(i!=-1);

        auto p = me.parent;
        p.insertAt(i, withMe);
        me.detach();
    }

    /**
     * @returns the index of this child (or -1)
     */
    final int indexOf(Node child) {
        foreach(i, ch; children) {
            if(ch is child) return i.as!int;
        }
        return -1;
    }

    /**
     *  @returns child index of this or -1
     */
    final int index() {
        if(hasParent()) {
            return parent.indexOf(this);
        }
        return -1;
    }

    /**
     *  @returns logically previous Node.
     */
    final Node prev() {
        if(hasParent()) {
            auto i = parent.indexOf(this);
            if(i>0) {
                return parent.children[i-1];
            }
            return parent;
        }
        return null;
    }

    /**
     *  @returns logically next Node.
     */
    final Node next() {
        if(hasParent()) {
            auto i = parent.indexOf(this);
            if(i < parent.numChildren()-1) {
                return parent.children[i+1];
            }
            return parent.next();
        }
        return null;
    }

    final void dump(ref string buf, string indent = "") {
        buf ~= "%s%s\n".format(indent, this);
        foreach(ch; children) {
            ch.dump(buf, indent ~ "    ");
        }
    }
    final string dumped() {
        string buf;
        dump(buf);
        return buf;
    }

    //abstract Function findFunction(string name);
    //abstract Variable findVariable(string name);

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
    Node parse(ParseState state) {
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

    T ancestor(T)() {
        if(!hasParent()) return null;
        if(parent.isA!T) return parent.as!T;
        return parent.ancestor!T;
    }

    T[] collectChildren(T)() {
        T[] things;
        foreach(ch; children) {
            if(ch.isA!T) things ~= ch.as!T;
        }
        return things;
    }

    T[] collect(T)(bool delegate(T t) filter = null) {
        T[] things;
        each!T((t) {
            if(!filter || filter(t)) {
                things ~= t;
            }
        });
        return things;
    }

    void each(T)(void delegate(T t) call) {
        if(this.isA!T) {
            call(this.as!T);
        }
        foreach(ch; children) {
            ch.each(call);
        }
    }
protected:
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
private:
    bool checkPublicAndConsume(ParseState state) {
        if(state.kind()==TokenKind.PLUS) {
            state.next();
            return true;
        }
        return false;
    }
}