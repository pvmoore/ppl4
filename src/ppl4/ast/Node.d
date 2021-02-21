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

    abstract NodeId id();

    final bool hasParent() { return parent !is null; }
    final bool hasChildren() { return numChildren() > 0; }
    final int numChildren() { return children.length.as!int; }
    final Statement first() { return numChildren() > 0 ? children[0] : null; }
    final Statement last() { return numChildren() > 0 ? children[$-1] : null; }

    final void add(Statement n) {
        expect(!n.parent);
        children ~= n;
        n.parent = this.as!Statement;
    }

    void dump(string indent = "") {
        trace("%s%s".format(indent, this));
        foreach(ch; children) {
            ch.dump(indent ~ "    ");
        }
    }
}