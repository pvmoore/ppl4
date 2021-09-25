module ppl4.zdeprecated.VariableOld;

import ppl4.all;

/**
 *  Variable
 *      [ Expression ]
 */
 /+
final class VariableOld : Statement, ITarget {
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
        this._type = UNKNOWN_TYPE;
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
        return parent.isA!StructLiteral;
    }
    @Implements("ITarget, Expression")
    Type type() {
        return _type;
    }
    @Implements("ITarget, Node")
    override bool isResolved() {
        return _isResolved;
    }
    @Implements("ITarget")
    override LLVMValueRef getLlvmValue() {
        return llvmValue;
    }

    @Implements("Node")
    override NodeId id() { return NodeId.VARIABLE; }

    @Implements("Node")
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
    override VariableOld parse(ParseState state) {

        // pub
        if("pub" == state.text()) {
            state.next();
            this.isPublic = true;
        }

        bool isNameType = state.isKind(TokenKind.IDENTIFIER) && state.peek(1).kind == TokenKind.COLON;
        bool isNameEquals = state.isKind(TokenKind.IDENTIFIER) && state.peek(1).kind == TokenKind.EQUALS;

        if(isNameType) {
            // name : Type [ = Expression ]

            // name
            this.name = state.text(); state.next();

            // : Type
            if(state.kind() == TokenKind.COLON) {
                state.next();

                this._explicitType = true;
                this._type = parseType(state, this);

            }

            // =
            if(state.isKind(TokenKind.EQUALS)) {
                state.next();

                parseExpression(state, this);
            } else if(!_explicitType) {
                syntaxError(state, "Variable is missing type information");
            }
        } else if(isNameEquals) {
            // name = Expression

            // name
            this.name = state.text(); state.next();

            // =
            if(state.isKind(TokenKind.EQUALS)) {
                state.next();

                parseExpression(state, this);
            }

        } else {
            // Type without a name. Must be an extern function
            this._explicitType = true;
            this._type = parseType(state, this);
        }

        return this;
    }

    @Implements("Node")
    override void resolve(ResolveState state) {

        resolveChildren(state);

        if(!_type.isResolved()) {

            if(!_explicitType) {
                // Get the type from the Expression
                if(expr().type().isResolved()) {
                    _type = expr().type();
                    setResolved();
                }
            } else {
                // resolve explicit type
                _type = resolveType(this, _type);
            }
        } else {
            setResolved();
        }

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
        return "Variable%s %s:%s".format(isPublic?"(pub)":"", name, _type);
    }
}
+/