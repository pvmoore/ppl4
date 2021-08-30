module ppl4.ast.stmt.Variable;

import ppl4.all;

/**
 *  Variable
 *      [ Expression ]
 */
final class Variable : Statement, ITarget {
private:
    Type _type;
    bool _explicitType;
    bool _isParameter;
public:
    string name;
    bool isPublic;
    LLVMValueRef llvmValue;

    this(Module mod, bool isPublic) {
        super(mod);
        this.isPublic = isPublic;
    }
    void setAsParameter() {
        this._isParameter = true;
    }

    Expression expr() {
        return first().as!Expression;
    }
    bool isGlobal() {
        return parent.isA!Module;
    }
    bool isParameter() {
        return _isParameter;
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
        return _isResolved;
    }
    @Implements("ITarget")
    override LLVMValueRef getLlvmValue() {
        return llvmValue;
    }

    @Implements("Node")
    override NodeId id() { return NodeId.VARIABLE; }

    @Implements("Statement")
    override void findTarget(string name, ref ITarget[] targets, Expression src) {
        if(this.name == name) {
            targets ~= this;
        }
        super.findTarget(name, targets, src);
    }

    /**
     * name ":" Type
     * name ":" Type "=" Expression
     * name "=" Expression
     */
    @Implements("Node")
    override Variable parse(ParseState state) {

        // + (public)
        if(state.isKind(TokenKind.PLUS)) {
            state.next();
            this.isPublic = true;
        }

        // name
        this.name = state.text(); state.next();

        // : Type
        if(state.kind() == TokenKind.COLON) {
            state.next();

            this._explicitType = true;
            this._type = parseType(state);

        } else {
            this._type = UNKNOWN_TYPE;
        }

        // =
        if(state.isKind(TokenKind.EQUALS)) {
            state.next();

            parseExpression(state, this);
        } else if(!_explicitType) {
            syntaxError(state, "Variable is missing type information");
        }

        return this;
    }

    @Implements("Node")
    override void resolve(ResolveState state) {
        if(!type.isResolved()) {

            if(!_explicitType) {
                // Get the type from the Expression
                if(expr().type().isResolved()) {
                    _type = expr().type();
                    setResolved();
                }
            }
        } else {
            setResolved();
        }

        super.resolve(state);

        if(!isResolved) {
            state.unresolved(this);
        }
    }

    @Implements("Node")
    override void check() {
        // 1) name must not be duplicate or shadow
        // 2) ...
        super.check();
    }

    @Implements("Node")
    override void generate(GenState state) {

        if(isGlobal()) {
            if(hasChildren()) {
                // The declaration will set this variable to zero/null
                // TODO - where shall we put the initialisation if specified?
            }
        } else if(isMember()) {
            // struct/class member
        } else if(isParameter()) {
            auto func = ancestor!Function;
            auto params = getFunctionParams(func.llvmValue);
            auto index = this.index();
            expect(index != -1);
            expect(index < params.length);

            state.lhs = state.builder.alloca(_type.getLLVMType(), name);
            llvmValue = state.lhs;

            state.builder.store(params[index], state.lhs);

        } else {
            // local alloc
            state.lhs = state.builder.alloca(_type.getLLVMType(), name);
            llvmValue = state.lhs;

            if(hasChildren()) {
                super.generate(state);

                //state.rhs = gen.castType(left, b.leftType, cmpType);
                state.builder.store(state.rhs, llvmValue);
            } else {
                // Initialise to zero/null
                auto zero = constAllZeroes(type.getLLVMType());
                state.builder.store(zero, llvmValue);
            }
        }
    }

    void generateDeclaration() {
        auto g = mod.llvmValue.addGlobal(type.getLLVMType(), name);
        g.setInitialiser(constAllZeroes(type.getLLVMType()));

        // if(v.isStatic && !v.access.isPrivate) {
        //     g.setLinkage(LLVMLinkage.LLVMLinkOnceODRLinkage);
        // } else {
            g.setLinkage(LLVMLinkage.LLVMInternalLinkage);
        //}
        llvmValue = g;
    }

    override string toString() {
        return "Variable%s %s:%s".format(isPublic?"(+)":"", name, _type);
    }
}