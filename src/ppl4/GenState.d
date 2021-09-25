module ppl4.GenState;

import ppl4.all;

final class GenState {
public:
    Module mod;
    LLVMWrapper llvm;
    LLVMPassManager passManager;
    LLVMBuilder builder;
    Writer writer;
    LLVMValueRef lhs;
    LLVMValueRef rhs;
    LLVMBasicBlockRef currentBlock;

    this(LLVMWrapper llvm, Writer writer, Module mod) {
        this.llvm = llvm;
        this.writer = writer;
        this.builder = llvm.builder;
        this.mod = mod;
        this.passManager = llvm.passManager;

        passManager.addPassesO3();
    }
    bool success() {
        return true;
    }
    void verify() {
        //trace("Verifying %s", mod.name);
        if(!mod.llvmValue.verify()) {
            warn("=======================================");
            mod.llvmValue.dump();
            warn("=======================================");
            warn("module %s is invalid", mod.name);
            throw new Exception("Verify error");
        }
    }
    void writeLL(Directory subdir) {
        writer.writeLL(mod, subdir);
    }
    void optimise() {
        passManager.runOnModule(mod.llvmValue);
    }
    LLVMBasicBlockRef createBlock(Statement n, string name) {
        auto func = n.ancestor!FnLiteral();
        assert(func);
        return func.llvmValue.appendBasicBlock(name);
    }
    void moveToBlock(LLVMBasicBlockRef label) {
        builder.positionAtEndOf(label);
        currentBlock = label;
    }
    LLVMValueRef castI1ToI8(LLVMValueRef v) {
        if(v.isI1) {
            return builder.sext(v, i8Type());
        }
        return v;
    }
    LLVMValueRef castType(LLVMValueRef v, Type from, Type to, string name=null) {
        if(from.exactlyMatches(to)) return v;
        //trace("cast %s -> %s", from, to);

        /// cast to different pointer type
        if(from.isPtr() && to.isPtr()) {
            rhs = builder.bitcast(v, to.getLLVMType(), name);
            return rhs;
        }
        if(from.isPtr && to.isInteger) {
            rhs = builder.ptrToInt(v, to.getLLVMType(), name);
            return rhs;
        }
        if(from.isInteger && to.isPtr) {
            rhs = builder.intToPtr(v, to.getLLVMType(), name);
            return rhs;
        }
        /// real->int or int->real
        if(from.isReal != to.isReal) {
            if(!from.isReal) {
                /// int->real
                rhs = builder.sitofp(v, to.getLLVMType(), name);
            } else {
                /// real->int
                rhs = builder.fptosi(v, to.getLLVMType(), name);
            }
            return rhs;
        }
        if(from.kind==TypeKind.UNKNOWN) {
            expect(false, "!!! %s %s".format(from.kind, mod.name));
        }
        /// widen or truncate
        if(from.size < to.size) {
            /// widen
            if(from.isReal) {
                rhs = builder.fpext(v, to.getLLVMType, name);
            } else {
                rhs = builder.sext(v, to.getLLVMType, name);
            }
        } else if(from.size > to.size) {
            /// truncate
            if(from.isReal) {
                rhs = builder.fptrunc(v, to.getLLVMType, name);
            } else {
                rhs = builder.trunc(v, to.getLLVMType, name);
            }
        } else {
            /// Size is the same
            //assert(from.isTuple, "castType size is the same - from %s to %s".format(from, to));
            //assert(to.isTuple);
            assert(false, "we shouldn't get here");
        }
        return rhs;
    }
}