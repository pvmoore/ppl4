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
import std.typecons             : tuple;
import std.string               : indexOf, lastIndexOf, toLower;
import std.algorithm.iteration  : map, filter, sum, filter;
import std.algorithm.searching  : count;
import std.algorithm.sorting    : sort;

import common;
import llvm.all;

import ppl4.Config;
import ppl4.logging;
import ppl4.Compiler;
import ppl4.ITarget;
import ppl4.Operator;
import ppl4.utils;
import ppl4.version_;

import ppl4.ast.Module;
import ppl4.ast.Node;

import ppl4.ast.expr.Assert;
import ppl4.ast.expr.AtFunc;
import ppl4.ast.expr.Binary;
import ppl4.ast.expr.Call;
import ppl4.ast.expr.Cast;
import ppl4.ast.expr.Expression;
import ppl4.ast.expr.Identifier;
import ppl4.ast.expr.Null;
import ppl4.ast.expr.Number;
import ppl4.ast.expr.Parens;
import ppl4.ast.expr.TypeReference;

import ppl4.ast.stmt.Function;
import ppl4.ast.stmt.Import;
import ppl4.ast.stmt.Return;
import ppl4.ast.stmt.Statement;
import ppl4.ast.stmt.Struct;
import ppl4.ast.stmt.Variable;

import ppl4.errors.CompilationError;
import ppl4.errors.SyntaxError;
import ppl4.errors.VerifyError;

import ppl4.eval.Value;

import ppl4.lexing.Lexer;
import ppl4.lexing.Scanner;
import ppl4.lexing.Token;
import ppl4.lexing.TokenKind;

import ppl4.phases.AbsNodeMaker;
import ppl4.phases.GenState;
import ppl4.phases.Linker;
import ppl4.phases.ParseState;
import ppl4.phases.Resolver;
import ppl4.phases.ResolveState;
import ppl4.phases.Writer;

import ppl4.types.Type;
import ppl4.types.BuiltinType;
import ppl4.types.FunctionType;
import ppl4.types.StructType;
import ppl4.types.TypeKind;
import ppl4.types.TypeUtils;
import ppl4.types.UnresolvedType;

enum TRUE  = -1;
enum FALSE = 0;

/**
 *  Represents a module name eg. std.util.List
 */
struct ModuleName {
    const string value;

    this(Filename name) {
        this.value = name.withoutExtension().value.replace("/", ".");
    }
    static ModuleName from(Filename filename) {
        return ModuleName(Filename(filename.value.replace("/", ".")));
    }
    //------------------------------------------------------------------------
    Filename toFilename() const {
        return Filename(value.replace(".", "/") ~ ".p4");
    }

    string toString() const {
        return value;
    }
}