module ppl4.ast.expr.type.TypeExpression;

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
        this._type = UNKNOWN_TYPE;
    }
    auto withType(Type type) {
        this._type = type;
        return this;
    }

    //=================================================================================== Expression
    override Type type() { return _type; }

    override int precedence() { return precedenceOf(Operator.TYPE_EXPRESSION); }

    //========================================================================================= Node
    override NodeId id() { return NodeId.TYPE_EXPRESSION; }

    override TypeExpression parse(ParseState state) {
        switch(state.text()) {
            case "bool":
                _type = new BuiltinType(TypeKind.BOOL);
                break;
            case "byte":
                _type = new BuiltinType(TypeKind.BYTE);
                break;
            case "short":
                _type = new BuiltinType(TypeKind.SHORT);
                break;
            case "int":
                _type = new BuiltinType(TypeKind.INT);
                break;
            case "long":
                _type = new BuiltinType(TypeKind.LONG);
                break;
            case "float":
                _type = new BuiltinType(TypeKind.FLOAT);
                break;
            case "double":
                _type = new BuiltinType(TypeKind.DOUBLE);
                break;
            case "void":
                _type = new BuiltinType(TypeKind.VOID);
                break;
            case "fn":
                _type = new FunctionType().parse(state, this);
                break;
            default:
                pplAssert(false, "We shouldn't get here");
                break;
        }
        if(_type) {
            state.next();

            while(TokenKind.ASTERISK == state.kind()) {
                _type.ptrDepth++;
                state.next();
            }
        }

        return this;
    }

    override void resolve(ResolveState state) {
        if(_type.isResolved()) {
            setResolved();
        } else {
            setUnresolved();
        }
    }

    override void check() {
        // 1) ...
    }

    override void generate(GenState state) {

    }

    //======================================================================================= Object
    override string toString() {
        return "TypeExpression %s %s".format(_type, isResolved() ? "✅" : "❌");
    }
}
