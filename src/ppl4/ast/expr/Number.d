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
    Value value;

    this(Module mod) {
        super(mod);
        this._type = UNKNOWN_TYPE;
    }

    @Implements("Node")
    override NodeId id() { return NodeId.NUMBER; }

    @Implements("Expression")
    override Type type() { return _type; }

    @Implements("Statement")
    override Number parse(ParseState state) {
        this.valueStr = state.text(); state.next();
        return this;
    }

    @Implements("Statement")
    override void resolve(ResolveState state) {
        if(!isResolved) {
            auto t = parseNumberLiteral(valueStr);
            if(t[0].isResolved()) {
                this._type    = t[0];
                this.valueStr = t[1];
                this.isResolved = true;
                this.value = new Value(this);
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
        LLVMValueRef v;
        switch(_type.kind) with(TypeKind) {
            case BOOL:   v = constI8(value.getInt()); break;
            case BYTE:   v = constI8(value.getInt()); break;
            case SHORT:  v = constI16(value.getInt()); break;
            case INT:    v = constI32(value.getInt()); break;
            case LONG:   v = constI64(value.getLong()); break;
            case FLOAT:  v = constF32(value.getDouble()); break;
            case DOUBLE: v = constF64(value.getDouble()); break;
            default:
                expect(false, "Invalid type %s".format(_type));
                break;
        }
        state.rhs = v;
    }

    override string toString() {
        return "Number %s:%s".format(valueStr, _type);
    }
private:
    From!"std.typecons".Tuple!(Type,string) parseNumberLiteral(string v) {

        auto t = tuple(UNKNOWN_TYPE, v);
        assert(v.length>0);

        bool neg = (v[0]=='-');
        if(neg) v = v[1..$];

        if(v.length==1) {
            if(isDigit(v[0])) t[0] = new BuiltinType(TypeKind.INT);
        } else if(v=="true") {
            t[0] = BOOL;
            t[1] = "%s".format(TRUE);
        } else if(v=="false") {
            t[0] = BOOL;
            t[1] = "%s".format(FALSE);
        } else if(v[0]=='\'') {
            long l = parseCharLiteral(v[1..$-1]);
            t[0] = INT;
            t[1] = "%s".format(l);
        } else if(v.endsWith("L")) {
            t[0] = new BuiltinType(TypeKind.LONG);
            t[1] = v[0..$-1];
        } else if(v[0..2]=="0x") {
            v = v[2..$];
            if(v.length>0 && isHexDigits(v)) {
                long l = hexToLong(v);
                t[0] = new BuiltinType(getTypeOfLong(l));
                t[1] = "%s".format(l);
            }
        } else if(v[0..2]=="0b") {
            v = v[2..$];
            if (v.length>0 && isBinaryDigits(v)) {
                long l = binaryToLong(v);
                t[0] = new BuiltinType(getTypeOfLong(l));
                t[1] = "%s".format(l);
            }
        // } else if(v.endsWith("h")) {
        //     string s = v[0..$-1];
        //     if (s.count('.')<2 &&
        //     s.removeChars('.').isDigits)
        //     {
        //         t[0] = new BuiltinType(Type.HALF);
        //         t[1] = s;
        //     }
        } else if(v.endsWith("d")) {
            string s = v[0..$-1];
            if(s.count('.')<2 && isDigits(s.removeChars('.'))) {
                t[0] = new BuiltinType(TypeKind.DOUBLE);
                t[1] = s;
            }
        } else if(v.count('.')==1) {        /// assume float if no type specified
            if(isDigits(v.removeChars('.'))) {
                t[0] = new BuiltinType(TypeKind.FLOAT);
            }
        } else if(isDigits(v)) {
            long l = From!"std.conv".to!long(t[1]);
            t[0] = new BuiltinType(getTypeOfLong(l));
        } else {
            // not a number literal
        }
        return t;
    }
    bool isDigit(char c) {
        return c>='0' && c<='9';
    }
    bool isDigits(string s) {
        foreach(c; s) if(!isDigit(c)) return false;
        return true;
    }
    bool isHexDigits(string s) {
        foreach(c; s.toLower) {
            if(!isDigit(c) && c!='_' && (c<'a' || c>'f')) return false;
        }
        return true;
    }
    bool isBinaryDigits(string s) {
        foreach(c; s) if(c!='0' && c!='1' && c!='_') return false;
        return true;
    }
    bool isInt(long l) {
        return l >= int.min && l <= int.max;
    }
    long hexToLong(string hex) {
        long total;
        foreach(c; hex.toLower) {
            if(c=='_') continue;
            int n;
            if(c>='0' && c<='9') n = c-'0';
            else n = (c-'a')+10;
            total <<= 4;
            total |= n;
        }
        return total;
    }
    long binaryToLong(string binary) {
        long total;
        foreach(c; binary) {
            if(c=='_') continue;
            int n = c-'0';
            total <<= 1;
            total |= n;
        }
        return total;
    }
    TypeKind getTypeOfLong(long l) {
        //if(isByte(l)) return Type.BYTE;
        //if(isShort(l)) return Type.SHORT;
        if(isInt(l)) return TypeKind.INT;
        return TypeKind.LONG;
    }
    int parseCharLiteral(string s) {
        int pos;
        return parseCharLiteral(s, &pos);
    }
    /// f  \n  \x12 \u1234 \U12345678
    /// pos is set to the final char that was consumed
    int parseCharLiteral(string s, int* pos) {
        if(s[0]=='\\') {
            switch(s[1]) {
                case '0' : *pos=1; return 0;
                case 'b' : *pos=1; return 8;
                case 't' : *pos=1; return 9;
                case 'n' : *pos=1; return 10;
                case 'f' : *pos=1; return 12;
                case 'r' : *pos=1; return 13;
                case '\"': *pos=1; return 34;
                case '\'': *pos=1; return 39;
                case '\\': *pos=1; return 92;
                case 'x' : *pos=3; return cast(uint)hexToLong(s[2..4]);
                case 'u' : *pos=5; return cast(uint)hexToLong(s[2..6]);
                //case 'U' : *pos=9; return cast(ulong)hexToLong(s[2..10]);
                default: return -1;
            }
        }
        *pos = 0;
        return s[0];
    }
}