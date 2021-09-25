module ppl4.ast.stmt.decl.VarDecl;

import ppl4.all;

/**
 *  VarDecl
 *      [ Expression ]  initialiser
 */
final class VarDecl : Declaration {
private:
    bool _isParameter;
public:
    override bool isVariable() { return true; }
    override bool isParameter() { return _isParameter; }

    void setAsParameter() {
        this._isParameter = true;
    }

    //==============================================================================================
    this(Module mod, bool isPublic) {
        super(mod, isPublic);
    }

    //========================================================================================= Node
    override NodeId id() { return NodeId.VAR_DECL; }

    override Declaration parse(ParseState state) {
        return super.parse(state);
    }

    override void resolve(ResolveState state) {
        resolveChildren(state);

        // if(!type.isResolved()) {

        //     if(!hasExplicitType) {
        //         // Get the type from the Expression
        //         if(expr().type().isResolved()) {
        //             this.type = expr().type();
        //             setResolved();
        //         }
        //     } else {
        //         // resolve explicit type
        //         this.type = resolveType(this, type);
        //     }
        // } else {
        //     setResolved();
        // }

        // if(!isResolved) {
        //     state.unresolved(this);
        // }
        super.resolve(state);
    }

    override void check() {
        super.check();
    }

    override void generate(GenState state) {
        //trace("generating %s", name);
        if(isGlobal()) {
            if(hasChildren()) {
                // The declaration will set this variable to zero/null
                // TODO - where shall we put the initialisation if specified?
            }
        } else if(isMember()) {
            // struct/class member - handled elsewhere

        } else if(isParameter()) {
            auto func = ancestor!FnLiteral;
            auto params = getFunctionParams(func.llvmValue);
            auto index = this.index();
            expect(index != -1);
            expect(index < params.length);

            state.lhs = state.builder.alloca(type.getLLVMType(), name);
            _llvmValue = state.lhs;

            state.builder.store(params[index], state.lhs);

        } else {
            // local alloc
            state.lhs = state.builder.alloca(type.getLLVMType(), name);
            _llvmValue = state.lhs;

            if(hasChildren()) {
                super.generate(state);

                //state.rhs = gen.castType(left, b.leftType, cmpType);
                state.builder.store(state.rhs, _llvmValue);
            } else {
                // Initialise to zero/null
                auto zero = constAllZeroes(type.getLLVMType());
                state.builder.store(zero, _llvmValue);
            }
        }
    }

    //======================================================================================= Object
    override string toString() {
        return "VarDecl%s %s:%s %s".format(
                isPublic?"(pub)":"", name, type, isResolved() ? "✅" : "❌");
    }

    //==============================================================================================
    void generateDeclaration() {
        auto g = mod.llvmValue.addGlobal(type.getLLVMType(), name);
        g.setInitialiser(constAllZeroes(type.getLLVMType()));

        // if(v.isStatic && !v.access.isPrivate) {
        //     g.setLinkage(LLVMLinkage.LLVMLinkOnceODRLinkage);
        // } else {
            g.setLinkage(LLVMLinkage.LLVMInternalLinkage);
        //}
        _llvmValue = g;
    }
}