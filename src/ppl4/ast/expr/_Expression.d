module ppl4.ast.expr._Expression;

import ppl4.all;

abstract class Expression : Statement {
public:
    abstract Type type();
    abstract int precedence();

    this(Module mod) {
        super(mod);
    }
}

//==================================================================================================

void parseExpression(ParseState state, Node parent) {
    //trace("parseExpression\n%s", parent.dumped());

    auto expr = lhs(state, parent);
    parent.add(expr);
    rhs(state, parent);
    //trace("parent = %s", parent.dumped());
    //auto f = parent.first().as!Expression;
}

private:
//==================================================================================================
// L H S
//==================================================================================================
Expression lhs(ParseState state, Node parent) {

    auto mod = state.mod;
    auto factory = mod.nodeFactory;

    switch(state.kind()) with(TokenKind) {
        case IDENTIFIER:

            if(isBuiltinType(state)) {
                return factory.make!TypeExpression(state.peek()).parse(state);
            }

            switch(state.text()) {
                case "true":
                case "false":
                    return factory.make!Number(state.peek()).parse(state);
                case "null":
                    return factory.make!Null(state.peek()).parse(state);
                case "assert":
                    return factory.make!Assert(state.peek()).parse(state);
                case "fn":
                case "extern":
                    return factory.make!FnLiteral(state.peek()).parse(state);
                case "struct":
                case "class":
                    return factory.make!StructLiteral(state.peek()).parse(state);

                default:
                    // Cast or StructValue?
                    if(isType(state)) {
                        if(isBuiltinType(state)) {
                            return factory.make!Cast(state.peek()).parse(state);
                        } else {
                            // Call constructor
                            todo();
                        }
                    }
                    // Call
                    if(state.peek(1).kind == LBRACKET) {
                        return factory.make!Call(state.peek()).parse(state);
                    }
                    // Identifier
                    return factory.make!Identifier(state.peek()).parse(state);
            }
        case NUMBER:
            return factory.make!Number(state.peek()).parse(state);
        case LBRACKET:
            return factory.make!Parens(state.peek()).parse(state);
        default:
            break;
    }
    todo("LHS %s".format(state.peek()));
    assert(false);
}

//==================================================================================================
// R H S
//==================================================================================================
void rhs(ParseState state, Node parent) {
    auto mod = state.mod;
    auto factory = mod.nodeFactory;

    while(true) {
        if(state.isNewLine()) return;

        auto text = state.text();

        if(text.isOneOf("and", "or", "shl", "shr", "ushr", "is")) {
            parent = attachAndRead2(state, parent, factory.make!Binary(state.peek()).parse(state));
            continue;
        }

        switch(state.kind()) with(TokenKind) {
            case NONE:
            case RCURLY:
            case RBRACKET:
            case RSQUARE:
            case COMMA:
            case COLON:
            case EQUALS:
                return;
            case PLUS:
            case MINUS:
            case ASTERISK:
            case FSLASH:
            case PERCENT:
            case COLON_EQUALS:
                parent = attachAndRead2(state, parent, factory.make!Binary(state.peek()).parse(state));
                break;
            case IDENTIFIER:
                todo();
                break;
            default:
                todo("RHS %s".format(state.peek()));
                break;
        }
    }
    assert(false);
}

// Expression attach(ParseState state, Statement prev, Expression newexpr) {
//     trace("attach");
//     while(true) {
//         auto parent = prev.as!Expression;
//         if(parent && newexpr.precedence() >= parent.precedence()) {
//             prev = prev.parent;
//         } else break;
//     }

// 	newexpr.add(prev.remove());
// 	prev.add(newexpr);
// 	return newexpr;
// }
// Expression attachAndRead(ParseState state, Statement prev, Expression newexpr) {
// 	trace("attachAndRead newexpr=%s prev=%s", newexpr.id(), prev.id());

//     while(true) {
//         auto parent = prev.as!Expression;
//         trace("parent = %s", parent);
//         if(parent && newexpr.precedence() >= parent.precedence()) {
//             prev = prev.parent;
//         } else break;
//     }
//     trace("prev = %s", prev);

//     //auto a = prev.remove();
//     //trace("a = %s", a.id());

//     newexpr.add(prev.remove());
// 	newexpr.add(lhs(state, newexpr));
// 	prev.add(newexpr);
// 	return newexpr;
// }
Expression attachAndRead2(ParseState state, Node parent, Expression newExpr, bool andRead = true) {

    Node prev = parent;

    ///
    /// Swap expressions according to operator precedence
    ///
    const doPrecedenceCheck = prev.isA!Expression;
    if(doPrecedenceCheck) {

        /// Adjust to account for operator precedence
        Expression prevExpr = prev.as!Expression;
        while(prevExpr.parent && newExpr.precedence() >= prevExpr.precedence()) {

            if(!prevExpr.parent.isA!Expression) {
                prev = prevExpr.parent;
                break;
            }

            prevExpr = prevExpr.parent.as!Expression;
            prev     = prevExpr;
        }
    }

    newExpr.add(prev.last());

    if(andRead) {
        newExpr.add(lhs(state, newExpr));
    }

    prev.add(newExpr);

    return newExpr;
}