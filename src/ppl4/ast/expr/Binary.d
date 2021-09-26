module ppl4.ast.expr.Binary;

import ppl4.all;

final class Binary : Expression {
private:
    Type _type;
    Operator op;
public:
    Expression left() { return first().as!Expression; }
    Expression right() { return last().as!Expression; }
    Type leftType() { return left().type(); }
    Type rightType() { return right().type(); }

    //==============================================================================================
    this(Module mod) {
        super(mod);
        this._type = UNKNOWN_TYPE;
    }

    //=================================================================================== Expression
    override Type type() { return _type; }

    override int precedence() { return precedenceOf(op); }

    //========================================================================================= Node
    override NodeId id() { return NodeId.BINARY; }

    override Binary parse(ParseState state) {
        this.op = toOperator(state); state.next();
        return this;
    }

    /**
     *  1) Resolve _type
     *  2) Cast left and right to _type
     */
    override void resolve(ResolveState state) {

        super.resolve(state);

        if(!isResolved) {
            if(!_type.isResolved()) {
                if(leftType().isResolved() && rightType().isResolved()) {
                    this._type = getBestFit(leftType(), rightType());
                }
            }

            if(_type.isResolved() && castArgs()) {
                setResolved();
            } else {
                setUnresolved();
            }
        }
    }

    override void fold() {
        super.fold();

        if(left().isResolved() && right().isResolved()) {
            // If both sides are Numbers then we can do the calculation now


        }
    }

    override void check() {
        super.check();
    }

    override void generate(GenState state) {

        auto l = left();
        auto r = right();
        auto ltype = leftType();
        auto rtype = rightType();

        l.generate(state);
        auto left	   = state.rhs;
        auto assignVar = state.lhs;

        if(op is Operator.OR || op is Operator.AND) {
            todo("shortcut");
        }

        r.generate(state);
        auto right = state.rhs;

        if(op.isBoolean()) {
            Type cmpType = getBestFit(ltype, rtype);
            //left  = state.castType(left, ltype, cmpType);
            //right = state.castType(right, rtype, cmpType);

            if(op is Operator.EQ) {
                eq(state, cmpType, left, right);
            } else if(op is Operator.NE) {
                neq(state, cmpType, left, right);
            } else if(op is Operator.LT) {
                lt(state, cmpType, left, right);
            } else if(op is Operator.GT) {
                gt(state, cmpType, left, right);
            } else if(op is Operator.LTE) {
                lt_eq(state, cmpType, left, right);
            } else if(op is Operator.GTE) {
                gt_eq(state, cmpType, left, right);
            }
            state.rhs = state.castI1ToI8(state.rhs);

        } else if(isPtrArithmetic(op)) {
            handleShortCircuit(state, left);
        } else {
            //left  = state.castType(left, ltype, _type);
            //right = state.castType(right, rtype, _type);

            if (op==Operator.ADD || op is Operator.ADD_ASSIGN) {
                right = add(state, _type, left, right);
            } else if (op is Operator.SUB || op is Operator.SUB_ASSIGN) {
                right = sub(state, _type, left, right);
            } else if (op is Operator.MUL || op is Operator.MUL_ASSIGN) {
                right = mul(state, _type, left, right);
            } else if (op is Operator.DIV || op is Operator.DIV_ASSIGN) {
                right = div(state, _type, left, right);
            } else if (op is Operator.MOD || op is Operator.MOD_ASSIGN) {
                right = modulus(state, _type, left, right);
            } else if (op is Operator.SHL || op is Operator.SHL_ASSIGN) {
                right = shl(state, left, right);
            } else if (op is Operator.SHR || op is Operator.SHR_ASSIGN) {
                right = shr(state, left, right);
            } else if (op is Operator.USHR || op is Operator.USHR_ASSIGN) {
                right = ushr(state, left, right);
            } else if (op is Operator.BITAND || op is Operator.BITAND_ASSIGN) {
                right = and(state, left, right);
            } else if (op is Operator.BITOR || op is Operator.BITOR_ASSIGN) {
                right = or(state, left, right);
            } else if (op is Operator.BITXOR || op is Operator.BITXOR_ASSIGN) {
                right = xor(state, left, right);
            }
        }

        if(op.isAssign) {
            assign(state, right, assignVar);
        }
    }

    //======================================================================================= Object
    override string toString() {
        return "Binary %s:%s".format(op, _type);
    }
private:
    bool castArgs() {
        expect(_type.isResolved());

        auto lt = leftType();
        auto rt = rightType();
        if(!lt.isResolved() || !rt.isResolved()) return false;

        if(!lt.exactlyMatches(_type)) {
            // assume we can cast otherwise _type would be UNKNOWN
            left().wrapWith(Cast.make(mod, _type));
        }
        if(!rt.exactlyMatches(_type)) {
            // assume we can cast otherwise _type would be UNKNOWN
            right().wrapWith(Cast.make(mod, _type));
        }
        return true;
    }
    /*
	 * Handle the right hand side of a boolean "and" / "or".
	 * In certain cases, the result of the left hand side means we don't
	 * need to evaluate the right hand side at all.
	*/
    void handleShortCircuit(GenState state, LLVMValueRef leftVar) {
        auto rightLabel		 = state.createBlock(this, "right");
        auto afterRightLabel = state.createBlock(this, "after_right");

        bool isOr = op is Operator.OR;

        /// ensure lhs is a bool(i8)
        leftVar = state.castType(leftVar, leftType(), BOOL);

        /// create a temporary result
        auto resultVal = state.builder.alloca(i8Type(), "bool_result");
        state.builder.store(leftVar, resultVal);

        /// do we need to evaluate the right side?
        LLVMValueRef cmpResult;
        if(isOr) {
            cmpResult = state.builder.icmp(LLVMIntPredicate.LLVMIntNE, leftVar, constI8(FALSE));
        } else {
            cmpResult = state.builder.icmp(LLVMIntPredicate.LLVMIntEQ, leftVar, constI8(FALSE));
        }
        state.builder.condBr(cmpResult, afterRightLabel, rightLabel);

        /// evaluate right side
        state.moveToBlock(rightLabel);
        right().generate(state);
        state.rhs = state.castType(state.rhs, rightType(), BOOL);
        state.builder.store(state.rhs, resultVal);
        state.builder.br(afterRightLabel);

        /// after right side
        state.moveToBlock(afterRightLabel);
        state.rhs = state.builder.load(resultVal);
    }
    void eq(GenState state, Type cmpType, LLVMValueRef left, LLVMValueRef right) {
        if(cmpType.isReal()) {
            state.rhs = state.builder.fcmp(LLVMRealPredicate.LLVMRealOEQ, left, right);
        } else {
            state.rhs = state.builder.icmp(LLVMIntPredicate.LLVMIntEQ, left, right);
        }
    }
    void neq(GenState state, Type cmpType, LLVMValueRef left, LLVMValueRef right) {
        if(cmpType.isReal)
            state.rhs = state.builder.fcmp(LLVMRealPredicate.LLVMRealONE, left, right);
        else
            state.rhs =state. builder.icmp(LLVMIntPredicate.LLVMIntNE, left, right);
    }
    void lt(GenState state, Type cmpType, LLVMValueRef left, LLVMValueRef right) {
        if(cmpType.isReal)
            state.rhs = state.builder.fcmp(LLVMRealPredicate.LLVMRealOLT, left, right);
        else {
            state.rhs = state.builder.icmp(LLVMIntPredicate.LLVMIntSLT, left, right);
        }
    }
    void gt(GenState state, Type cmpType, LLVMValueRef left, LLVMValueRef right) {
        if(cmpType.isReal)
            state.rhs = state.builder.fcmp(LLVMRealPredicate.LLVMRealOGT, left, right);
        else {
            state.rhs = state.builder.icmp(LLVMIntPredicate.LLVMIntSGT, left, right);
        }
    }
    void lt_eq(GenState state, Type cmpType, LLVMValueRef left, LLVMValueRef right) {
        if(cmpType.isReal)
            state.rhs = state.builder.fcmp(LLVMRealPredicate.LLVMRealOLE, left, right);
        else {
            state.rhs = state.builder.icmp(LLVMIntPredicate.LLVMIntSLE, left, right);
        }
    }
    void gt_eq(GenState state, Type cmpType, LLVMValueRef left, LLVMValueRef right) {
        if(cmpType.isReal)
            state.rhs = state.builder.fcmp(LLVMRealPredicate.LLVMRealOGE, left, right);
        else {
            state.rhs = state.builder.icmp(LLVMIntPredicate.LLVMIntSGE, left, right);
        }
    }
    void assign(GenState state, LLVMValueRef right, LLVMValueRef assignVar) {
        state.builder.store(right, assignVar);
    }
    auto add(GenState state, Type type, LLVMValueRef left, LLVMValueRef right) {
        auto op = type.isReal() ? LLVMOpcode.LLVMFAdd : LLVMOpcode.LLVMAdd;
        state.rhs = state.builder.binop(op, left, right);
        return state.rhs;
    }
    auto sub(GenState state, Type type, LLVMValueRef left, LLVMValueRef right) {
        auto op = type.isReal() ? LLVMOpcode.LLVMFSub : LLVMOpcode.LLVMSub;
        state.rhs = state.builder.binop(op, left, right);
        return state.rhs;
    }
    auto mul(GenState state, Type type, LLVMValueRef left, LLVMValueRef right) {
        auto op = type.isReal() ? LLVMOpcode.LLVMFMul : LLVMOpcode.LLVMMul;
        state.rhs = state.builder.binop(op, left, right);
        return state.rhs;
    }
    auto div(GenState state, Type type, LLVMValueRef left, LLVMValueRef right) {
        auto op = type.isReal() ? LLVMOpcode.LLVMFDiv : LLVMOpcode.LLVMSDiv;
        state.rhs = state.builder.binop(op, left, right);
        return state.rhs;
    }
    auto modulus(GenState state, Type type, LLVMValueRef left, LLVMValueRef right) {
        auto op = type.isReal() ? LLVMOpcode.LLVMFRem : LLVMOpcode.LLVMSRem;
        state.rhs = state.builder.binop(op, left, right);
        return state.rhs;
    }
    auto shl(GenState state, LLVMValueRef left, LLVMValueRef right) {
        state.rhs = state.builder.binop(LLVMOpcode.LLVMShl, left, right);
        return state.rhs;
    }
    auto shr(GenState state, LLVMValueRef left, LLVMValueRef right) {
        state.rhs = state.builder.binop(LLVMOpcode.LLVMAShr, left, right);
        return state.rhs;
    }
    auto ushr(GenState state, LLVMValueRef left, LLVMValueRef right) {
        state.rhs = state.builder.binop(LLVMOpcode.LLVMLShr, left, right);
        return state.rhs;
    }
    auto and(GenState state, LLVMValueRef left, LLVMValueRef right) {
        state.rhs = state.builder.binop(LLVMOpcode.LLVMAnd, left, right);
        return state.rhs;
    }
    auto or(GenState state, LLVMValueRef left, LLVMValueRef right) {
        state.rhs = state.builder.binop(LLVMOpcode.LLVMOr, left, right);
        return state.rhs;
    }
    auto xor(GenState state, LLVMValueRef left, LLVMValueRef right) {
        state.rhs = state.builder.binop(LLVMOpcode.LLVMXor, left, right);
        return state.rhs;
    }
}