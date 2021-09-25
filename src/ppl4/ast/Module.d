module ppl4.ast.Module;

import ppl4.all;

/**
 *  Module
 *      { Statement }
 */
final class Module : Node {
private:
public:
    ModuleName name;
    Config config;
    Writer writer;
    Token[] tokens;
    UniqueList!CompilationError errors;
    LLVMModule llvmValue;

    NodeFactory nodeFactory;
    ScannerResults scan;

    bool hasErrors() { return errors.length > 0; }

    //==============================================================================================
    this(Config config, Writer writer, ModuleName name) {
        super(this);
        this.config = config;
        this.writer = writer;
        this.name = name;
        this.errors = new UniqueList!CompilationError;
        this.nodeFactory = new NodeFactory(this);
    }

    VarDecl[] getVariables() {
        return collectChildren!VarDecl;
    }
    FnDecl[] getFunctions() {
        return collectChildren!FnDecl;
    }
    FnDecl[] getFunctions(string name) {
        return getFunctions.filter!(it=>it.name == name).array;
    }
    StructDecl[] getStructDecls() {
        return collectChildren!StructDecl;
    }
    StructDecl getStructDecl(string name) {
        return getStructDecls().filter!(it=>it.name == name).frontOrNull!StructDecl;
    }

    bool declaresType(string name, bool includingPrivate) {
        return scan.containsStruct(name, includingPrivate) ||
               scan.containsEnum(name, includingPrivate);
    }

    void addError(CompilationError e) {
        errors.add(e);
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

        trace(LEX, scan.toString());
    }

    //========================================================================================= Node
    override NodeId id() { return NodeId.MODULE; }

    override void findDeclaration(string name, ref bool[Declaration] decls, Node src) {
        // auto decl = getStructDecl(name);
        // if(decl) {
        //     decls[decl] = true;
        // }
        //trace("MODULE findDeclaration");
        foreach(t; collectChildren!Declaration) {
            auto v = t.as!VarDecl;
            auto f = t.as!FnDecl;
            if(v && v.name == name) {
                decls[v] = true;
            } else if(f && f.name == name) {
                decls[f] = true;
            }
        }
        super.findDeclaration(name, decls, src);
    }

    /**
     * StructDef | Class | Enum | FnDecl | VariableOld | Import
     */
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
    override void resolve(ResolveState state) {
        setResolved();
        super.resolve(state);
    }
    /**
     * @return true if ...
     */
    override void check() {
        super.check();
    }

    /**
     * @return true if the module was generated successfully
     */
    override void generate(GenState state) {
        this.llvmValue = state.llvm.createModule(name.value);

        // TODO - Generate module scope strings

        // Generate module scope variables
        auto vars = collectChildren!VarDecl;
        foreach(v; vars) {
            v.generateDeclaration();
        }

        // TODO - Generate structs and classes
        auto structs = collect!StructDecl;
        foreach(s; structs) {
            s.generateDeclaration();
        }

        // TODO - Generate Enums

        // Generate module scope functions
        auto funcs = collect!FnLiteral;
        foreach(f; funcs) {
            f.generateDeclaration();
        }

        // Generate extern functions
        auto efnDecls = collect!ExternFnDecl;
        foreach(f; efnDecls) {
            f.generateDeclaration();
        }




        super.generate(state);

        state.writeLL(Directory("ir"));
        state.verify();

        state.optimise();
        state.writeLL(Directory("ir_opt"));
        state.verify();
    }

    //======================================================================================= Object
    override string toString() {
        return "Module %s%s".format(name, isResolved ? "✅" : "❌");
    }
protected:
    /**
     *  Add default() if it does not exist
     */
    void addInitFunction() {
        auto f = getFunctions("__default");
        if(f.length==0) {
            auto i = nodeFactory.makeFunction("__default", false, new FunctionType([], VOID));
            add(i);
        } else {

        }
    }
}