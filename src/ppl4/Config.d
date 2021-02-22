module ppl4.Config;

import ppl4.all;
import std;

final class Config {
public:
    FileName mainFilename;
    Directory directory;
    FileNameAndDirectory output;
    bool writeIR = true;
    bool writeASM = true;
    bool writeOBJ = true;
    bool isDebug = true;
    string subsystem = "console";

    this(string directory, string mainFilename) {
        this.directory = Directory(directory);
        this.mainFilename = FileName(mainFilename);
        this.output = FileNameAndDirectory(
            this.mainFilename.withExtension("exe"),
            this.directory);
    }
    auto withOutput(string directory) {
        this.output = FileNameAndDirectory(
            this.mainFilename.withExtension("exe"),
            Directory(directory));
        return this;
    }
    string[] getExternalLibs() {
        return null;
    }
    auto getFullPath(ModuleName name) {
        return FileNameAndDirectory(name.toFileName(), directory);
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