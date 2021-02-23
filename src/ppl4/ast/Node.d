module ppl4.ast.Node;

import ppl4.all;

enum NodeId {
    FUNCTION,
    IMPORT,
    MODULE,
    NUMBER,
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
        expect(!n.parent);
        children ~= n;
        n.parent = this.as!Statement;
        return this.as!Statement;
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

    void dump(string indent = "") {
        trace("%s%s".format(indent, this));
        foreach(ch; children) {
            ch.dump(indent ~ "    ");
        }
    }
}