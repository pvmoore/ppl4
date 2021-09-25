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
import std.algorithm.searching  : count, any;
import std.algorithm.sorting    : sort;

import common;
import llvm.all;

import ppl4.Config;
import ppl4.Compiler;
import ppl4.GenState;
import ppl4.Linker;
import ppl4.Logging;
import ppl4.Operator;
import ppl4.ParseState;
import ppl4.Resolver;
import ppl4.ResolveState;
import ppl4.utils;
import ppl4.version_;
import ppl4.Writer;

import ppl4.ast.Module;
import ppl4.ast.Node;
import ppl4.ast.NodeFactory;

import ppl4.ast.expr._Expression;
import ppl4.ast.expr.Assert;
import ppl4.ast.expr.AtFunc;
import ppl4.ast.expr.Binary;
import ppl4.ast.expr.Call;
import ppl4.ast.expr.Cast;
import ppl4.ast.expr.Identifier;
import ppl4.ast.expr.Parens;

import ppl4.ast.expr.lit._Literal;
import ppl4.ast.expr.lit.FnLiteral;
import ppl4.ast.expr.lit.Null;
import ppl4.ast.expr.lit.Number;
import ppl4.ast.expr.lit.StructLiteral;

import ppl4.ast.expr.type.TypeExpression;

import ppl4.ast.stmt._Statement;
import ppl4.ast.stmt.Import;
import ppl4.ast.stmt.Return;

import ppl4.ast.stmt.decl.Declaration;
import ppl4.ast.stmt.decl.ExternFnDecl;
import ppl4.ast.stmt.decl.FnDecl;
import ppl4.ast.stmt.decl.StructDecl;
import ppl4.ast.stmt.decl.VarDecl;

import ppl4.errors.CompilationError;
import ppl4.errors.ResolutionError;
import ppl4.errors.SemanticError;

import ppl4.eval.Value;

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

    bool opEquals(const ModuleName other) const {
        return this.value == other.value;
    }
    size_t toHash() const @safe pure nothrow {
        return value.hashOf();
    }

    string toString() const {
        return value;
    }
}
