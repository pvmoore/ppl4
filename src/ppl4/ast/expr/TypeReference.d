module ppl4.ast.expr.TypeReference;

import ppl4.all;

final class TypeReference : Expression {
private:
    Type _type;
public:
    this(Module mod) {
        super(mod);
    }

    @Implements("Node")
    override NodeId id() { return NodeId.TYPE_REFERENCE; }

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
        return "TypeReference(%s)".format(_type);
    }
}
