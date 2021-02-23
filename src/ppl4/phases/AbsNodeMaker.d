module ppl4.phases.AbsNodeMaker;

import ppl4.all;

abstract class AbsNodeMaker {
protected:
    int uids;
public:
    Module mod;

    this(Module mod) {
        this.mod = mod;
        this.uids = 1;
    }

    abstract Token getStartToken();

    T make(T)(bool isPublic = true) {
        import std.traits;

        //trace("make %s", T.stringof);

        T instance;

        static if(is(T==Function) || is(T==Variable) || is(T==Struct)) {
            instance = new T(mod, isPublic);
        } else {
            instance = new T(mod);
        }
        instance.uid = uids++;
        instance.startToken = getStartToken();
        return instance;
    }
}