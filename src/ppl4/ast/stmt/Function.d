module ppl4.ast.stmt.Function;

import ppl4.all;

/**
 *  Function
 *      { Variable }        // numParams parameters
 *      { Statement }       // body
 */
final class Function : Statement {
public:
    string name;
    int numParams;
    Type returnType;
    bool isPublic;
    bool isExtern;

    this(Module mod, bool isPublic) {
        super(mod);
        this.isPublic = isPublic;
    }

    @Implements("Node")
    override NodeId id() { return NodeId.FUNCTION; }

    /**
     * name "=" "fn" "(" { Variable } ")" [ ":" Type ] "{" { Statement } "}"
     */
    @Implements("Statement")
    override Statement parse(ParseState state) {

        // name
        this.name = state.text(); state.next();

        //info("%s", name);

        // =
        state.skip(TokenKind.EQUALS);

        if("extern" == state.text) {
            state.next();
            this.isExtern = true;
        }

        // "fn"
        state.skip("fn");

        // ( parameters )
        if(state.isKind(TokenKind.LBRACKET)) {
            state.next();

            while(state.kind()!=TokenKind.RBRACKET) {

                add(new Variable(mod, false).parse(state));

                numParams++;

                state.expectOneOf(TokenKind.RBRACKET, TokenKind.COMMA);
                state.trySkip(TokenKind.COMMA);
            }

            state.skip(TokenKind.RBRACKET);
        } else {
            if(!isExtern) {
                // error
            }
        }

        // optional return Type
        if(state.kind() == TokenKind.COLON) {
            state.next();

            this.returnType = Type.parseType(state);
        } else {
            this.returnType = UNKNOWN;
        }

        // {
        if(state.isKind(TokenKind.LCURLY)) {
            state.next();

            while(!state.isKind(TokenKind.RCURLY)) {
                // Variable | Return | Import | Expression

                switch(state.text()) {
                    case "return":
                    add(new Return(mod).parse(state));
                        break;
                    default:
                        todo();
                        break;
                }
            }

            state.skip(TokenKind.RCURLY);
        }

        return this;
    }

    @Implements("Statement")
    override bool resolve() {
        todo();
        return false;
    }

    @Implements("Statement")
    override bool check() {
        todo();
        return false;
    }

    @Implements("Statement")
    override bool generate() {
        todo();
        return false;
    }

    override string toString() {
        string p = numParams > 0 ? " (%s params)".format(numParams) : "";
        string rt = returnType.isResolved() ? " returns %s".format(returnType) : "";
        string ex = isExtern ? " extern" : "";
        return "Function%s '%s'%s%s%s".format(isPublic ? "(+)":"", name, p, ex, rt);
    }
}