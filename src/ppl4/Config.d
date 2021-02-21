module ppl4.Config;

import ppl4.all;
import std;

final class Config {
public:
    FileName mainFilename;
    Directory directory;

    this(string directory, string mainFilename) {
        this.directory = Directory(directory);
        this.mainFilename = FileName(mainFilename);

    }
    auto getFullPath(ModuleName name) {
        return FileNameAndDirectory(name.toFileName(), directory);
    }
    // string getFilename(ModuleName name) {
    //     return rootPath ~ name.value.replace(".", "/") ~ ".p4";
    // }
    // string calculateRelativePath(string path) {
    //     // auto a = asNormalizedPath(path)
    //     //             .array.as!string
    //     //             .replace("\\", "/");

    //     return relativePath(path, rootPath);
    // }

    override string toString() {
        string s;
        s ~= format("\nPPL4 %s\n\n", VERSION);
        s ~= format("main file .... %s\n", mainFilename);
        s ~= format("root path .... %s\n", directory);
        return s;
    }
private:
}