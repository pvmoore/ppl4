module ppl4.zdeprecated.StructOld;

import ppl4.all;

/**
 *  Struct
 *      { [ Variable ] }
 *      { [ Function ] }
 *      { [ Import ] }
 */
 /+
final class StructOld : Statement {
private:
    StructType _type;
public:
    string name;
    bool isPublic;
    bool isClass;       // implicit ptr
    bool isPacked;
    LLVMTypeRef llvmType;

    this(Module mod, bool isPublic) {
        super(mod);
        this.isPublic = isPublic;
        //this._type = new StructType(this);
    }

    VariableOld[] getVariables() {
        return collectChildren!VariableOld;
    }
    FnDecl[] getFunctions() {
        return collectChildren!FnDecl;
    }
    Type[] getVariableTypes() {
        return getVariables()
                .map!(it=>it.type())
                .array;
    }

    void generateDeclaration() {
        this.llvmType = struct_(name);

        auto t = getVariableTypes();
        auto lt = t.map!(it=>it.getLLVMType()).array;

        setTypes(llvmType, lt, isPacked);
    }

    @Implements("Node")
    override NodeId id() { return NodeId.STRUCT; }

    @Implements("Statement")
    override void findTarget(string name, ref ITarget[] targets, Expression src) {
        // Only look at Struct variables and functions
        // if the src Identifier is within this Struct
        auto s = src.ancestor!StructLiteral;
        if(s && s is this) {
            foreach(t; collectChildren!ITarget) {
                auto v = t.as!VariableOld;
                auto f = t.as!FnDecl;

                if(v && v.name == name) {
                    targets ~= v;
                } else if(f && f.name == name) {
                    targets ~= f;
                }
            }
        }
        super.findTarget(name, targets, src);
    }

    /**
     * name "=" "struct" "{" ( Function | Variable | Import ) "}"
     */
    @Implements("Node")
    override StructOld parse(ParseState state) {

        // name
        this.name = state.text(); state.next();

        // =
        state.skip(TokenKind.EQUALS);

        // struct | class | component
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

    @Implements("Node")
    override void resolve(ResolveState state) {
        super.resolve(state);

        setResolved();
        reorderVariables();
    }

    @Implements("Node")
    override void check() {
        // 1) ...
        super.check();
    }

    @Implements("Node")
    override void generate(GenState state) {

    }

    override string toString() {
        return "Struct%s '%s'".format(isPublic ? "(pub)":"", name);
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
+/