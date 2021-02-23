

// comment

/* multiline comment */

/* 2
 */

putchar = extern fn(a:int) : int

// t = fn() throws {}

// name = Type
// Int = int
// +e = enum { A = 1, B = 2 }

// name = Type
// public struct declaration and definition
+ Animal = struct {
    // public properties can be set in the constructor
    // eg. Animal(a:0, b:true)

    + a : int = 1       // default if no value passed
    + b : bool
    c   : float
    d   : double
    e   : ref int
    //fp : fn(int):int // = (a) { return a+1 }

    +sayHello = fn {}
    sayGoodbye = fn() {}

    make = fn() { // do something after defaults have been set
    }

    index = fn(i:int):void {}
    //equals = fn(Animal other) {}
}

// public function declaration and definition
+ main = fn {
     //a = 0
     //a := 1
    return 0
}

// need to do a scan for public declarations after lexing

// import std.core                                 // ModuleImport (while module)
// Math       = import std.math                    // ModuleImport (while module with name)
// ofNullable = import std.optional.ofNullable     // ModuleImport (single Function)
// List       = import std.list.List               // ModuleImport (single class)
// float3     = import std.vector3.float3          // ModuleImport (single struct)


// fn add(int a, int b) {
//     return a+b
//}
// fn process {
//     s1 = Animal(a:0, b:true, c: 3.14, d:8.1)
//     s2 = Animal(0, true, 3.14, 8.1)
//     a = int 0
//     b = float 0
//     c = int 1
//}
    // d = () { return 0 }
    // e = fn(int a) { return a }

    // list.stream()
    //     .map fn(i) {
    //         return 3+i
    //     }
    //     .map fn(int a) { return 3+i }
    //     .each fn(i) { log(i) }

//}
