module ppl4.ast.expr.Expression;

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

    switch(state.kind()) with(TokenKind) {
        case IDENTIFIER:
            switch(state.text()) {
                case "true":
                case "false":
                    return state.make!Number().parse(state);
                case "null":
                    return state.make!Null().parse(state);
                case "assert":
                    return state.make!Assert().parse(state);

                default:
                    // Cast or StructValue?
                    if(isType(state)) {
                        if(isBuiltinType(state)) {
                            return state.make!Cast().parse(state);
                        } else {
                            // Call constructor
                            todo();
                        }
                    }
                    // Call
                    if(state.peek(1).kind == LBRACKET) {
                        return state.make!Call().parse(state);
                    }
                    // Identifier
                    return state.make!Identifier().parse(state);
            }
        case NUMBER:
            return state.make!Number().parse(state);
        case LBRACKET:
            return state.make!Parens().parse(state);
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
    while(true) {
        if(state.isNewLine()) return;

        auto text = state.text();

        if(text.isOneOf("and", "or", "shl", "shr", "ushr", "is")) {
            parent = attachAndRead2(state, parent, state.make!Binary().parse(state));
            continue;
        }

        switch(state.kind()) with(TokenKind) {
            case NONE:
            case RCURLY:
            case RBRACKET:
            case RSQUARE:
            case COMMA:
            case COLON:
                return;
            case PLUS:
            case MINUS:
            case ASTERISK:
            case FSLASH:
            case PERCENT:
            case COLON_EQUALS:
                parent = attachAndRead2(state, parent, state.make!Binary().parse(state));
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