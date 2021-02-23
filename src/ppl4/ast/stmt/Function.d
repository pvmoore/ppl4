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
    bool isProgramEntry;
    LLVMValueRef llvmValue;

    this(Module mod, bool isPublic) {
        super(mod);
        this.isPublic = isPublic;
    }

    string uniqueName() {
        expect(isResolved);
        if(numParams==0) return name;
        string s;
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

    @Implements("Node")
    override NodeId id() { return NodeId.FUNCTION; }

    /**
     * name "=" "fn" "(" { Variable } ")" [ ":" Type ] "{" { Statement } "}"
     */
    @Implements("Statement")
    override Function parse(ParseState state) {

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

                add(state.make!Variable(false).parse(state));

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

            this.returnType = parseType(state);
        } else {
            this.returnType = UNKNOWN_TYPE;
        }

        // {
        if(state.isKind(TokenKind.LCURLY)) {
            state.next();

            while(!state.isKind(TokenKind.RCURLY)) {
                // Variable | Return | Import | Expression

                switch(state.text()) {
                    case "return":
                    add(state.make!Return().parse(state));
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
    override void resolve(ResolveState state) {
        if(!isResolved) {
            resolveIsProgramEntry();
            resolveReturnType();

            if(returnType.isResolved()) {
                this.isResolved = true;

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

    @Implements("Statement")
    override void check() {
        if(isProgramEntry && !returnType.exactlyMatches(INT)) {
            entryFuncReturnTypeShouldBeInt(this);
        }
        super.check();
    }

    @Implements("Statement")
    override void generate(GenState state) {
        if(isExtern) return;

        auto entry = llvmValue.appendBasicBlock("entry");
        state.moveToBlock(entry);

        super.generate(state);
    }

    void generateDecl() {
        doGenerateDecl();
    }

    override string toString() {
        string p = numParams > 0 ? " (%s params)".format(numParams) : "";
        string rt = returnType.isResolved() ? " returns %s".format(returnType) : "";
        string ex = isExtern ? " extern" : "";
        return "Function%s '%s'%s%s%s".format(isPublic ? "(+)":"", name, p, ex, rt);
    }
private:
    void resolveIsProgramEntry() {
        if(name == mod.config.programEntryName()) {
            isProgramEntry = true;
        }
    }
    /**
     * Collect all return Expressions and try to determine a returnType
     */
    void resolveReturnType() {
        Return[] returns = collect!Return();

        if(returns.length == 0) {
            this.returnType = VOID;
            return;
        }

        Expression[] exprs = returns.filter!(it=>it.hasChildren())
                                    .map!(it=>it.first())
                                    .map!(it=>cast(Expression)it)
                                    .array;

        if(exprs.length == 0) {
            this.returnType = VOID;
            return;
        }

        if(exprs.length != returns.length) {
            returnTypeMismatch(this);
            return;
        }

        // Get all types are attempt to find the largest Type.
        // All types must be resolved before we do this
        Type[] types = exprs.map!(it=>it.type()).array;
        if(!types.areResolved()) return;

        this.returnType = getBestFit(types);
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
        //info("f = %s", llvmValue.toString());

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

        //// linkage
        //if(!f.isExport && f.access==Access.PRIVATE) {

        if(isExtern || isProgramEntry) {
            llvmValue.setLinkage(LLVMLinkage.LLVMExternalLinkage);
        } else /*if(numExternalRefs==0 && )*/ {
            llvmValue.setLinkage(LLVMLinkage.LLVMInternalLinkage);
        }
    }
}