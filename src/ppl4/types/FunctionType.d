module ppl4.types.FunctionType;

import ppl4.all;

/**
 *
 */
final class FunctionType : Type {
private:

public:
    Type[] params;
    Type returnType;

    this() {
        super(TypeKind.FUNCTION_PTR, 1);
    }

    Type parse(ParseState state) {
        todo();
        return this;
    }

    override bool exactlyMatches(Type other) {
        todo();
        return false;
    }

    override string toString() {
        return "FunctionType";
    }
}