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

        parsePhase();
        resolvePhase();
        checkPhase();
        generatePhase();
        linkPhase();
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
    void resolvePhase() {
        info("Resolve phase");
        resolveTime += time(() {
            foreach(m; modules) {
                m.resolve();
            }
        });
    }
    void checkPhase() {
        info("Check phase");
        checkTime += time(() {
            foreach(m; modules) {
                m.check();
            }
        });
    }
    void generatePhase() {
        info("Generate phase");
        generateTime += time(() {
            foreach(m; modules) {
                m.generate();
            }
        });
    }
    void linkPhase() {
        info("Link phase");
        linkTime += time(() {

        });
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