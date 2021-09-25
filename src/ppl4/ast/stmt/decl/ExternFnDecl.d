module ppl4.ast.stmt.decl.ExternFnDecl;

import ppl4.all;

/**
 *  ExternFnDecl
 */
final class ExternFnDecl : Declaration {
private:

public:

    override bool isFunction() { return true; }
    LLVMCallConv callingConvention() { return LLVMCallConv.LLVMCCallConv; }
    override LLVMValueRef getLlvmValue() { return _llvmValue; }

    //==============================================================================================
    this(Module mod, bool isPublic) {
        super(mod, isPublic);
    }

    //========================================================================================= Node
    override NodeId id() { return NodeId.EXTERN_FN_DECL; }

    /**
     * name "=" "extern" "fn" "(" PARAMS "->" Type )"
     *
     * PARAM  ::= [ name ":" ] Type
     * PARAMS ::= { PARAM [ "," PARAM ] }
     */
    override Declaration parse(ParseState state) {

        // name
        this.name = state.text(); state.next();

        // "="
        state.skip(TokenKind.EQUALS);

        // "extern"
        state.skip("extern");

        //
        this.type = parseType(state, this);

        return this;
    }

    override void resolve(ResolveState state) {
        super.resolve(state);
    }

    override void check() {
        super.check();
    }

    override void generate(GenState state) {
        super.generate(state);
    }

    void generateDeclaration() {
        //trace(GEN, "generating extern %s", name);
        auto ft = type.as!FunctionType;
        pplAssert(ft !is null);

        _llvmValue = mod.llvmValue.addFunction(
            name,
            ft.returnType.getLLVMType(),
            ft.params.map!(it=>it.getLLVMType()).array,
            LLVMCallConv.LLVMCCallConv
        );

        addFunctionAttribute(_llvmValue, LLVMAttribute.NoInline);

        _llvmValue.setLinkage(LLVMLinkage.LLVMExternalLinkage);
    }

    //======================================================================================= Object
    override string toString() {
        string e = isPublic ? "(pub)" : "";
        return "ExternFnDecl%s %s:%s %s".format(e, name, type, isResolved() ? "✅" : "❌");
    }
}