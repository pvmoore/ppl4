module ppl4.phases.GenState;

import ppl4.all;

final class GenState {
public:
    Module mod;
    LLVMWrapper llvm;
    LLVMBuilder builder;
    LLVMValueRef lhs;
    LLVMValueRef rhs;
    LLVMBasicBlockRef currentBlock;

    this(LLVMWrapper llvm, Module mod) {
        this.llvm = llvm;
        this.builder = llvm.builder;
        this.mod = mod;
    }
    bool success() {
        return true;
    }
    void writeLL(Directory subdir) {
        if(mod.config.writeIR) {
            auto path = FileNameAndDirectory(
                mod.name.toFileName().withExtension(".ll"),
                mod.config.output.directory.add(subdir));
            info("writeLL %s", path);
            mod.llvmValue.writeToFileLL(path.toString());
        }
    }
    bool writeASM() {
        if(mod.config.writeASM) {
            auto path = FileNameAndDirectory(
                mod.name.toFileName().withExtension(".asm"),
                mod.config.output.directory);
            info("writeASM %s", path);
            if(!llvm.x86Target.writeToFileASM(mod.llvmValue, path.toString())) {
                warn("failed to write ASM %s", path);
                return false;
            }
        }
        return true;
    }
    bool verify() {
        trace("Verifying %s", mod.name);
        if(!mod.llvmValue.verify()) {
            warn("=======================================");
            mod.llvmValue.dump();
            warn("=======================================");
            warn("module %s is invalid", mod.name);
            return false;
        }
        trace("finished verifying");
        return true;
    }
    void moveToBlock(LLVMBasicBlockRef label) {
        builder.positionAtEndOf(label);
        currentBlock = label;
    }
    LLVMValueRef castType(LLVMValueRef v, Type from, Type to, string name=null) {
        if(from.exactlyMatches(to)) return v;
        //dd("cast", from, to);
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
            error("!!!", from.kind, mod.name);
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