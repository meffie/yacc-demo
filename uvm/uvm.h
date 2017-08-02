/*
 * demo bytecodes
 */

enum uvm_opcode {
    OP_NOP = 0,

    /* stack */
    OP_PUSH, /* <value> */
    OP_POP,
    OP_SWAP,
    OP_DUP,

    /* math */
    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_DIV,
    OP_MOD,

    /* logic */
    OP_AND,
    OP_OR,
    OP_NOT,

    /* compare */
    OP_EQ,
    OP_NE,
    OP_LT,
    OP_LE,
    OP_GT,
    OP_GE,

    /* control flow */
    OP_JUMP,   /* <address> */
    OP_BRANCH, /* <address> */
    OP_RETURN,
    OP_HALT,

    /* i/o */
    OP_READ,
    OP_WRITE,
    OP_PRINT,

    NUMOPS,
};
