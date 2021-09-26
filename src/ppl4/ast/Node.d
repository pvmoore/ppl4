module ppl4.ast.Node;

import ppl4.all;

enum NodeId {
    ASSERT,
    AT_FUNC,
    BINARY,
    CALL,
    CAST,

    DECLARATION,

    EXTERN_FN_DECL,
    FN_DECL,
    FN_LITERAL,

    IDENTIFIER,
    IMPORT,
    MODULE,
    NULL,
    NUMBER,
    PARENS,
    RETURN,

    STRUCT_DECL,
    STRUCT_LITERAL,

    TYPE_EXPRESSION,

    VAR_DECL
}

abstract class Node {
protected:
    bool _isResolved;
public:
    Module mod;
    Statement[] children;
    Node parent;
    int uid;    // unique id per Module

    bool isResolved() { return _isResolved; }
    void setResolved() { this._isResolved = true; }
    void setUnresolved() { this._isResolved = false; }

    this(Module mod) {
        this.mod = mod;
    }

    override string toString() { return "Node%s".format(uid); }
    override bool opEquals(const Object other) const {
        return other.isA!Node && other.as!Node.uid == uid;
    }
    override size_t toHash() const @safe pure nothrow {
        return uid;
    }

    abstract NodeId id();

    final bool hasParent() { return parent !is null; }
    final bool hasChildren() { return numChildren() > 0; }
    final int numChildren() { return children.length.as!int; }
    final Statement first() { return numChildren() > 0 ? children[0] : null; }
    final Statement last() { return numChildren() > 0 ? children[$-1] : null; }

    final Node add(Statement n) {
        n.detach();
        children ~= n;
        n.parent = this.as!Node;
        return this.as!Statement;
    }

    final Statement addAndReturn(Statement n) {
        add(n);
        return n;
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
    final void replaceChild(Statement me, Statement withMe) {
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

    /**
     *  Find all Declarations with the specified _name_.
     */
    void findDeclaration(string name, ref bool[Declaration] decls, Node src) {
        if(auto p = prev()) {
            //trace("p= %s", p);
            p.findDeclaration(name, decls, src);
        }
    }

    /**
     * Variable | Function | Enum | Import
     * TypeDef | Struct | Class
     */
    Node parse(ParseState state) {
        expect(this.isA!Module || this.isA!FnLiteral || this.isA!StructLiteral);

        //trace("token = %s, %s", state.peek().kind, state.peek(1).kind);

        bool publicAllowed      = this.isA!Module || this.isA!StructLiteral;
        bool structAllowed      = this.isA!Module;
        bool enumAllowed        = this.isA!Module;
        bool returnAllowed      = this.isA!FnLiteral;
        bool expressionsAllowed = this.isA!FnLiteral;
        bool externAllowed      = this.isA!Module;
        bool functionAllowed    = true;
        bool variableAllowed    = true;
        bool importAllowed      = true;
        auto factory = mod.nodeFactory;

        // pub
        auto pub = checkPublicAndConsume(state);
        if(pub && !publicAllowed) {
            publicNotAllowed(state);
        }

        if("import" == state.text()) {
            if(!importAllowed) syntaxError(state);
            todo();
        }
        if("assert" == state.text()) {
            addAndReturn(factory.make!Assert(state.peek())).parse(state);
            return this;
        }
        if("return" == state.text()) {
            if(!returnAllowed) statementNotAllowed(state, "return");
            addAndReturn(factory.make!Return(state.peek())).parse(state);
            return this;
        }

        auto kind1 = state.peek(1).kind;

        //trace(PARSE, "state = %s", state.peek());

        if(kind1 == TokenKind.EQUALS) {
            // name = struct
            // name = class
            // name = fn
            // name = extern fn
            // name = expression
            // name = type

            auto text2 = state.peek(2).text;

            if(text2.isOneOf("struct", "class")) {
                if(!structAllowed) syntaxError(state);
                addAndReturn(factory.make!StructDecl(pub, state.peek())).parse(state);

            } else if(text2 == "extern") {

                if(!functionAllowed) syntaxError(state);
                if(!externAllowed) syntaxError(state);
                addAndReturn(factory.make!ExternFnDecl(pub, state.peek())).parse(state);

            } else if(text2 == "fn") {

                if(!functionAllowed) syntaxError(state);
                addAndReturn(factory.make!FnDecl(pub, state.peek())).parse(state);

            } else {
                // This could be any type of Declaration (probably VarDecl)

                if(!variableAllowed) syntaxError(state);
                addAndReturn(factory.make!VarDecl(pub, state.peek())).parse(state);
            }
        } else if(kind1 == TokenKind.COLON) {
            // This could be any type of Declaration (probably VarDecl)

            // name : type [ = expression ]

            if(!variableAllowed) syntaxError(state);
            addAndReturn(factory.make!VarDecl(pub, state.peek())).parse(state);

        // this stuff below here should just be parseExpression

        } else if(kind1 == TokenKind.COLON_EQUALS) {
            // reassign
            // name := Expression
            if(!expressionsAllowed) syntaxError(state);
            parseExpression(state, this);
        } else if(kind1 == TokenKind.LBRACKET) {
            // call
            // name ( args )
            if(!expressionsAllowed) syntaxError(state);
            parseExpression(state, this);

        } else {
            todo("%s".format(state.peek()));
        }
        return this;
    }

    void resolve(ResolveState state) {
        //trace("Resolve %s (%s children) %s", this.id(), numChildren(), isResolved());
        resolveChildren(state);
    }

    void fold() {
        foldChildren();
    }

    void check() {
        checkChildren();
    }

    void generate(GenState state) {
        generateChildren(state);
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
    void resolveChildren(ResolveState state) {
        //trace("resolve %s", id);
        foreach(stmt; children) {
            stmt.resolve(state);
        }
    }
    void foldChildren() {
        foreach(stmt; children) {
            stmt.fold();
        }
    }
    void checkChildren() {
        foreach(stmt; children) {
            stmt.check();
        }
    }
    void generateChildren(GenState state) {
        foreach(stmt; children) {
            //trace(GEN, "generate %s", stmt.id());
            stmt.generate(state);
        }
    }
    Type resolveTypeFromParent() {
        switch(parent.id()) with(NodeId) {
            case VAR_DECL:
                auto var = parent.as!VarDecl;
                if(var.type.isResolved()) {
                    return var.type;
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
        if(state.text()=="pub") {
            state.next();
            return true;
        }
        return false;
    }
}