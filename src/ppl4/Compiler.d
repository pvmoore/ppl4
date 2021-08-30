module ppl4.Compiler;

import ppl4.all;

final class Compiler {
private:
    Module mainModule;
    Module[ModuleName] modules;
    Config config;
    ulong parseTime, resolveTime, checkTime, generateTime, linkTime;
    LLVMWrapper llvm;
    Writer writer;
    Resolver resolver;
public:
    this(Config config) {
        this.config = config;
        this.llvm = new LLVMWrapper;
        this.writer = new Writer(llvm, config);
        this.resolver = new Resolver(this, writer);
    }
    void compile() {
        scope(exit) destroy();

        ModuleName mainModuleName = ModuleName(config.mainFilename);

        this.mainModule = createModule(mainModuleName);

        try{
            parsePhase();

            // If we get here then there are no SyntaxErrors

            if(!resolvePhase()) {
                error("Symbol resolution failed");
                return;
            }

            // If we get here then all symbols are resolved

            if(!checkPhase()) {
                error("Semantic check failed");
                return;
            }

            if(!generatePhase()) {
                error("Generation failed");
                return;
            }

            if(!linkPhase()) {
                error("Link failed");
                return;
            }

        }catch(SyntaxError e) {
            error("Syntax error: %s".format(e));
        }catch(VerifyError e) {
            error("Verification error");
        }
    }
    void destroy() {
        this.llvm.destroy();
    }
    bool hasErrors() {
        return getErrors().length > 0;
    }
    CompilationError[] getErrors() {
        CompilationError[] e;
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
        info("★ Parse phase");
        parseTime += time((){
            foreach(m; modules) {
                m.parse(new ParseState(m, m.tokens));
            }
        });
    }
    bool resolvePhase() {
        info("★ Resolve phase");
        return resolver.resolve(modules.values()) == 0;
    }
    bool checkPhase() {
        info("★ Check phase");
        checkTime += time(() {
            foreach(m; modules) {
                m.check();
            }
        });
        return !hasErrors();
    }
    bool generatePhase() {
        info("★ Generate phase");
        bool result = true;
        generateTime += time(() {
            foreach(m; modules) {
                auto state = new GenState(llvm, writer, m);
                m.generate(state);
                result &= state.success();
            }

            if(result) {
                // Create one merged module and optimise it
                auto otherModules = modules.values()
                                        .filter!(it=>it !is mainModule)
                                        .map!(it=>it.llvmValue)
                                        .array();

                if(otherModules.length > 0) {
                    llvm.linkModules(mainModule.llvmValue, otherModules);
                    llvm.passManager.runOnModule(mainModule.llvmValue);
                    writer.writeLL(mainModule, Directory(""));
                }
            }
        });
        return result;
    }
    bool linkPhase() {
        info("★ Link phase");

        bool result;
        linkTime += time(() {
            auto linker = new Linker(llvm, writer, config, mainModule);
            result = linker.link();
        });
        return result;
    }
    Module getOrCreateModule(ModuleName name) {
        auto p = name in modules;
        if(!p) {
            return createModule(name);
        }
        return *p;
    }
    Module createModule(ModuleName name) {
        auto m = new Module(config, writer, name);
        //m.startToken = MODULE_TOKEN;
        m.uid = 0;

        modules[name] = m;

        m.lex();

        return m;
    }
}