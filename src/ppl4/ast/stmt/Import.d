module ppl4.ast.stmt.Import;

import ppl4.all;

/**
 * Import
 */
final class Import : Statement {
private:
    Module externalModule;
public:
    string name;

    this(Module mod) {
        super(mod);
    }

    @Implements("Node")
    override NodeId id() { return NodeId.IMPORT; }

    /**
     * "import" ModuleName [ "." Symbol ]
     * name = "import" ModuleName [ "." Symbol ]
     */
    @Implements("Statement")
    override Statement parse(ParseState state) {
        todo();
        return this;
    }

    @Implements("Statement")
    override void resolve(ResolveState state) {
        
    }

    @Implements("Statement")
    override bool check() {
        // 1) ...
        return true;
    }

    @Implements("Statement")
    override void generate(GenState state) {

    }

    override string toString() {
        return "Import";
    }
}
