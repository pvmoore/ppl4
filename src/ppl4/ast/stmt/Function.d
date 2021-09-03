module ppl4.ast.stmt.Function;

import ppl4.all;

/**
 *  Function
 *      { Variable }        // numParams parameters
 *      { Statement }       // body
 */
final class Function : Statement, ITarget {
private:
    Type _type;         // Will be a FunctionType when resolved
    Type _returnType;   // This can be known before _type is known
public:
    string name;
    int numParams;
    bool isPublic;
    bool isExtern;
    bool isProgramEntry;
    LLVMValueRef llvmValue;

    this(Module mod, bool isPublic) {
        super(mod);
        this.isPublic = isPublic;
        this._type = UNKNOWN_TYPE;
        this._returnType = UNKNOWN_TYPE;
    }

    static auto make(Module mod, string name, FunctionType type) {
        auto f = new Function(mod, false);
        f.name = name;
        f._type = type;
        return f;
    }

    string uniqueName() {
        expect(isResolved);
        if(numParams==0) return name;
        return "%s|%s".format(name, typeString(paramTypes));
    }
    LLVMCallConv callingConvention() {
        if(isExtern) return LLVMCallConv.LLVMCCallConv;
        if(isProgramEntry) return LLVMCallConv.LLVMCCallConv;
        return LLVMCallConv.LLVMFastCallConv;
    }

    Variable[] params() {
        return children[0..numParams].map!(it=>cast(Variable)it).array;
    }
    Type[] paramTypes() {
        return params().map!(it=>it.type).array;
    }
    Type returnType() {
        return _returnType;
    }

    void generateDeclaration() {
        doGenerateDecl();
    }

    @Implements("ITarget")
    override bool isMember() {
        return parent.isA!Struct;
    }

    @Implements("ITarget")
    Type type() {
        return _type;
    }
    @Implements("ITarget")
    override bool isResolved() {
        return super.isResolved();
    }
    @Implements("ITarget")
    override LLVMValueRef getLlvmValue() {
        return llvmValue;
    }

    @Implements("Node")
    override NodeId id() { return NodeId.FUNCTION; }

    @Implements("Node")
    override void findTarget(string name, ref ITarget[] targets, Expression src) {
        if(this.name == name) {
            targets ~= this;
        }
        super.findTarget(name, targets, src);
    }

    /**
     * name "=" "fn" "(" { Variable } ")" [ ":" Type ] "{" { Statement } "}"
     */
    @Implements("Node")
    override Function parse(ParseState state) {

        // name
        this.name = state.text(); state.next();

        //info("%s", name);

        // =
        state.skip(TokenKind.EQUALS);

        if("extern" == state.text) {
            state.next();
            this.isExtern = true;
            this.isPublic = true;
        }

        // "fn"
        state.skip("fn");

        // (    (optional parameters)
        if(state.isKind(TokenKind.LBRACKET)) {

            // (
            state.skip(TokenKind.LBRACKET);

            // parameters
            while(state.kind()!=TokenKind.LCURLY &&
                state.kind()!=TokenKind.COLON &&
                state.kind()!=TokenKind.RBRACKET)
            {
                auto param = state.make!Variable(false).parse(state);
                param.setAsParameter();

                add(param);

                numParams++;

                state.expectOneOf(TokenKind.LCURLY, TokenKind.COMMA, TokenKind.COLON, TokenKind.RBRACKET);
                state.trySkip(TokenKind.COMMA);
            }

            // )
            state.skip(TokenKind.RBRACKET);
        }

        // :   (optional return Type)
        if(state.kind() == TokenKind.COLON) {
            state.next();

            this._returnType = parseType(state);
        }

        // {
        if(state.isKind(TokenKind.LCURLY)) with(TokenKind) {
            state.next();

            while(!state.isKind(RCURLY)) {

                // Call Node.parse
                super.parse(state);
            }

            state.skip(RCURLY);
        } else {
            if(!isExtern) {
                // error
            }
        }

        return this;
    }

    @Implements("Node")
    override void resolve(ResolveState state) {
        if(!_isResolved) {
            resolveIsProgramEntry();
            resolveReturnType();
            resolveFunctionType();

            if(_returnType.isResolved() && _type.isResolved()) {
                setResolved();

                // Add an implicit ret void at the end
                if(returnType.kind == TypeKind.VOID && !returnType.isPtr()) {
                    if(!hasChildren() || !last().isA!Return) {
                        add(state.make!Return());
                    }
                }
            } else {
                state.unresolved(this);
            }
        }
        super.resolve(state);
    }

    @Implements("Node")
    override void check() {
        if(isProgramEntry && !returnType.exactlyMatches(INT)) {
            entryFuncReturnTypeShouldBeInt(this);
        }
        super.check();
    }

    @Implements("Node")
    override void generate(GenState state) {
        if(isExtern) return;

        //trace("  generate %s", toString());

        auto entry = llvmValue.appendBasicBlock("entry");
        state.moveToBlock(entry);

        super.generate(state);
    }

    override string toString() {
        string t;
        if(isResolved()) {
            t = _type.toString();
        } else {
            t = "(%s params) returns %s".format(
                numParams, returnType.isResolved() ? returnType.toString() : "?");
        }

        string brk = isExtern && isPublic ? "(pub extern)"
                                          : isExtern ? "(extern)"
                                          : isPublic ? "(pub)"
                                          : "";
        return "Function%s '%s' %s".format(brk, name, t);
    }
private:
    void resolveIsProgramEntry() {
        if(name == mod.config.programEntryName()) {
            isProgramEntry = true;
        }
    }
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
            returnType.getLLVMType(),
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
        auto externallyVisible = true || isExtern || isProgramEntry;

        if(externallyVisible) {
            llvmValue.setLinkage(LLVMLinkage.LLVMExternalLinkage);
        } else /*if(numExternalRefs==0 && )*/ {
            llvmValue.setLinkage(LLVMLinkage.LLVMInternalLinkage);
        }
    }
}