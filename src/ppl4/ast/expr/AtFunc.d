module ppl4.ast.expr.AtFunc;

import ppl4.all;

/**
 *  AtFunc (name)
 *      { Expression }  // optional depending on function
 *
 * @isPublic(Type)
 * @isFunction(Type)
 * @isStruct(Type)
 * @isClass(Type)
 * @isEnum(Type)
 *
 */
final class AtFunc : Expression {
private:
    Type _type;
public:
    string name;

    this(Module mod) {
        super(mod);
        this._type = UNKNOWN_TYPE;
    }

    @Implements("Node")
    override NodeId id() { return NodeId.AT_FUNC; }

    @Implements("Expression")
    override Type type() { return _type; }

    @Implements("Expression")
    override int precedence() { return precedenceOf(Operator.CALL); }

    /**
     * '@' name '(' { Expression } ')'
     *
     */
    @Implements("Node")
    override AtFunc parse(ParseState state) {
        // name
        this.name = state.text(); state.next();

        // (
        state.skip(TokenKind.LBRACKET);

        while(!state.isKind(TokenKind.RBRACKET)) {

            parseExpression(state, this);

            state.expectOneOf(TokenKind.COMMA, TokenKind.RBRACKET);
            state.trySkip(TokenKind.COMMA);
        }

        // )
        state.skip(TokenKind.RBRACKET);
        return this;
    }

    @Implements("Node")
    override void resolve(ResolveState state) {
        if(!_type.isResolved()) {
            setResolved();

            // Single Expression:
            // @shl
            // @shr
            // @ushl
            // @ushr
            // @rol
            // @ror
            // @ugt
            // @ugte
            // @ult
            // @ulte
            if(numChildren() == 0) {
                singleExpressionExpected(this);
            } else if(numChildren() > 1) {
                singleExpressionExpected(children[1]);
            } else {
                if(first().isResolved) {
                    this._type = first().as!Expression.type();
                    setResolved();
                }
            }

            if(!_type.isResolved()) {
                state.unresolved(this);
            }
        }

        super.resolve(state);
    }

    @Implements("Node")
    override void check() {

    }

    @Implements("Node")
    override void generate(GenState state) {

    }

    override string toString() {
        return "AtFunc %s:%s".format(name, _type);
    }
}