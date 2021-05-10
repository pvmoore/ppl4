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

    @Implements("Statement")
    override void findTarget(string name, ref ITarget[] targets, Expression src) {
        todo("look in external Module");
    }

    /**
     * "import" ModuleName [ "." Symbol ]
     * name = "import" ModuleName [ "." Symbol ]
     */
    @Implements("Statement")
    override Import parse(ParseState state) {
        todo();
        return this;
    }

    @Implements("Statement")
    override void resolve(ResolveState state) {

    }

    @Implements("Statement")
    override void check() {
        // 1) ...
    }

    @Implements("Statement")
    override void generate(GenState state) {

    }

    override string toString() {
        return "Import";
    }
}
