module ppl4.ast.stmt.Module;

import ppl4.all;

/**
 *  Module
 *      { Statement }
 */
final class Module : Statement {
private:
public:
    ModuleName name;
    Config config;
    Token[] tokens;
    CompileError[] errors;
    LLVMModule llvmValue;

    this(Config config, ModuleName name) {
        super(this);
        this.config = config;
        this.name = name;
    }

    @Implements("Node")
    override NodeId id() { return NodeId.MODULE; }

    void addError(CompileError e) {
        errors ~= e;
    }

    void lex() {
        import std.file : read;

        auto path = config.getFullPath(name);
        auto lexer = new Lexer(this, cast(string)read(path.toString()));
        lexer.lex();
        this.tokens = lexer.getCodeTokens();
        trace("tokens = %s", tokens.toString());

        auto scanner = new ModuleScanner(this);
        scanner.scan();

        // get symbols from scanner here
    }

    /**
     * Struct | Class | Enum | Function | Variable | Import
     */
    @Implements("Statement")
    override Module parse(ParseState state) {

        while(!state.isEOF()) {
            super.parse(state);
        }

        trace("--------------------");
        dump();
        trace("--------------------");
        return this;
    }

    /**
     *
     */
    @Implements("Statement")
    override void resolve(ResolveState state) {
        this.isResolved = true;
        super.resolve(state);
    }
    /**
     * @return true if ...
     */
    @Implements("Statement")
    override void check() {
        // Nothing to do
        super.check();
    }

    /**
     * @return true if the module was generated successfully
     */
    @Implements("Statement")
    override void generate(GenState state) {
        this.llvmValue = state.llvm.createModule(name.value);

        // Generate module scope strings
        // Generate module scope variables
        auto vars = collectChildren!Variable;

        // Generate module scope functions
        // Needs to be done first so that we have the decl LLVLValueRefs available
        auto funcs = collectChildren!Function;
        //trace("funcs = %s", funcs);
        foreach(f; funcs) {
            f.generateDecl();
        }

        // Generate structs and classes
        auto structs = collectChildren!Struct;
        // Generate Enums

        super.generate(state);

        state.writeLL(Directory("ir"));
        state.verify();

        state.optimise();
        state.writeLL(Directory("ir_opt"));
        state.verify();
    }

    override string toString() {
        return "Module '%s'".format(name);
    }
protected:

}