module ppl4.ast.expr.Identifier;

import ppl4.all;

/**
 *  Identifier
 */
final class Identifier : Expression {
private:

public:
    string name;
    Declaration target;

    //==============================================================================================
    this(Module mod) {
        super(mod);
    }

    //=================================================================================== Expression
    override Type type() {
        return target && target.isResolved ? target.type : UNKNOWN_TYPE;
    }

    override int precedence() { return precedenceOf(Operator.IDENTIFIER); }

    //========================================================================================= Node
    override NodeId id() { return NodeId.IDENTIFIER; }

    /**
     * name
     */
    override Identifier parse(ParseState state) {
        // name
        this.name = state.text(); state.next();

        return this;
    }

    override void resolve(ResolveState state) {
        if(!isResolved) {
            resolveTarget();

            if(target) {
                setResolved();
            } else {
                setUnresolved();
            }
        }
    }

    override void check() {

    }

    override void generate(GenState state) {
        if(target.isMember()) {
            todo();

        } else if(target.isA!FnDecl) {
            // function
            state.rhs = target.as!FnDecl.getLlvmValue();
            expect(state.rhs !is null);

        } else {
            // variable
            state.lhs = target.as!VarDecl.getLlvmValue();
            expect(state.lhs !is null);
            state.rhs = state.builder.load(state.lhs);
        }
    }

    //======================================================================================= Object
    override string toString() {
        return "Identifier %s:%s".format(name, target ? target.type : UNKNOWN_TYPE);
    }
private:
    void resolveTarget() {
        // trace("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        // trace("Looking for '%s'", name);
        // trace("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        bool[Declaration] targets;
        findDeclaration(name, targets, this);
        // trace("targets: %s", targets);
        // trace("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");

        if(targets.length == 0) {
            // TODO - not found
        } else if(targets.length == 1) {
            this.target = targets.keys()[0];
        } else {
            errorShadowingDeclaration(this, targets.keys());
        }
    }
}