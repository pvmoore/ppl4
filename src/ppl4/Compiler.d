module ppl4.Compiler;

import ppl4.all;

final class Compiler {
private:
    Module mainModule;
    Module[ModuleName] modules;
    Config config;
    ulong parseTime, resolveTime, checkTime, generateTime, linkTime;
public:
    this(Config config) {
        this.config = config;
    }
    void compile() {
        ModuleName mainModuleName = ModuleName(config.mainFilename);

        this.mainModule = createModule(mainModuleName);

        try{
            parsePhase();

            // If we get here then there are no SyntaxErrors

            bool r = resolvePhase();
            trace("    %s", r);

            r = checkPhase();
            trace("    %s", r);

            r = generatePhase();
            trace("    %s", r);

            r = linkPhase();
            trace("    %s", r);

        }catch(SyntaxError e) {
            error("Syntax error: %s".format(e));
        }
    }
    bool hasErrors() {
        return getErrors().length > 0;
    }
    CompileError[] getErrors() {
        CompileError[] e;
        foreach(m; modules) {
            e ~= m.errors;
        }
        return e;
    }
    string getReport() {
        string s;
        s ~= "Parse time ...... %.1f ms\n".format(parseTime / 1000_000.0);
        s ~= "Resolve time .... %.1f ms\n".format(resolveTime / 1000_000.0);
        s ~= "Check time ...... %.1f ms\n".format(checkTime / 1000_000.0);
        s ~= "Generate time ... %.1f ms\n".format(generateTime / 1000_000.0);
        s ~= "Link time ....... %.1f ms\n".format(linkTime / 1000_000.0);
        s ~= "Total time ...... %.1f ms".format(
            (parseTime+resolveTime+checkTime+generateTime+linkTime) / 1000_000.0);
        return s;
    }
private:
    void parsePhase() {
        info("Parse phase");
        parseTime += time((){
            foreach(m; modules) {
                m.parse(new ParseState(m, m.tokens));
            }
        });
    }
    bool resolvePhase() {
        info("Resolve phase");
        bool result = true;
        resolveTime += time(() {
            foreach(m; modules) {
                auto state = new ResolveState(m);
                m.resolve(state);
                result &= state.success();
                if(!state.success()) {
                    trace("    %s unresolved", state.getNumUnresolved());
                }
            }
        });
        return result;
    }
    bool checkPhase() {
        info("Check phase");
        bool result = true;
        checkTime += time(() {
            foreach(m; modules) {
                result &= m.check();
            }
        });
        return result;
    }
    bool generatePhase() {
        info("Generate phase");
        bool result = true;
        generateTime += time(() {
            foreach(m; modules) {
                auto state = new GenState(m);
                m.generate(state);
                result &= state.success();
            }
        });
        return result;
    }
    bool linkPhase() {
        info("Link phase");
        linkTime += time(() {

        });
        return true;
    }
    Module getOrCreateModule(ModuleName name) {
        auto p = name in modules;
        if(!p) {
            return createModule(name);
        }
        return *p;
    }
    Module createModule(ModuleName name) {
        auto m = new Module(config, name);
        modules[name] = m;

        m.lex();

        return m;
    }
}