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
    Writer writer;
    Token[] tokens;
    CompilationError[] errors;
    LLVMModule llvmValue;

    ScannerResults scan;

    this(Config config, Writer writer, ModuleName name) {
        super(this);
        this.config = config;
        this.writer = writer;
        this.name = name;
    }

    Variable[] getVariables() {
        return collectChildren!Variable;
    }
    Function[] getFunctions() {
        return collectChildren!Function;
    }
    Function[] getFunctions(string name) {
        return getFunctions.filter!(it=>it.name == name).array;
    }
    Struct[] getStructs() {
        return collectChildren!Struct;
    }
    Struct getStruct(string name) {
        return getStructs().filter!(it=>it.name == name).frontOrNull!Struct;
    }

    bool declaresType(string name, bool includingPrivate) {
        return scan.containsStruct(name, includingPrivate) ||
               scan.containsEnum(name, includingPrivate);
    }

    void addError(CompilationError e) {
        errors ~= e;
    }

    void lex() {
        import std.file : read;

        auto path = config.getFullPath(name);
        auto lexer = new Lexer(this, cast(string)read(path.toString()));
        lexer.lex();
        this.tokens = lexer.getCodeTokens();
        writer.writeTokens(this);

        auto scanner = new ModuleScanner(this);
        this.scan = scanner.scan();

        trace(scan.toString());
    }

    @Implements("Node")
    override NodeId id() { return NodeId.MODULE; }

    @Implements("Statement")
    override void findTarget(string name, ref ITarget[] targets, Expression src) {
        foreach(t; collectChildren!ITarget) {
            auto v = t.as!Variable;
            auto f = t.as!Function;
            if(v && v.name == name) {
                targets ~= v;
            } else if(f && f.name == name) {
                targets ~= f;
            }
        }
        super.findTarget(name, targets, src);
    }

    /**
     * Struct | Class | Enum | Function | Variable | Import
     */
    @Implements("Statement")
    override Module parse(ParseState state) {

        while(!state.isEOF()) {
            super.parse(state);
        }

        addInitFunction();

        return this;
    }

    /**
     *
     */
    @Implements("Statement")
    override void resolve(ResolveState state) {
       setResolved();
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

        // TODO - Generate module scope strings

        // Generate module scope variables
        auto vars = collectChildren!Variable;
        foreach(v; vars) {
            v.generateDeclaration();
        }

        // TODO - Generate structs and classes
        auto structs = collectChildren!Struct;
        foreach(s; structs) {
            s.generateDeclaration();
        }

        // TODO - Generate Enums

        // Generate module scope functions
        auto funcs = collectChildren!Function;
        foreach(f; funcs) {
            f.generateDeclaration();
        }



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
    /**
     *  Add __init() if it does not exist
     */
    void addInitFunction() {
        auto f = getFunctions("__init");
        if(f.length==0) {
            auto i = Function.make(mod, "__init", new FunctionType(null, VOID));
            add(i);
        } else {

        }
    }
}