module ppl4.ast.expr.Number;

import ppl4.all;

/**
 *  Number
 */
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
        return "Number %s".format(valueStr);
    }
}