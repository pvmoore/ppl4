module ppl4.phases.Writer;

import ppl4.all;
import std.stdio : File;

final class Writer {
private:
    LLVMWrapper llvm;
    Config config;
public:
    this(LLVMWrapper llvm, Config config) {
        this.llvm = llvm;
        this.config = config;

        // Create paths
        if(config.writeTokens)
            config.output.directory.add(Directory("tk")).create();
        if(config.writeIR)
            config.output.directory.add(Directory("ir")).create();
        if(config.writeIR)
            config.output.directory.add(Directory("ir_opt")).create();
        if(config.writeAST)
            config.output.directory.add(Directory("ast")).create();
    }
    void writeTokens(Module mod) {
        if(config.writeTokens) {
            auto path = config.output.directory.add(Directory("tk")).toString();
            auto file = File(path ~ mod.name.toFileName().withExtension(".tk").value, "w");
            file.rawWrite(mod.tokens.toString());
        }
    }
    void writeAST(Module mod) {
        if(config.writeAST) {
            string buf;
            mod.dump(buf);
            auto path = config.output.directory.add(Directory("ast")).toString();
            auto file = File(path ~ mod.name.toFileName().withExtension(".ast").value, "w");
            file.rawWrite(buf);
        }
    }
    void writeLL(Module mod, Directory subdir) {
        if(config.writeIR) {
            auto path = FileNameAndDirectory(
                mod.name.toFileName().withExtension(".ll"),
                mod.config.output.directory.add(subdir));
            mod.llvmValue.writeToFileLL(path.toString());
        }
    }
    bool writeASM(Module mod) {
        if(config.writeASM) {
            auto path = FileNameAndDirectory(
                mod.name.toFileName().withExtension(".asm"),
                config.output.directory);
            if(!llvm.x86Target.writeToFileASM(mod.llvmValue, path.toString())) {
                warn("failed to write ASM %s", path);
                return false;
            }
        }
        return true;
    }
    bool writeOBJ(Module mainModule, string filename) {
        if(!llvm.x86Target.writeToFileOBJ(mainModule.llvmValue, filename)) {
            warn("failed to write OBJ %s", filename);
            return false;
        }
        return true;
    }
}