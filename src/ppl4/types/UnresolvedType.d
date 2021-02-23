module ppl4.types.UnresolvedType;

import ppl4.all;

/**
 *  This represents a struct or class that we need to resolve.
 */
final class UnresolvedType : Type {
public:
    string name;

    this() {
        super(TypeKind.UNKNOWN, 0);
    }
    override bool isResolved() { return false; }

    Type parse(ParseState state) {
        this.name = state.text();
        state.next();

        return this;
    }

    override bool exactlyMatches(Type other) {
        return false;
    }
    override bool canImplicitlyCastTo(Type other) {
        return false;
    }

    override string toString() {
        return super.toString() ~ "UnresolvedType(%s)".format(name);
    }
}