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

    //==============================================================================================
    this(Module mod) {
        super(mod);
    }

    //========================================================================================= Node
    override NodeId id() { return NodeId.IMPORT; }

    override void findDeclaration(string name, ref bool[Declaration] targets, Node src) {
        todo("look in external Module");
    }

    /**
     * "import" ModuleName [ "." Symbol ]
     * name = "import" ModuleName [ "." Symbol ]
     */
    override Import parse(ParseState state) {
        todo();
        return this;
    }

    override void resolve(ResolveState state) {

    }

    override void check() {
        // 1) ...
    }

    override void generate(GenState state) {

    }

    //======================================================================================= Object
    override string toString() {
        return "Import";
    }
}
