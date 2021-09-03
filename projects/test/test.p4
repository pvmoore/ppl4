

/* multiline comment */

/* 2
 */

// Initialise global variables here
// Created if not already existing
init = fn {

}

putchar = extern fn(a:int) : int

// t = fn() throws {}

g = 0

// name = Type
// Int = int
// +e = enum { A = 1, B = 2 }

// name = Type
// public struct declaration and definition
pub Animal = struct {
    // public properties can be set in the constructor
    // eg. Animal(a:0, b:true)

    pub a : int = 1       // default if no value passed
    pub b : bool
    c   : float
    d   : double
    e   : int*

    //fp : fn(int):int // = (a) { return a+1 }

    pub sayHello = fn() {}
    sayGoodbye = fn {}

    // Implicit constructor if not manually added
    init = fn { // implied param: this:Animal*
        // set default or supplied property values
    }

    index = fn(i:int) : void {}
    //equals = fn other:Animal* {}
}

//A = Animal()

// as int

// public function declaration and definition
pub main = fn {
    a = byte(0)
    n = 0 + 1 + 2 * 3
    b = true
    n := 1
    c:int
    d:Animal
    e:int*
    f:int* = null

    //g = Animal()


    //assert (1 + 2 * 3) / 4 - 5

    result = add(4,a)

    return (1 + 2 * 3) / 4 - 5
}

add = fn(a:int, b:int) {
    return a + b
}

test = fn {
    a = byte(1) + 2
}

test2 = fn(a:Animal) {

}

// need to do a scan for public declarations after lexing

// import std.core                                 // Import (while module)
// Math       = import std.math                    // Import (while module with name)
// ofNullable = import std.optional.ofNullable     // Import (single Function)
// List       = import std.list.List               // Import (single class)
// float3     = import std.vector3.float3          // Import (single struct)



// fn process {
//     s1 = Animal(a:0, b:true, c: 3.14, d:8.1)
//     s2 = Animal(0, true, 3.14, 8.1)
//     a = int(0)
//     b = float(0)
//     c = int(1)
//}
    // d = fn { return 0 }
    // e = fn a:int { return a }

    // list.stream()
    //     .map fn i {
    //         return 3+i
    //     }
    //     .map fn a:int { return 3+i }
    //     .each fn i { log(i) }

//}
