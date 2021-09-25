module ppl4.ast.stmt.decl.StructDecl;

import ppl4.all;

/**
 *  StructDecl
 *      StructLiteral
 */
final class StructDecl : Declaration {
private:

public:
    StructLiteral getStructLiteral() { return expr().as!StructLiteral; }

    //==============================================================================================
    this(Module mod, bool isPublic) {
        super(mod, isPublic);
    }

    //========================================================================================= Node
    override NodeId id() { return NodeId.STRUCT_DECL; }

    override Declaration parse(ParseState state) {
        return super.parse(state);
    }

    override void resolve(ResolveState state) {
        resolveChildren(state);

        // if(!type.isResolved() && expr().isA!StructLiteral && getStructLiteral().isResolved()) {
        //     this.type = getStructLiteral().type();
        // }
        super.resolve(state);
    }

    override void check() {
        super.check();
    }

    override void generate(GenState state) {
        super.generate(state);
    }

    //======================================================================================= Object
    override string toString() {
        return "StructDecl%s %s:%s %s".format(
            isPublic ? "(pub)":"",
            name, type, isResolved() ? "✅" : "❌");
    }

    //==============================================================================================
    void generateDeclaration() {
        getStructLiteral().generateDeclaration();
    }
private:
}