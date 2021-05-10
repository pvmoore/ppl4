module ppl4.phases.ResolveState;

import ppl4.all;

final class ResolveState : AbsNodeMaker {
private:
    Statement[] _unresolved;
    int[] prevUnresolvedNodeUids;
    int iterations;
    bool noProgressMade;
public:
    this(Module mod) {
        super(mod);
    }

    override Token getStartToken() {
        return mod.startToken;
    }

    void reset() {
        iterations++;
        auto prev = _unresolved.map!(it=>it.uid).array().sort().array();
        sort(prev);
        trace("    %s curr = %s, prev = %s", mod, prev, prevUnresolvedNodeUids);

        if(prev.length > 0 && prev == prevUnresolvedNodeUids) {
            noProgressMade = true;
            trace("        No progress");
        }

        _unresolved.length = 0;
    }
    bool success() {
        return _unresolved.length == 0;
    }
    void unresolved(Statement stmt) {
        this._unresolved ~= stmt;
    }
    int getNumUnresolved() {
        return _unresolved.length.as!int;
    }
    Statement[] getUnresolvedStatements() {
        return _unresolved;
    }
    bool isStalemate() {
        return noProgressMade;
    }
 }