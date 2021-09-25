module ppl4.version_;

import ppl4.all;

const VERSION = "0.2.0";

/**

Currently working on:
----------------------------------------------------------------------------------------------------
    Changing syntax
    Making everything an Expression
    Change Number to
        - ILiteral/Number
        - ILiteral/Null
        - ILiteral/StructLiteral
        - ILiteral/FunctionLiteral
        - ILiteral/ArrayLiteral

    Struct member access
    Dot
    Constructor
    Changing Cast to As

----------------------------------------------------------------------------------------------------
0.2.0 - Move Node generation to NodeFactory
      - Remove ITarget. Replace with Declaration
      - Refactor Variable, Function, Struct. Split into Declarations and Literals
      - Refactor resolution
      - Change function types to fn(params->returnType)

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

    - use get(n) and set(n, T) instead of [n] indexing
    - Casting. Use "as" or @cast(type, expr) ?
    - Do we need assign/op eg. += since we won't support operator overloading for anything other
      than ==
    - No need for rol or ror
    - Errors need to give a module, line and column

    class(pub a:int
          b:int=3)
    {
        default = fn {
            this.a = 0
            this.b = 3
        }
    }


 */