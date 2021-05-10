module ppl4.phases.Resolver;

import ppl4.all;

final class Resolver {
private:
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
        auto numUnresolved = 0;

        elapsed += time(() {

            bool resolved = false;

            for(auto pass = 0; !resolved && pass < 5; pass++) {
                trace("===================================================");
                trace("pass %s", pass);
                numUnresolved = 0;

                // todo - parallel foreach here
                foreach(m; modules) {
                    auto state = getState(m);
                    m.resolve(state);
                    numUnresolved += state.getNumUnresolved();

                    writer.writeAST(m);
                }

                resolved = numUnresolved == 0;

                if(!resolved) {
                    trace("    %s unresolved", numUnresolved);

                    foreach(state; states.values()) {
                        if(!state.success()) {
                            foreach(i, stmt; state.getUnresolvedStatements()) {
                                info("    [%s][%s] %s", stmt.mod, i, stmt);
                            }
                        }
                    }

                    foreach(state; states.values()) {
                        state.reset();
                    }

                } else {
                    trace("All symbols resolved");
                }
            }
        });
        trace("===================================================");

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
}