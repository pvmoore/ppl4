module ppl4.version_;

import ppl4.all;

const VERSION = "0.1.2";

/**

Currently working on:
    struct member access
    Dot
    Constructor
    changing CastExpression to AsExpression
    Constructor



0.1.2 - Use Filename, Directory and Filepath from common
0.1.1 - Initial generation phase
0.1.0 - Initial resolution phase
0.0.1 - Initial commit to Github

 */

 /**
    TODO
    ###########################

    - use get() and set() instead of [] indexing
    - Casting. Use "as" or @cast(type, expr) ?
    - Do we need assign/op eg. += since we won't support operator overloading for anything other
      than ==
    - No need for rol or ror

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