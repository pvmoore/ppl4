module ppl4.ITarget;

import ppl4.all;

interface ITarget {
    bool isResolved();
    Type type();
    bool isMember();    // of a struct/class
    LLVMValueRef getLlvmValue();
}