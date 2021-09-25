module ppl4.ResolveState;

import ppl4.all;

final class ResolveState {
private:
    int[] currentUnresolvedNodeUids;
    int[] prevUnresolvedNodeUids;
    bool noProgressMade;
public:
    Module mod;

    this(Module mod) {
        this.mod = mod;
    }

    void beforePass() {
        this.prevUnresolvedNodeUids = this.currentUnresolvedNodeUids;
        this.currentUnresolvedNodeUids.length = 0;
    }
    void afterPass() {
        this.currentUnresolvedNodeUids = collectUnresolvedNodes();
        //trace("    %s :: curr = %s, prev = %s", mod, current, prevUnresolvedNodeUids);

        this.noProgressMade = false;

        if(currentUnresolvedNodeUids.length > 0 && currentUnresolvedNodeUids == prevUnresolvedNodeUids) {
            noProgressMade = true;
            trace(RESOLVE, "        No progress");
        }
    }

    bool success() {
        return currentUnresolvedNodeUids.length == 0;
    }
    int getNumUnresolved() {
        return currentUnresolvedNodeUids.length.as!int;
    }
    Statement[] getUnresolvedStatements() {
        Statement[] stmts;
        mod.each!Statement((n) {
            if(currentUnresolvedNodeUids.contains(n.id())) {
                stmts ~= n;
            }
        });
        return stmts;
    }
    bool isStalemate() {
        return noProgressMade;
    }
private:
    int[] collectUnresolvedNodes() {
        int[] uids;
        mod.each!Statement((n) {
            if(!n.isResolved()) {
                uids ~= n.id();
            }
        });
        uids.sort();
        return uids;
    }
 }