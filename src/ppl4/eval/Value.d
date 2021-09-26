module ppl4.eval.Value;

import ppl4.all;
import std.conv : to;

final class Value {
private:
    union {
        double f;
        long i;
    }
    Number number;
public:
    this(Number number) {
        this.number = number;
        expect(number.isResolved);

        if(kind() == TypeKind.BOOL) {
            i = number.valueStr.to!long == 0 ? FALSE : TRUE;
        } else if(kind().isInteger()) {
            i = number.valueStr.to!long;
        } else if(kind().isReal()) {
            f = number.valueStr.to!double;
        } else assert(false, "How did we get here? type is %s".format(type()));

    }
    Type type() { return number.type(); }
    TypeKind kind() { return type().kind; }
    bool getBool() { return getLong() != FALSE; }
    int getInt() { return cast(int)getLong(); }
    long getLong() { if(kind().isReal()) return cast(long)f; return i; }
    double getDouble() { if(!kind().isReal()) return cast(double)i; return f; }
    string getString() { return type().isReal() ? "%f".format(getDouble()) : "%s".format(getLong()); }

    /**
     *
     */
    // Number applyBinary(Type resultType, Operator op, Value right) {
    //     return null;
    // }

}