module ppl4.eval.Calculator;

import ppl4.all;
import std.conv : to;

final class Calculator {
private:
    Module mod;
    NodeFactory factory;
public:
    this(Module mod) {
        this.mod = mod;
        this.factory = mod.nodeFactory;
    }
    /**
     * Calculate Binary
     */
    Number calculate(Number left, Number right, Operator op) {
        pplAssert(left.isResolved() && right.isResolved());
        pplAssert(left.type().isA!BuiltinType);
        pplAssert(right.type().isA!BuiltinType);

        Type type = getBestFit(left.type(), right.type());
        string value;

        if(type.isInteger() || type.isBool()) {
            long leftLong = getLong(left);
            long rightLong = getLong(right);
            bool leftBool = leftLong != FALSE;
            bool rightBool = rightLong != FALSE;

            switch(op) with(Operator) {
                case ADD: value = (leftLong + rightLong).to!string; break;
                case SUB: value = (leftLong - rightLong).to!string; break;
                case MUL: value = (leftLong * rightLong).to!string; break;
                case DIV: value = (leftLong / rightLong).to!string; break;
                case MOD: value = (leftLong % rightLong).to!string; break;

                case SHL: value = (leftLong << rightLong).to!string; break;
                case SHR: {
                        switch(type.kind) with(TypeKind) {
                            case BYTE:  value = ((leftLong | 0xffffffff_ffffff00) >> rightLong).as!byte.to!string; break;
                            case SHORT: value = ((leftLong | 0xffffffff_ffff0000) >> rightLong).as!short.to!string; break;
                            case INT:   value = ((leftLong | 0xffffffff_00000000) >> rightLong).as!int.to!string; break;
                            default:    value = (leftLong >> rightLong).to!string; break;
                        }
                    }
                    break;

                case USHR: {
                        switch(type.kind) with(TypeKind) {
                            case BYTE:  value = ((leftLong & 0xff) >>> rightLong).as!ubyte.to!string; break;
                            case SHORT: value = ((leftLong & 0xffff) >>> rightLong).as!ushort.to!string; break;
                            case INT:   value = ((leftLong & 0xffffffff) >>> rightLong).as!uint.to!string; break;
                            default:    value = (leftLong.as!ulong >>> rightLong).to!string; break;
                        }
                    }
                    break;

                case BITAND: value = (leftLong & rightLong).to!string; break;
                case BITOR: value = (leftLong | rightLong).to!string; break;
                case BITXOR: value = (leftLong ^ rightLong).to!string; break;

                case LT:  value = (leftLong < rightLong) ? TRUE_STR : FALSE_STR; break;
                case GT:  value = (leftLong > rightLong) ? TRUE_STR : FALSE_STR; break;
                case LTE: value = (leftLong <= rightLong) ? TRUE_STR : FALSE_STR; break;
                case GTE: value = (leftLong >= rightLong) ? TRUE_STR : FALSE_STR; break;
                case EQ:  value = (leftLong == rightLong) ? TRUE_STR : FALSE_STR; break;
                case NE:  value = (leftLong != rightLong) ? TRUE_STR : FALSE_STR; break;

                case AND: value = (leftBool && rightBool) ? TRUE_STR : FALSE_STR; break;
                case OR:  value = (leftBool || rightBool) ? TRUE_STR : FALSE_STR; break;

                default:
                    pplAssert(false, "Unsupported operator %s".format(op)); assert(false);
            }
        } else {
            // float/double
            double leftDbl = getDouble(left);
            double rightDbl = getDouble(right);

            switch(op) with(Operator) {
                case ADD: value = (leftDbl + rightDbl).to!string; break;
                case SUB: value = (leftDbl - rightDbl).to!string; break;
                case MUL: value = (leftDbl * rightDbl).to!string; break;
                case DIV: value = (leftDbl / rightDbl).to!string; break;
                case MOD: value = (leftDbl % rightDbl).to!string; break;

                case LT:  value = (leftDbl <  rightDbl) ? TRUE_STR : FALSE_STR; break;
                case GT:  value = (leftDbl >  rightDbl) ? TRUE_STR : FALSE_STR; break;
                case LTE: value = (leftDbl <= rightDbl) ? TRUE_STR : FALSE_STR; break;
                case GTE: value = (leftDbl >= rightDbl) ? TRUE_STR : FALSE_STR; break;
                case EQ:  value = (leftDbl == rightDbl) ? TRUE_STR : FALSE_STR; break;
                case NE:  value = (leftDbl != rightDbl) ? TRUE_STR : FALSE_STR; break;

                default:
                    pplAssert(false, "Unsupported operator %s".format(op)); assert(false);
            }
        }

        return value ? factory.makeNumber(type, value) : null;
    }
    /**
     * Calculate Unary
     */
    Number calculate(Number number, Operator op) {
        return null;
    }

private:
    int getInt(Number n) {
        return cast(int)getLong(n);
    }
    long getLong(Number n) {
        long value;
        if(n.type().isReal()) {
            value = cast(long)n.valueStr.to!double;
        } else {
            value = n.valueStr.to!long;
        }
        return value;
    }
    double getDouble(Number n) {
        return n.valueStr.to!double;
    }
}
