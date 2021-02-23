module ppl4.phases.Writer;

import ppl4.all;

final class Writer {
private:
    LLVMWrapper llvm;
public:
    this(LLVMWrapper llvm) {
        this.llvm = llvm;
    }
    void writeLL(Module mod, Directory subdir) {
        if(mod.config.writeIR) {
            auto path = FileNameAndDirectory(
                mod.name.toFileName().withExtension(".ll"),
                mod.config.output.directory.add(subdir));
            info("writeLL %s", path);
            if(!path.directory.exists()) path.directory.create();
            mod.llvmValue.writeToFileLL(path.toString());
        }
    }
    bool writeASM(Module mod) {
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
    bool writeOBJ(Module mainModule, string filename) {
        //trace("writeOBJ %s", filename);
        if(!llvm.x86Target.writeToFileOBJ(mainModule.llvmValue, filename)) {
            warn("failed to write OBJ %s", filename);
            return false;
        }
        return true;
    }
}