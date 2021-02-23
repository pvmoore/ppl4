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

        if(type().isBool()) {
            i = number.valueStr.to!long == 0 ? FALSE : TRUE;
        } else if(type().isInteger()) {
            i = number.valueStr.to!long;
        } else if(type().isReal()) {
            f = number.valueStr.to!double;
        } else assert(false, "How did we get here? type is %s".format(type()));

    }
    Type type() { return number.type(); }
    bool getBool() { return getLong() != FALSE; }
    int getInt() { return cast(int)getLong(); }
    long getLong() { if(type.isReal()) return cast(long)f; return i; }
    double getDouble() { if(!type.isReal()) return cast(double)i; return f; }
}