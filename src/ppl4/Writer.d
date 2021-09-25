module ppl4.Writer;

import ppl4.all;
import std.stdio : File;
import std.file  : rmdirRecurse;

final class Writer {
private:
    LLVMWrapper llvm;
    Config config;
public:
    this(LLVMWrapper llvm, Config config) {
        this.llvm = llvm;
        this.config = config;

        // Create paths
        if(config.writeTokens) {
            auto dir = config.output.directory.add(Directory("tk"));
            rmdirRecurse(dir.value);
            dir.create();
        }
        if(config.writeIR) {
            auto dir = config.output.directory.add(Directory("ir"));
            rmdirRecurse(dir.value);
            dir.create();
        }
        if(config.writeIR) {
            auto dir = config.output.directory.add(Directory("ir_opt"));
            rmdirRecurse(dir.value);
            dir.create();
        }
        if(config.writeAST) {
            auto dir = config.output.directory.add(Directory("ast"));
            rmdirRecurse(dir.value);
            dir.create();
        }
    }
    void writeTokens(Module mod) {
        if(config.writeTokens) {
            auto path = config.output.directory.add(Directory("tk")).toString();
            auto file = File(path ~ mod.name.toFilename().withExtension(".tk").value, "w");
            file.rawWrite(mod.tokens.toString());
        }
    }
    void writeAST(Module mod, string suffix) {
        if(config.writeAST) {
            string buf;
            mod.dump(buf);
            auto dir = config.output.directory.add(Directory("ast")).toString();
            auto file = File(dir ~ mod.name.toFilename().add(suffix).withExtension(".ast").value, "w");
            file.rawWrite(buf);
        }
    }
    void writeLL(Module mod, Directory subdir) {
        if(config.writeIR) {
            auto path = Filepath(
                mod.config.output.directory.add(subdir),
                mod.name.toFilename().withExtension(".ll"));
            mod.llvmValue.writeToFileLL(path.toString());
        }
    }
    bool writeASM(Module mod) {
        if(config.writeASM) {
            auto path = Filepath(
                config.output.directory,
                mod.name.toFilename().withExtension(".asm"));
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