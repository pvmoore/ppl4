module ppl4.ast.stmt.Struct;

import ppl4.all;

/**
 *  Struct
 *      { [ Variable ] }
 *      { [ Function ] }
 *      { [ Import ] }
 */
final class Struct : Statement {
private:
    StructType _type;
public:
    string name;
    bool isPublic;
    bool isClass;   // implicit ref
    bool isPacked;
    LLVMTypeRef llvmType;

    this(Module mod, bool isPublic) {
        super(mod);
        this.isPublic = isPublic;
        this._type = new StructType(this);
    }

    Variable[] getVariables() {
        return collectChildren!Variable;
    }
    Function[] getFunctions() {
        return collectChildren!Function;
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
        auto s = src.ancestor!Struct;
        if(s && s is this) {
            foreach(t; collectChildren!ITarget) {
                auto v = t.as!Variable;
                auto f = t.as!Function;
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
    @Implements("Statement")
    override Struct parse(ParseState state) {

        // name
        this.name = state.text(); state.next();

        // =
        state.skip(TokenKind.EQUALS);

        // struct | class
        if("struct" == state.text()) {
            
        } else if("class" == state.text()) {
            isClass = true;
        }
        state.next();

        // {
        state.skip(TokenKind.LCURLY);

        while(!state.isKind(TokenKind.RCURLY)) {
            super.parse(state);
        }

        // }
        state.skip(TokenKind.RCURLY);

        return this;
    }

    @Implements("Statement")
    override void resolve(ResolveState state) {
        super.resolve(state);

        setResolved();
        reorderVariables();
    }

    @Implements("Statement")
    override void check() {
        // 1) ...
        super.check();
    }

    @Implements("Statement")
    override void generate(GenState state) {

    }

    override string toString() {
        return "Struct%s '%s'".format(isPublic ? "(+)":"", name);
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