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
        super(TypeKind.FUNCTION, 1);
    }
    this(Type[] params, Type returnType) {
        this();
        this.params = params;
        this.returnType = returnType;
    }

    /**
     *  "fn" "(" { PARAMS [ "->" RETURN_TYPE ]} ")"
     *
     *  PARAMS      ::= [ name ":" ] Type
     *  RETURN_TYPE ::= Type
     */
    Type parse(ParseState state, Node parent) {
        // fn
        state.skip("fn");

        // (
        state.skip(TokenKind.LBRACKET);

        // { PARAMS }

        while(!state.isOneOf(TokenKind.RBRACKET, TokenKind.RT_ARROW)) {

            bool isNameType = state.peek(1).kind == TokenKind.COLON;

            if(isNameType) {
                state.next(2);
            }

            if(state.text=="void" && state.peek(1).kind.isOneOf(TokenKind.RT_ARROW, TokenKind.RBRACKET)) {
                state.next();
            } else {
                params ~= parseType(state, parent);
            }

            state.expectOneOf(TokenKind.COMMA, TokenKind.RBRACKET, TokenKind.RT_ARROW);
            state.trySkip(TokenKind.COMMA);
        }

        // ->
        if(state.isKind(TokenKind.RT_ARROW)) {
            state.next();

            if(!state.isKind(TokenKind.RBRACKET)) {
                this.returnType = parseType(state, parent);
            }
        }

        // )
        state.skip(TokenKind.RBRACKET);

        return this;
    }

    override bool exactlyMatches(Type other) {
        if(!.canImplicitlyCastTo(this, other)) return false;

        return false;
    }

    override bool canImplicitlyCastTo(Type other) {
        return false;
    }

    override string toString() {
        auto p = params.length == 0 ? "void" : typeString(params);
        return "fn(%s->%s)%s".format(p, returnType.toString(), repeat("*", ptrDepth-1));
    }
}