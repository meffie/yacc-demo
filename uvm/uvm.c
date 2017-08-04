/*
 * uvm - mircro virtual machine
 *
 * This is an elementary opcode interpreter for demonstration purposes. It is a
 * stack based opcode interpreter similar to Wirth's p-code interpreter.
 *
 * Features
 * - stack based
 * - variable width instructions
 * - elementary i/o opcodes for demos
 * - conditional jump support for logic and loops
 * - load/store elements below the top of the stack
 * - indirect load/store for array support
 * - basic opcode and stack tracing with --trace
 *
 * Limitations
 * - 32 bit integer types only
 * - no stack frame support
 * - no heap support
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <arpa/inet.h>
#include "uvm.h"

int trace = 0; /* debugtracing */

/* opcode table */
void (*optab[NUMOPS])(void);
char *opname[NUMOPS]; /* for tracing */

/* code buffer */
char *program = NULL;
int program_size = 0;

/* stack buffer */
int *stack = NULL;
int stack_size = 0;

/* registers */
int pc = 0;  /* program counter */
int sp = -1; /* stack pointer */

#define push(x) stack[++sp]=(x)
#define pop()   stack[sp--]

/* fetch next argument */
int fetch(void)
{
    int arg;
    memcpy(&arg, &program[pc], sizeof(uint32_t));
    pc += sizeof(uint32_t);
    return ntohl(arg);
}

/* opcodes */
void op_nop(void)    { ; }
void op_ton(void)    { trace = 1; }
void op_toff(void)   { trace = 0; }
void op_push(void)   { int arg = fetch();            push(arg); }
void op_pop(void)    { sp--; }
void op_peek(void)   { int o = fetch();              push(stack[o]); }
void op_poke(void)   { int o = fetch();              stack[o] = pop(); }
void op_ipeek(void)  { int o = fetch() + pop();      push(stack[o]); }
void op_ipoke(void)  { int o = fetch() + pop();      stack[o] = pop(); }
void op_dup(void)    { int a = pop();                push(a); push(a); }
void op_swap(void)   { int a = pop(); int b = pop(); push(a); push(b); }
void op_add(void)    { int a = pop(); int b = pop(); push(b + a); }
void op_sub(void)    { int a = pop(); int b = pop(); push(b - a); }
void op_mul(void)    { int a = pop(); int b = pop(); push(b * a); }
void op_div(void)    { int a = pop(); int b = pop(); push(b / a); }
void op_mod(void)    { int a = pop(); int b = pop(); push(b % a); }
void op_and(void)    { int a = pop(); int b = pop(); push(b && a); }
void op_or(void)     { int a = pop(); int b = pop(); push(b || a); }
void op_not(void)    { int a = pop();                push(!a); }
void op_eq(void)     { int a = pop(); int b = pop(); push(b == a); }
void op_ne(void)     { int a = pop(); int b = pop(); push(b != a); }
void op_lt(void)     { int a = pop(); int b = pop(); push(b < a);  }
void op_le(void)     { int a = pop(); int b = pop(); push(b <= a); }
void op_gt(void)     { int a = pop(); int b = pop(); push(b > a); }
void op_ge(void)     { int a = pop(); int b = pop(); push(b >= a); }
void op_jump(void)   { pc = fetch(); }
void op_branch(void) { int addr = fetch(); int a = pop(); if (a) pc = addr; }
void op_halt(void)   { pc = -1; }
void op_read(void)   { unsigned char a; fread(&a, sizeof(a), 1, stdin); push(a); }
void op_write(void)  { unsigned char a = pop(); fwrite(&a, sizeof(a), 1, stdout); }
void op_print(void)  { printf("%d\n", pop()); }

void init_optab(void) {
    memset(optab, 0, sizeof(optab));
    optab[OP_NOP] =    op_nop;
    optab[OP_TON] =    op_ton;
    optab[OP_TOFF] =   op_toff;
    optab[OP_PUSH] =   op_push;
    optab[OP_POP] =    op_pop;
    optab[OP_PEEK] =   op_peek;
    optab[OP_POKE] =   op_poke;
    optab[OP_IPEEK] =  op_ipeek;
    optab[OP_IPOKE] =  op_ipoke;
    optab[OP_DUP] =    op_dup;
    optab[OP_SWAP] =   op_swap;
    optab[OP_ADD] =    op_add;
    optab[OP_SUB] =    op_sub;
    optab[OP_MUL] =    op_mul;
    optab[OP_DIV] =    op_div;
    optab[OP_AND] =    op_and;
    optab[OP_OR] =     op_or;
    optab[OP_NOT] =    op_not;
    optab[OP_EQ] =     op_eq;
    optab[OP_NE] =     op_ne;
    optab[OP_LT] =     op_lt;
    optab[OP_LE] =     op_le;
    optab[OP_GT] =     op_gt;
    optab[OP_GE] =     op_ge;
    optab[OP_JUMP] =   op_jump;
    optab[OP_BRANCH] = op_branch;
    optab[OP_HALT] =   op_halt;
    optab[OP_READ] =   op_read;
    optab[OP_WRITE] =  op_write;
    optab[OP_PRINT] =  op_print;
}

void init_opname(void) {
    memset(opname, 0, sizeof(opname));
    opname[OP_NOP] =    "nop";
    opname[OP_TON] =    "ton";
    opname[OP_TOFF] =   "toff";
    opname[OP_PUSH] =   "push";
    opname[OP_POP] =    "pop";
    opname[OP_PEEK] =   "peek";
    opname[OP_POKE] =   "poke";
    opname[OP_IPEEK] =  "ipeek";
    opname[OP_IPOKE] =  "ipoke";
    opname[OP_DUP] =    "dup";
    opname[OP_SWAP] =   "swap";
    opname[OP_ADD] =    "add";
    opname[OP_SUB] =    "sub";
    opname[OP_MUL] =    "mul";
    opname[OP_DIV] =    "div";
    opname[OP_AND] =    "and";
    opname[OP_OR] =     "or";
    opname[OP_NOT] =    "not";
    opname[OP_EQ] =     "eq";
    opname[OP_NE] =     "ne";
    opname[OP_LT] =     "lt";
    opname[OP_LE] =     "le";
    opname[OP_GT] =     "gt";
    opname[OP_GE] =     "ge";
    opname[OP_JUMP] =   "jump";
    opname[OP_BRANCH] = "branch";
    opname[OP_HALT] =   "halt";
    opname[OP_READ] =   "read";
    opname[OP_WRITE] =  "write";
    opname[OP_PRINT] =  "print";
};

int read_program(char *filename)
{
    FILE *fp = NULL;
    struct stat stat;

    if ((fp = fopen(filename, "r")) == NULL) {
        fprintf(stderr, "uvm: failed to open file %s; code=%d\n", filename, errno);
        exit(1);
    }
    if (fstat(fileno(fp), &stat) < 0) {
        fprintf(stderr, "uvm: failed to stat file %s; code=%d\n", filename, errno);
        exit(1);
    }
    program_size = (int)stat.st_size;
    program = calloc(program_size + 1, sizeof(char));
    if (fread(program, 1, program_size, fp) != program_size) {
        fprintf(stderr, "uvm: failed to read file %s; code=%d\n", filename, errno);
        exit(1);
    }
    fclose(fp);
    return 0;
}

int main(int argc, char *argv[])
{
    if (argc < 2) {
        fprintf(stderr, "usage: uvm [--trace] <program>\n");
        exit(1);
    }
    argv++;
    if (strcmp(*argv, "--trace")==0) {
        trace = 1;
        argv++;
    }
    stack_size = 256;
    stack = calloc(stack_size, sizeof(*stack));
    init_optab();
    init_opname();
    read_program(*argv);
    while (pc >= 0 && pc < program_size) {
        int code = program[pc++];
        if (code < 0 || code > NUMOPS) {
            fprintf(stderr, "uvm: invalid opcode %d\n", code);
            exit(1);
        }
        if (trace) {
            printf("%d: %s (%d)\n", pc, opname[code], code);
        }
        (*optab[code])();
        if (trace) {
            int i;
            printf("stack:\n");
            for (i = sp; i >= 0; i--) {
                printf("   %d: %d\n", i, stack[i]);
            }
        }
    }
    return 0;
}
