module ppl4.ast.expr.Identifier;

import ppl4.all;

/**
 *  Identifier
 */
final class Identifier : Expression {
private:

public:
    string name;
    ITarget target;

    this(Module mod) {
        super(mod);
    }

    @Implements("Node")
    override NodeId id() { return NodeId.IDENTIFIER; }

    @Implements("Expression")
    override Type type() {
        return target && target.isResolved() ? target.type() : UNKNOWN_TYPE;
    }

    @Implements("Expression")
    override int precedence() { return precedenceOf(Operator.IDENTIFIER); }

    /**
     * name
     */
    @Implements("Statement")
    override Identifier parse(ParseState state) {
        // name
        this.name = state.text(); state.next();

        return this;
    }

    @Implements("Statement")
    override void resolve(ResolveState state) {
        if(!_isResolved) {
            resolveTarget();

            if(target) {
                setResolved();
            } else {
                state.unresolved(this);
            }
        }
    }

    @Implements("Statement")
    override void check() {

    }

    @Implements("Statement")
    override void generate(GenState state) {
        if(target.isMember()) {
            todo();

        } else if(target.isA!Function) {
            // function
            state.rhs = target.as!Function.llvmValue;
            expect(state.rhs !is null);

        } else {
            // variable
            state.lhs = target.as!Variable.llvmValue;
            expect(state.lhs !is null);
            state.rhs = state.builder.load(state.lhs);
        }
    }

    override string toString() {
        return "Identifier %s:%s".format(name, target ? target.type() : UNKNOWN_TYPE);
    }
private:
    void resolveTarget() {
        // trace("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        // trace("Looking for '%s'", name);
        // trace("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        ITarget[] targets;
        findTarget(name, targets, this);
        // trace("targets: %s", targets);
        // trace("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");

        if(targets.length == 0) {
            // TODO - not found
        } else if(targets.length == 1) {
            this.target = targets[0];
        } else {
            // TODO - several matches found
        }
    }
}