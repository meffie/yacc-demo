/*
 * demo bytecodes
 */

enum uvm_opcode {
    OP_NOP = 0,

    /* debug */
    OP_TON,
    OP_TOFF,

    /* stack */
    OP_PUSH, /* <value> */
    OP_POP,
    OP_PEEK, /* <offset> */
    OP_POKE, /* <offset> */
    OP_IPEEK, /* <offset> */
    OP_IPOKE, /* <offset> */
    OP_DUP,
    OP_SWAP,

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
    OP_MARK,
    OP_CALL,
    OP_RETURN,
    OP_UNMARK,
    OP_HALT,

    /* i/o */
    OP_READ,
    OP_WRITE,
    OP_PRINT,

    NUMOPS,
};
