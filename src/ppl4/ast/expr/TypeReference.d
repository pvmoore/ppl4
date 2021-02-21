module ppl4.ast.expr.TypeReference;

import ppl4.all;

/**
 *  TypeReference
 */
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
    override void resolve(ResolveState state) {
        if(!isResolved) {

        }
    }

    @Implements("Statement")
    override bool check() {
        // 1) ...
        return true;
    }

    @Implements("Statement")
    override void generate(GenState state) {

    }

    override string toString() {
        return "TypeReference(%s)".format(_type);
    }
}
