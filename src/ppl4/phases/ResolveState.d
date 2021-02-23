module ppl4.phases.ResolveState;

import ppl4.all;

final class ResolveState : AbsNodeMaker {
private:
    Statement[] _unresolved;
    int[] prevUnresolvedNodeUids;
public:
    this(Module mod) {
        super(mod);
    }

    override Token getStartToken() {
        return mod.startToken;
    }

    void reset() {
        prevUnresolvedNodeUids = _unresolved.map!(it=>it.uid).array().sort().array();
        info("prev = %s", prevUnresolvedNodeUids);
        sort(prevUnresolvedNodeUids);
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
}