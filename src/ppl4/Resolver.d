module ppl4.Resolver;

import ppl4.all;

final class Resolver {
private:
    enum MAX_PASS = 5;
    Compiler compiler;
    Writer writer;
    ulong elapsed;
    ResolveState[ModuleName] states;
public:
    this(Compiler compiler, Writer writer) {
        this.compiler = compiler;
        this.writer = writer;
    }
    /**
     * @return the number of unresolved nodes
     */
    int resolve(Module[] modules) {
        int numUnresolved = 0;

        elapsed += time(() {
            auto pass = 0;
            auto resolved = false;

            while(!resolved && pass < MAX_PASS) {
                numUnresolved = runPass(modules, pass);
                resolved = numUnresolved == 0;
                pass++;
            }

            // No further progress possible
            if(!resolved && pass == MAX_PASS) {
                foreach(state; states.values()) {
                    if(!state.success()) {
                        resolutionError(state);
                    }
                }
            }
        });

        trace(RESOLVE, "===================================================");
        return numUnresolved;
    }
private:
    ResolveState getState(Module m) {
        auto p = m.name in states;
        if(!p) {
            auto state = new ResolveState(m);
            states[m.name] = state;
            return state;
        }
        return *p;
    }
    /**
     * Run a resolution pass and return the number of unresolved Nodes
     */
    int runPass(Module[] modules, int pass) {
        trace(RESOLVE, "===================================================");
        trace(RESOLVE, "pass %s", pass);

        foreach(state; states.values()) {
            state.beforePass();
        }

        // todo - parallel foreach here
        foreach(m; modules) {
            auto state = getState(m);

            m.resolve(state);
            m.fold();

            writer.writeAST(m, "_%s".format(pass));
        }

        auto numUnresolved = 0;

        foreach(state; states.values()) {
            state.afterPass();
            numUnresolved += state.getNumUnresolved();
        }

        if(numUnresolved > 0) {
            trace(RESOLVE, "    %s unresolved", numUnresolved);
        } else {
            trace(RESOLVE, "All symbols resolved");
        }
        return numUnresolved;
    }
}