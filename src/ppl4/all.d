module ppl4.all;

public:

import core.stdc.stdlib : exit;

import std.stdio                : writef, writefln;
import std.format               : format;
import std.datetime.stopwatch   : StopWatch;
import std.range                : array;
import std.path                 : asAbsolutePath, asNormalizedPath, buildNormalizedPath, isAbsolute, stripExtension;
import std.file                 : exists, isDir, mkdirRecurse;
import std.array                : replace;
import std.algorithm.iteration  : map, filter;

import common;
import llvm.all;

import ppl4.Config;
import ppl4.logging;
import ppl4.Compiler;
import ppl4.utils;
import ppl4.version_;

import ppl4.ast.Node;

import ppl4.ast.expr.Expression;
import ppl4.ast.expr.Number;
import ppl4.ast.expr.TypeReference;

import ppl4.ast.stmt.Function;
import ppl4.ast.stmt.Import;
import ppl4.ast.stmt.Module;
import ppl4.ast.stmt.Return;
import ppl4.ast.stmt.Statement;
import ppl4.ast.stmt.Struct;
import ppl4.ast.stmt.Variable;

import ppl4.errors.CompileError;
import ppl4.errors.SyntaxError;

import ppl4.phases.GenState;
import ppl4.phases.ParseState;
import ppl4.phases.ResolveState;

import ppl4.lexing.Lexer;
import ppl4.lexing.Scanner;
import ppl4.lexing.Token;
import ppl4.lexing.TokenKind;

import ppl4.types.Type;
import ppl4.types.BuiltinType;
import ppl4.types.FunctionType;
import ppl4.types.StructType;
import ppl4.types.TypeKind;
import ppl4.types.TypeUtils;
import ppl4.types.UnresolvedType;


/**
 * Represents a filename without directory eg. "myfile.p4"
 */
struct FileName {
    string value;

    this(string value) {
        expect(value !is null);
        expect(!value.contains("/") && !value.contains("\\"));
        this.value = value;
    }
    auto withoutExtension() const {
        return FileName(stripExtension(this.value));
    }
    auto withExtension(string ext) const {
        expect(ext !is null);
        ext = ext[0]=='.' ? ext : "." ~ ext;
        return FileName(stripExtension(this.value) ~ ext);
    }
    ModuleName toModuleName() const {
        return ModuleName(FileName(value.replace("/", ".")));
    }
    string toString() const {
        return value;
    }
}

/**
 * Represents a directory without a filename eg. "/a/b/c/"
 * Backslashes are replaced with forward slashes.
 */
struct Directory {
    string value;

    this(string value) {
        expect(value !is null);
        auto norm = asNormalizedPath(value).array.as!string;
        this.value = norm.replace("\\", "/");
        if(this.value[$-1] != '/') this.value ~= "/";
    }
    bool exists() const {
        return .exists(value);
    }
    void create() {
        mkdirRecurse(value);
    }
    Directory absolute() {
        return Directory(asAbsolutePath(value).array);
    }
    Directory add(string dir) {
        expect(dir !is null);
        return Directory(buildNormalizedPath(value, dir));
    }
    Directory add(Directory dir) {
        return Directory(buildNormalizedPath(value, dir.value));
    }
    string toString() const {
        return value;
    }
}

/**
 * Represents a directory and filename eg. /a/b/c/file.p4
 */
struct FileNameAndDirectory {
    FileName filename;
    Directory directory;

    string toString() const {
        return directory.value ~ filename.value;
    }
}

/**
 *  Represents a module name eg. std.util.List
 */
struct ModuleName {
    string value;

    this(FileName name) {
        this.value = name.withoutExtension().value.replace("/", ".");
    }
    FileName toFileName() const {
        return FileName(value.replace(".", "/") ~ ".p4");
    }

    string toString() const {
        return value;
    }
}