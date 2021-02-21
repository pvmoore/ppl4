module ppl4.phases.ResolveState;

import ppl4.all;

final class ResolveState {
private:
    Module mod;
    Statement[] _unresolved;
public:
    this(Module mod) {
        this.mod = mod;
    }
    void reset() {
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