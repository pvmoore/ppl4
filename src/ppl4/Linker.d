module ppl4.Linker;

import ppl4.all;

final class Linker {
private:
    LLVMWrapper llvm;
    Writer writer;
    Config config;
    Module mainModule;
    Filename outName;
public:
    this(LLVMWrapper llvm, Writer writer, Config config, Module mainModule) {
        this.llvm = llvm;
        this.writer = writer;
        this.config = config;
        this.mainModule = mainModule;
        this.outName = mainModule.name.toFilename();
    }
    bool link() {
        auto obj = getFilename(".obj");
        auto exe = getFilename(".exe");

        writer.writeOBJ(mainModule, obj);

        auto args = createArgs(obj, exe);

        executeLinker(args, obj);

        return true;
    }
private:
    string getFilename(string ext) {
        auto name = outName.withExtension(ext);
        return config.output.directory.value ~ name.value;
    }
    string[] createArgs(string obj, string exe) {
        auto args = [
            "link",
            "/NOLOGO",
            //"/VERBOSE",
            "/MACHINE:X64",
            "/WX",              /// Treat linker warnings as errors
            "/SUBSYSTEM:" ~ config.subsystem
        ];

        if(config.isDebug) {
            args ~= [
                "/DEBUG:NONE",  /// Don't generate a PDB for now
                "/OPT:NOREF"    /// Don't remove unreferenced functions and data
            ];
        } else {
            args ~= [
                "/RELEASE",
                "/OPT:REF",     /// Remove unreferenced functions and data
                //"/LTCG",        /// Link time code gen
            ];
        }

        args ~= [
            obj,
            "/OUT:" ~ exe
        ];

        args ~= config.getExternalLibs();

        //trace("link command: %s", args);
        return args;
    }
    void executeLinker(string[] args, string obj) {
        import std.process : spawnProcess, wait, Config;

        int returnStatus;
        string errorMsg;
        try{
            auto pid = spawnProcess(args, null, Config.none);
            returnStatus = wait(pid);

        }catch(Exception e) {
            errorMsg     = e.msg;
            returnStatus = -1;
        }

        if(returnStatus!=0) {
            linkError(mainModule, "Linker returned %s: ".format(returnStatus) ~ errorMsg);
        }

        /// Delete the obj file if required
        if(!config.writeOBJ) {
            import std.file : remove;
            remove(obj);
        }
    }
}