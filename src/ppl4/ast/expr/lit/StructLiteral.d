module ppl4.ast.expr.lit.StructLiteral;

import ppl4.all;

/**
 * StructLiteral
 *      { Statement }
 */
final class StructLiteral : Literal {
private:

public:
    bool isClass;
    bool isPublic;
    bool isPacked;
    LLVMTypeRef llvmType;

    bool  isNamed() { return parent.isA!StructDecl; }
    string name() { pplAssert(isNamed(), "This is not a named struct"); return parent.as!StructDecl.name; }

    string uniqueName() {
        expect(isResolved());
        return "%s.%s".format(mod.name, name());
    }

    VarDecl[] getVariables() {
        return collectChildren!VarDecl;
    }
    FnDecl[] getFunctions() {
        return collectChildren!FnDecl;
    }
    Type[] getVariableTypes() {
        return getVariables()
                .map!(it=>it.type)
                .array;
    }

    // =============================================================================================
    this(Module mod) {
        super(mod);
        this._type = new StructType(this);
    }

    // ================================================================================== Expression
    override Type type() { return _type; }

    // ======================================================================================== Node
    override NodeId id() { return NodeId.STRUCT_LITERAL; }

    override void findDeclaration(string name, ref bool[Declaration] decls, Node src) {
        // Only look at Struct variables and functions
        // if the src Identifier is within this Struct
        auto s = src.ancestor!StructLiteral;
        if(s && s is this) {
            foreach(t; collectChildren!Declaration) {
                auto v = t.as!VarDecl;
                auto f = t.as!FnDecl;
                if(v && v.name == name) {
                    decls[v] = true;
                } else if(f && f.name == name) {
                    decls[f] = true;
                }
            }
        }
        super.findDeclaration(name, decls, src);
    }

    /**
     * ("struct"|"class") "{" { Statement } "}"
     */
    override StructLiteral parse(ParseState state) {

        // struct | class
        if("class" == state.text()) {
            isClass = true;
        }
        state.next();

        // {
        state.skip(TokenKind.LCURLY);

        while(!state.isKind(TokenKind.RCURLY)) {

            // Call Node.parse
            super.parse(state);
        }

        // }
        state.skip(TokenKind.RCURLY);

        return this;
    }

    override void resolve(ResolveState state) {
        super.resolve(state);

        setResolved();
        reorderVariables();
    }

    override void check() {
        super.check();
    }

    override void generate(GenState state) {
        super.generate(state);
    }

    // ====================================================================================== Object
    override string toString() {
        return "StructLiteral";
    }

    //==============================================================================================
    void generateDeclaration() {
        if(isNamed()) {

            this.llvmType = struct_(name);

            auto t = getVariableTypes();
            auto lt = t.map!(it=>it.getLLVMType()).array;

            setTypes(llvmType, lt, isPacked);
        } else {
            todo("generate unnamed struct type");
        }
    }
private:
    /**
     *  Change the order of member variables if isPacked == false (largest first?)
     */
    void reorderVariables() {
        if(isPacked) {
            return;
        }
        if(getVariableTypes().areResolved()) {
            // TODO

        }
    }
}