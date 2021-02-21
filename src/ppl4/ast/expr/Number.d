module ppl4.ast.expr.Number;

import ppl4.all;

final class Number : Expression {
private:
    Type _type;
public:
    string valueStr;

    this(Module mod) {
        super(mod);
    }

    @Implements("Node")
    override NodeId id() { return NodeId.NUMBER; }

    @Implements("Expression")
    override Type type() { return _type; }

    @Implements("Statement")
    override Statement parse(ParseState state) {
        todo();
        return this;
    }

    @Implements("Statement")
    override bool resolve() {
        todo();
        return false;
    }

    @Implements("Statement")
    override bool check() {
        todo();
        return false;
    }

    @Implements("Statement")
    override bool generate() {
        todo();
        return false;
    }

    override string toString() {
        return "Number %s".format(valueStr);
    }
}