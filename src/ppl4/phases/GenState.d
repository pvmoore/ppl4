module ppl4.phases.GenState;

import ppl4.all;

final class GenState {
public:
    Module mod;
    LLVMWrapper llvm;
    LLVMBuilder builder;
    LLVMValueRef lhs;
    LLVMValueRef rhs;

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
}