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

    @Implements("Expression")
    override int precedence() { return precedenceOf(Operator.TYPE_REFERENCE); }

    @Implements("Node")
    override TypeReference parse(ParseState state) {
        todo();
        return this;
    }

    @Implements("Node")
    override void resolve(ResolveState state) {
        if(!isResolved) {

        }
    }

    @Implements("Node")
    override void check() {
        // 1) ...
    }

    @Implements("Node")
    override void generate(GenState state) {

    }

    override string toString() {
        return "TypeReference(%s)".format(_type);
    }
}
