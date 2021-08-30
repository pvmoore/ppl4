module ppl4.ast.expr.Call;

import ppl4.all;

final class Call : Expression {
private:
public:
    string name;
    ITarget target;

    this(Module mod) {
        super(mod);
    }

    Expression[] args() {
        return children.as!(Expression[]);
    }
    Type[] argTypes() {
        return children.map!(it=>cast(Expression)it)
                       .map!(it=>it.type())
                       .array;
    }

    @Implements("Node")
    override NodeId id() { return NodeId.CALL; }

    @Implements("Expression")
    override Type type() {
        return target && target.isResolved() ? target.type().as!FunctionType.returnType : UNKNOWN_TYPE;
    }

    @Implements("Expression")
    override int precedence() { return precedenceOf(Operator.CALL); }

    /**
     * name '(' { Expression } ')'
     *
     */
    @Implements("Node")
    override Call parse(ParseState state) {
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

    /**
     *  1) Resolve target
     *  2) Cast all args to target params
     */
    @Implements("Node")
    override void resolve(ResolveState state) {
        if(!_isResolved) {
            resolveTarget();

            if(target && target.isResolved()) {
                castArgs();
                setResolved();
            } else {
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

        auto var = target.as!Variable;
        auto func = target.as!Function;

        LLVMValueRef[] argValues;
        foreach(expr; args()) {
            expr.generate(state);
            argValues ~= state.rhs;
        }

        if(target.isMember()) {
            if(var) {
                todo();
            } else {
                todo();
            }
        } else {
            if(var) {
                state.rhs = state.builder.load(target.getLlvmValue());
                state.rhs = state.builder.call(state.rhs, argValues, LLVMCallConv.LLVMFastCallConv);
            } else {
                expect(target.getLlvmValue() !is null, "Function llvmValue is null: %s".format(func));
                state.rhs = state.builder.call(target.getLlvmValue(), argValues, func.callingConvention());
            }
        }
    }

    override string toString() {
        string t = _isResolved ? target.type().toString() : "?";
        return "Call %s:%s".format(name, t);
    }
private:
    void resolveTarget() {
        if(target) return;

        auto types = argTypes();

        if(!areResolved(types)) return;

        trace("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        trace("Looking for %s(%s)", name, typeString(types));
        trace("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        ITarget[] targets;
        findTarget(name, targets, this);

        warn("TODO - filter based on parameters");

        if(targets.length==0) {
            // TODO - No targets
        } else if(targets.length == 1) {
            this.target = targets[0];
        } else {
            // TODO - Multiple possible targets
        }
    }
    /**
     * Ensure arguments are cast to the exact type of the target function
     */
    void castArgs() {
        FunctionType t = target.type().as!FunctionType;
        auto pTypes = t.params;
        auto aTypes = argTypes();
        expect(pTypes.length == aTypes.length);

        foreach(i; 0..aTypes.length) {
            auto arg = aTypes[i];
            auto param = pTypes[i];
            if(!arg.exactlyMatches(param)) {
                if(arg.canImplicitlyCastTo(param)) {
                    auto toType = getBestFit(arg, param);
                    children[i].wrapWith(Cast.make(mod, toType));
                } else {
                    // this shouldn't happen because we filter based on param types
                    expect(false);
                }
            }
        }
    }
}