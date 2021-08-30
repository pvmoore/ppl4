module ppl4.ast.stmt.Statement;

import ppl4.all;

abstract class Statement : Node {
protected:
    bool _isResolved;
public:
    Module mod;
    Token startToken;

    this(Module mod) {
        this.mod = mod;
    }

    final int line() { return startToken.line; }
    final int column() { return startToken.column; }
    bool isResolved() { return _isResolved; }
    final void setResolved() { this._isResolved = true; }

    //abstract Function findFunction(string name);
    //abstract Variable findVariable(string name);

protected:
    Type resolveTypeFromParent() {
        switch(parent.id()) with(NodeId) {
            case VARIABLE:
                auto var = parent.as!Variable;
                if(var.type().isResolved()) {
                    return var.type();
                }
                break;
            default:
                todo("implement %s.resolveTypeFromParent - parent is %s".format(this.id(), parent.id()));
                break;
        }
        return UNKNOWN_TYPE;
    }
}