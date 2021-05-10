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
public:
    Statement[] children;
    Statement parent;
    int uid;    // unique id per Module

    abstract NodeId id();

    final bool hasParent() { return parent !is null; }
    final bool hasChildren() { return numChildren() > 0; }
    final int numChildren() { return children.length.as!int; }
    final Statement first() { return numChildren() > 0 ? children[0] : null; }
    final Statement last() { return numChildren() > 0 ? children[$-1] : null; }

    final Statement add(Statement n) {
        n.detach();
        children ~= n;
        n.parent = this.as!Statement;
        return this.as!Statement;
    }

    final Statement insertAt(int i, Statement n) {
        expect(i>=0 && i<=children.length);
        n.detach();
        children.insertAt(i, n);
        n.parent = this.as!Statement;
        return this.as!Statement;
    }
    /**
     *  Remove a child node at index. Default is the last child.
     */
    final Statement remove(int index = -1) {
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
    Statement prev() {
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
    Statement next() {
        if(hasParent()) {
            auto i = parent.indexOf(this);
            if(i < parent.numChildren()-1) {
                return parent.children[i+1];
            }
            return parent.next();
        }
        return null;
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

    void dump(ref string buf, string indent = "") {
        buf ~= "%s%s\n".format(indent, this);
        foreach(ch; children) {
            ch.dump(buf, indent ~ "    ");
        }
    }

    string dumped() {
        string buf;
        dump(buf);
        return buf;
    }
}