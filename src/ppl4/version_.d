module ppl4.version_;

import ppl4.all;

const VERSION = "0.1.5";

/**

Currently working on:
----------------------------------------------------------------------------------------------------
    Changing syntax
    Making everything an Expression

    Struct member access
    Dot
    Constructor
    Changing CastExpression to AsExpression

----------------------------------------------------------------------------------------------------
0.1.5 -

0.1.4 - Require brackets around function parameters unless there are no parameters
      - Use 'pub' instead of '+' to indicate public types
      - Rename TypeReference to TypeExpression
      - Don't use ref. Use '*' to indicate a pointer

0.1.3 - Make Module a Node rather than a Statement
0.1.2 - Use Filename, Directory and Filepath from common
      - Move some code from Statement to Node
0.1.1 - Initial generation phase
0.1.0 - Initial resolution phase
0.0.1 - Initial commit to Github
----------------------------------------------------------------------------------------------------
 */

 /**
    TODO
    ###########################

    - Use NodeFactory to abstract away Node creation
    - use get() and set() instead of [] indexing
    - Casting. Use "as" or @cast(type, expr) ?
    - Do we need assign/op eg. += since we won't support operator overloading for anything other
      than ==
    - No need for rol or ror
    - Errors need to give a module, line and column

    class {
        a:int
        b:int

        init = fn(a, b) {
            // automatically sets this.a = a; this.b = b
        }
        init = fn(a, b:int) {
            // this.a = a
            // b is local to this function
        }

    }


 */