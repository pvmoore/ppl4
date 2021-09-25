module ppl4.ast.stmt.decl.FnDecl;

import ppl4.all;

/**
 * FnDecl
 *      { VarDecl }         // parameters ( * numParams)
 *      [ TypeExpression ]  // return type
 *      { Statement }       // Statements
 */
final class FnDecl : Declaration {
private:

public:
    bool isProgramEntry;

    override bool isFunction() { return true; }

    LLVMCallConv callingConvention() { return expr().as!FnLiteral.callingConvention(); }
    override LLVMValueRef getLlvmValue() { return expr().as!FnLiteral.llvmValue; }

    //==============================================================================================
    this(Module mod, bool isPublic) {
        super(mod, isPublic);
    }

    //========================================================================================= Node
    override NodeId id() { return NodeId.FN_DECL; }

    /**
     * "fn" "(" PARAMS [ "->" RETURN_TYPE ] )" [ BODY ]
     */
    override Declaration parse(ParseState state) {
        return super.parse(state);
    }

    override void resolve(ResolveState state) {
        // Resolve literal
        resolveChildren(state);

        resolveIsProgramEntry();

        super.resolve(state);
    }

    override void check() {
        super.check();
    }

    override void generate(GenState state) {
        super.generate(state);
    }

    //======================================================================================= Object
    override string toString() {
        string e = isPublic ? "(pub)" : "";
        return "FnDecl%s %s:%s %s".format(e, name, type, isResolved() ? "✅" : "❌");
    }
private:
    void resolveIsProgramEntry() {
        if(name == mod.config.programEntryName()) {
            isProgramEntry = true;
            isPublic = true;
        }
    }
    // void resolveTypeFromFnLiteral() {
    //     auto e = expr();
    //     if(e.isA!FnLiteral && e.isResolved()) {
    //         this.type = e.type();
    //     }
    // }
}