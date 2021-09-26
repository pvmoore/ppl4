module ppl4.ast.NodeFactory;

import ppl4.all;

final class NodeFactory {
private:
    int uids;
public:
    Module mod;

    this(Module mod) {
        this.mod = mod;
        this.uids = 1;
    }

    T make(T)(Token startToken) {
        static assert(!__traits(compiles, new T(mod,true)));
        import std.traits;

        //trace("make %s", T.stringof);

        T instance;

        instance = new T(mod);
        instance.uid = uids++;
        instance.startToken = startToken;
        return instance;
    }

    T make(T)(bool isPublic, Token startToken) {
        static assert(__traits(compiles, new T(mod,true)));
        import std.traits;

        //trace("make %s", T.stringof);

        T instance;

        instance = new T(mod, isPublic);
        instance.uid = uids++;
        instance.startToken = startToken;
        return instance;
    }

    // Type makeBuiltinType(TypeKind kind, int ptrDepth) {
    //     auto t = make!Type(MODULE_TOKEN);
    //     t.kind = kind;
    //     t.ptrDepth = ptrDepth;
    //     return t;
    // }

    // Type makeVoidType() {
    //     return make!Type(MODULE_TOKEN).withKind(TypeKind.VOID);
    // }

    // FnType makeFnType(Type returnType, Type[] params...) {
    //     auto f = make!FnType(MODULE_TOKEN);
    //     f.add(returnType);
    //     foreach(p; params) {
    //         f.add(p);
    //     }
    //     return f;
    // }

    FnDecl makeFunction(string name, bool isPublic, FunctionType type) {
        auto d = make!FnDecl(isPublic, MODULE_TOKEN);
        d.name = name;
        d.type = type;

        auto f = make!FnLiteral(MODULE_TOKEN);
        d.add(f);

        return d;
    }

    Number makeNumber(Type type, string valueStr) {
        auto n = cast(Number)make!Number(MODULE_TOKEN)
            .withType(type);
        n.valueStr = valueStr;
        return n;
    }
}