module ppl4.ast.expr.TypeExpression;

import ppl4.all;

/**
 *  TypeExpression
 */
final class TypeExpression : Expression {
private:
    Type _type;
public:
    this(Module mod) {
        super(mod);
    }

    @Implements("Node")
    override NodeId id() { return NodeId.TYPE_EXPRESSION; }

    @Implements("Expression")
    override Type type() { return _type; }

    @Implements("Expression")
    override int precedence() { return precedenceOf(Operator.TYPE_EXPRESSION); }

    @Implements("Node")
    override TypeExpression parse(ParseState state) {
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
