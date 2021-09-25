module ppl4.ast.stmt.decl.Declaration;

import ppl4.all;

/**
 * Definition
 *      [ Expression ]
 */
class Declaration : Statement {
protected:
    bool hasExplicitType;       // true if a Type is explicitly provided eg. :Type
    bool noTypeProvided;
    LLVMValueRef _llvmValue;
public:
    string name;
    Type type;
    bool isPublic;

    bool isModule() { return false; }
    bool isClass() { return isStruct() && expr().as!StructLiteral.isClass; }
    bool isStruct() { return expr().isA!StructLiteral; }
    bool isFunction() { return expr().isA!FnLiteral; }
    bool isTypedef() { return expr().isA!TypeExpression; }
    bool isVariable() { return false; }
    bool isParameter() { return false; }

    final bool isLocal() { return parent.isA!FnLiteral; }
    final bool isGlobal() { return parent.isA!Module; }
    final bool isMember() { return parent.isA!StructLiteral; }

    bool hasInitialiser() {
        return hasChildren();
    }
    Expression expr() {
        pplAssert(hasInitialiser(), "Expecting initialiser");
        return first().as!Expression;
    }

    LLVMValueRef getLlvmValue() { return _llvmValue; }

    //==============================================================================================
    this(Module mod, bool isPublic) {
        super(mod);
        this.isPublic = isPublic;
        this.type = UNKNOWN_TYPE;
    }

    //========================================================================================= Node
    override void findDeclaration(string name, ref bool[Declaration] decls, Node src) {
        if(this.name == name) {
            decls[this] = true;
        }
        super.findDeclaration(name, decls, src);
    }

    /**
     * One of:
     *  name "=" Expression
     *  name ":" Type
     *  name ":" Type "=" Expression
     */
    override Declaration parse(ParseState state) {

        bool isNameType = state.isKind(TokenKind.IDENTIFIER) && state.peek(1).kind == TokenKind.COLON;
        bool isNameEquals = state.isKind(TokenKind.IDENTIFIER) && state.peek(1).kind;

        trace(PARSE, "Declaration '%s' %s%s", state.text(),
            isNameType ? "name:type" : "", isNameEquals ? "name=" : "");

        if(isNameType) {
            // name : Type [ = Expression ]

            // name
            this.name = state.text(); state.next();

            // :
            state.skip(TokenKind.COLON);

            // Type
            this.type = parseType(state, this);

        } else if(isNameEquals) {
            // name =

            // We will need to get the type from the initialiser later
            this.noTypeProvided = true;

            // name
            this.name = state.text(); state.next();

        } else {
            // Type
            this.type = parseType(state, this);
        }

        // =    (Optional initialiser Expression)
        if(state.kind==TokenKind.EQUALS) {
            state.next();

            // Expression
            parseExpression(state, this);
        }

        return this;
    }

    override void resolve(ResolveState state) {
        if(!type.isResolved()) {
            resolveTypeFromInitialiser();
        }

        if(!type.isResolved()) {
            setUnresolved();
        } else {
            setResolved();
        }
    }

    override void check() {
        super.check();
    }

    override void generate(GenState state) {
        super.generate(state);
    }

    //======================================================================================= Object
    override string toString() {
        return "Decl %s:%s %s".format(name, type, isResolved() ? "✅" : "❌");
    }
private:

    void resolveTypeFromInitialiser() {
        if(!hasInitialiser()) return;

        // Allow the type to resolve and use that
        if(!noTypeProvided) return;

        // Wait for the initialiser to resolve
        auto e = expr();
        if(!e.isResolved()) return;

        // Use the type of the expresion
        this.type = e.type();
    }
}