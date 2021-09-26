module ppl4.ast.expr.lit.FnLiteral;

import ppl4.all;

/**
 * FnLiteral
 *      { VarDecl }         // parameters ( * numParams)
 *      [ TypeExpression ]  // return type
 *      { Statement }       // Statements
 */
final class FnLiteral : Literal {
private:
    //Type _type;                 // Will be a FunctionType when resolved
    Type _returnType;           // This can be known before _type is known
public:
    int numParams;
    LLVMValueRef llvmValue;

    bool isLambda() { return !parent.isA!FnDecl || !(parent.as!Declaration.isMember() || parent.as!Declaration.isGlobal()); }
    bool isProgramEntry() { return !isLambda() && parent.as!FnDecl.isProgramEntry; }

    bool hasName() { return !isLambda(); }
    string name() { pplAssert(!isLambda()); return parent.as!FnDecl.name; }

    VarDecl[] params() { return children[0..numParams].map!(it=>cast(VarDecl)it).array; }
    Type[] paramTypes() { return params().map!(it=>it.type).array; }
    Type returnType() { return _returnType; }

    string uniqueName() {
        expect(isResolved);

        if(numParams==0) return name;
        return "%s|%s".format(name, typeString(paramTypes));
    }
    LLVMCallConv callingConvention() {
        if(isProgramEntry()) return LLVMCallConv.LLVMCCallConv;
        return LLVMCallConv.LLVMFastCallConv;
    }

    //==============================================================================================
    this(Module mod) {
        super(mod);
        this._returnType = UNKNOWN_TYPE;
    }

    // ======================================================================================== Node
    override NodeId id() { return NodeId.FN_LITERAL; }

    /**
     * "fn" [ PARAMS ] [ RETURNTYPE ] [ BODY ]
     *
     *  PARAMS      ::= "(" { Variable } ")"
     *  RETURNTYPE  ::= ":" Type|TypeExpression
     *  BODY        ::= "{" { Statement } "}"
     */
    override FnLiteral parse(ParseState state) {

        // "fn"
        state.skip("fn");

        // "("  PARAMS
        if(state.isKind(TokenKind.LBRACKET)) {
            // "("
            state.next();

            while(state.isNotOneOf(TokenKind.RBRACKET, TokenKind.RT_ARROW)) {

                if(state.text=="void" && (state.peek(1).kind.isOneOf(TokenKind.RT_ARROW, TokenKind.RBRACKET))) {
                    state.next();
                } else {
                    auto param = cast(VarDecl)mod.nodeFactory.make!VarDecl(false, state.peek()).parse(state);
                    param.setAsParameter();

                    add(param);

                    numParams++;
                }

                state.expectOneOf(TokenKind.RT_ARROW, TokenKind.COMMA, TokenKind.RBRACKET);
                state.trySkip(TokenKind.COMMA);
            }

            if(state.isKind(TokenKind.RT_ARROW)) {
                state.next();

                if(!state.isKind(TokenKind.RBRACKET)) {
                    this._returnType = parseType(state, this);
                }
            }

            // ")"
            state.skip(TokenKind.RBRACKET);
        }

        // "{"  BODY
        if(state.isKind(TokenKind.LCURLY)) with(TokenKind) {
            state.next();

            while(!state.isKind(RCURLY)) {

                // Call Node.parse
                super.parse(state);
            }

            // "}"
            state.skip(RCURLY);
        } else {
            syntaxError(state, "No function body found");
        }

        return this;
    }

    override void resolve(ResolveState state) {
        if(!isResolved) {
            resolveReturnType();
            resolveFunctionType();

            if(_returnType.isResolved() && _type.isResolved()) {

                setResolved();

                // Add an implicit ret void at the end
                if(_returnType.kind == TypeKind.VOID && !_returnType.isPtr()) {
                    if(!hasChildren() || !last().isA!Return) {
                        add(mod.nodeFactory.make!Return(MODULE_TOKEN));
                    }
                }
            } else {
                setUnresolved();
            }
        }
        super.resolve(state);
    }

    override void check() {
        super.check();

        if(hasName() && parent.as!FnDecl.isProgramEntry && !returnType.exactlyMatches(INT)) {
            entryFuncReturnTypeShouldBeInt(this);
        }
    }

    override void generate(GenState state) {

        //if(isExtern()) return;

        auto entry = llvmValue.appendBasicBlock("entry");
        state.moveToBlock(entry);

        super.generate(state);
    }

    // ======================================================================================= Object
    override string toString() {
        string t;
        if(isResolved) {
            t = _type.toString();
        } else {
            t = "(%s params) returns %s".format(
                numParams, _returnType.isResolved() ? _returnType.toString() : "?");
        }

        return "FnLiteral %s %s".format(t, isResolved() ? "✅" : "❌");
    }

    // =============================================================================================
    void generateDeclaration() {
        doGenerateDecl();
    }
private:
    /**
     * Once return type and param types are known we can set our FunctionType
     */
    void resolveFunctionType() {
        if(_type.isResolved()) return;
        if(!_returnType.isResolved()) return;
        if(!areResolved(paramTypes())) return;

        this._type = new FunctionType(paramTypes(), _returnType);
    }
    /**
     * Collect all return Expressions and try to determine a returnType
     */
    void resolveReturnType() {
        if(_returnType.isResolved()) return;

        Return[] returns = collect!Return();

        if(returns.length == 0) {
            this._returnType = VOID;
            return;
        }

        Expression[] exprs = returns.filter!(it=>it.hasChildren())
                                    .map!(it=>it.first())
                                    .map!(it=>cast(Expression)it)
                                    .array;

        if(exprs.length == 0) {
            this._returnType = VOID;
            return;
        }

        if(exprs.length != returns.length) {
            returnTypeMismatch(this);
            return;
        }

        // Attempt to find the largest return Type.
        // All types must be resolved before we do this
        Type[] types = exprs.map!(it=>it.type()).array;

        if(!types.areResolved()) return;

        this._returnType = getBestFit(types);

        if(!returnType.isResolved()) {
            returnTypeMismatch(this);
        }
    }
    void doGenerateDecl() {
        this.llvmValue = mod.llvmValue.addFunction(
            uniqueName(),
            _returnType.getLLVMType(),
            paramTypes().map!(it=>it.getLLVMType()).array,
            callingConvention()
        );

        // inline | noinline
        bool isInline   = false;
        bool isNoInline = false;

        if(isInline) {
            addFunctionAttribute(llvmValue, LLVMAttribute.AlwaysInline);
        } else if(isNoInline) {
            addFunctionAttribute(llvmValue, LLVMAttribute.NoInline);
        }

        // throws?
        addFunctionAttribute(llvmValue, LLVMAttribute.NoUnwind);

        // linkage
        auto externallyVisible = true || isProgramEntry();

        if(externallyVisible) {
            llvmValue.setLinkage(LLVMLinkage.LLVMExternalLinkage);
        } else /*if(numExternalRefs==0 && )*/ {
            llvmValue.setLinkage(LLVMLinkage.LLVMInternalLinkage);
        }
    }
}