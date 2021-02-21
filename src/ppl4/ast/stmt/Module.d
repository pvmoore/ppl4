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
    override Statement parse(ParseState state) {
        with(TokenKind) {

            while(!state.isEOF()) {
                super.parse(state);
            }

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

        trace("--------------------");
        dump();
        trace("--------------------");
    }
    /**
     * @return true if ...
     */
    @Implements("Statement")
    override bool check() {
        // Nothing to do
        return super.check();
    }

    /**
     * @return true if the module was generated successfully
     */
    @Implements("Statement")
    override void generate(GenState state) {


    }

    override string toString() {
        return "Module '%s'".format(name);
    }
protected:
}