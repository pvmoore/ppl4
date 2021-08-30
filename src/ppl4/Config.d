module ppl4.Config;

import ppl4.all;
import std;

final class Config {
public:
    Filename mainFilename;
    Directory directory;
    Filepath output;
    bool writeTokens = true;
    bool writeAST = true;
    bool writeIR = true;
    bool writeASM = true;
    bool writeOBJ = true;
    bool isDebug = true;
    string subsystem = "console";
    string[] libs;

    string programEntryName() {
        return "console" == subsystem ? "main" : "winMain";
    }

    this(string directory, string mainFilename) {
        this.directory = Directory(directory);
        this.mainFilename = Filename(mainFilename);
        this.output = Filepath(this.directory, this.mainFilename.withExtension("exe"));
    }
    auto withOutput(string directory) {
        this.output = Filepath(Directory(directory), this.mainFilename.withExtension("exe"));
        return this;
    }
    string[] getExternalLibs() {
        if(isDebug) {
            string[] dynamicRuntime = [
                "msvcrtd.lib",
                "ucrtd.lib",
                "vcruntimed.lib"
            ];
            //string[] staticRuntime = [
            //    "libcmt.lib",
            //    "libucrt.lib",
            //    "libvcruntime.lib"
            //];
            return dynamicRuntime ~ libs;
        }
        string[] dynamicRuntime = [
            "msvcrt.lib",
            "ucrt.lib",
            "vcruntime.lib"
        ];
        //string[] staticRuntime = [
        //    "libcmt.lib",
        //    "libucrt.lib",
        //    "libvcruntime.lib"
        //];
        return dynamicRuntime ~ libs;
    }
    Filepath getFullPath(ModuleName name) {
        return Filepath(directory, name.toFilename());
    }

    override string toString() {
        string s;
        s ~= format("\nPPL4 %s\n\n", VERSION);
        s ~= format("main file .... %s\n", mainFilename);
        s ~= format("root path .... %s\n", directory);
        s ~= format("output dir ... %s\n", output.directory);
        s ~= format("target file .. %s\n", output.filename);
        return s;
    }
private:
}