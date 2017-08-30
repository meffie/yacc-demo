/*
 * uvm - micro virtual machine
 *
 * This is an elementary opcode interpreter for demonstration purposes,
 * similar to Wirth's p-code interpreter.
 *
 * Differences from Wirth's p-code:
 *   - opcodes are 8 bits followed by 0 or 1 32-bit integer
 *   - only 1 base level
 *   - different call frame setup/teardown
 *   - added indirect peek/poke (aka load/store) for arrays
 *   - added elementary i/o opcodes for demos
 *   - added tracing for demos and debugging
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

/* opcode table */
void (*optab[NUMOPS])(void);

/* code buffer */
char *program = NULL;
int program_size = 0;

/* stack buffer */
int *stack = NULL;
int stack_size = 4096;

/* registers */
int pc = 0;  /* program counter (instruction pointer) */
int sp = -1; /* stack pointer */
int mp = 0;  /* mark pointer */
int bp = 0;  /* base pointer (stack frames) */

/* tracing */
int trace = 0;
#define T(x)    if (trace) printf("%s\n", (x))
#define T1(x,y) if (trace) printf("%s %d\n", (x), (y))
#define TS()    if (trace) trace_stack()
void trace_stack(void)
{
    int i;
    printf("pc:%d sp:%d bp:%d mp:%d\n", pc, sp, bp, mp);
    printf("stack:\n");
    for (i = sp; i >= 0; i--) {
        printf("   %d: %d\n", i, stack[i]);
    }
    printf("\n");
}

/* fetch next argument */
int fetch(void)
{
    int arg;
    memcpy(&arg, &program[pc], sizeof(uint32_t));
    pc += sizeof(uint32_t);
    return ntohl(arg);
}

/* opcodes */
#define push(x)    stack[++sp]=(x)
#define pop()      stack[sp--]
#define peek(x)    stack[(x)]
#define poke(x, y) stack[(x)] = y
void op_nop(void)    { T("nop"); }
void op_ton(void)    { trace = 1; T("ton"); }
void op_toff(void)   { T("toff"); trace = 0; }
void op_push(void)   { int a = fetch(); T1("push", a); push(a); }
void op_pop(void)    { T("pop"); sp--; }
void op_peek(void)   { int a = fetch(); T1("peek", a); a += bp+2; push(peek(a)); }
void op_poke(void)   { int a = fetch(); T1("poke", a); a += bp+2; poke(a, pop()); }
void op_ipeek(void)  { int a = fetch(); T1("ipeek", a); a += pop()+bp+2; push(peek(a)); }
void op_ipoke(void)  { int a = fetch(); T1("ipoke", a); a += pop()+bp+2; poke(a, pop()); }
void op_dup(void)    { int a = pop(); T("dup"); push(a); push(a); }
void op_swap(void)   { int a = pop(); int b = pop(); T("swap"); push(a); push(b); }
void op_add(void)    { int a = pop(); int b = pop(); T("add");  push(b + a); }
void op_sub(void)    { int a = pop(); int b = pop(); T("sub");  push(b - a); }
void op_mul(void)    { int a = pop(); int b = pop(); T("mul");  push(b * a); }
void op_div(void)    { int a = pop(); int b = pop(); T("div");  push(b / a); }
void op_mod(void)    { int a = pop(); int b = pop(); T("mod");  push(b % a); }
void op_eq(void)     { int a = pop(); int b = pop(); T("eq");   push(b == a); }
void op_ne(void)     { int a = pop(); int b = pop(); T("ne");   push(b != a); }
void op_lt(void)     { int a = pop(); int b = pop(); T("lt");   push(b < a);  }
void op_le(void)     { int a = pop(); int b = pop(); T("le");   push(b <= a); }
void op_gt(void)     { int a = pop(); int b = pop(); T("gt");   push(b > a); }
void op_ge(void)     { int a = pop(); int b = pop(); T("ge");   push(b >= a); }
void op_and(void)    { int a = pop(); int b = pop(); T("and");  push(b && a); }
void op_or(void)     { int a = pop(); int b = pop(); T("or");  push(b || a); }
void op_not(void)    { int a = pop();                T("not");  push(!a); }
void op_jump(void)   { int a = fetch(); T1("jump", a); pc = a; }
void op_branch(void) { int a = fetch(); T1("branch", a); if (pop()) pc = a; }
void op_mark(void)   { T("mark"); mp = sp+1; sp += 2; }
void op_call(void)   { int a = fetch(); T1("call", a); poke(mp,bp); poke(mp+1,pc); bp = mp; pc = a; }
void op_return(void) { T("return"); pc = peek(bp+1); bp = peek(bp); }
void op_unmark(void) { T("unmark"); sp = mp-1; mp=bp; }
void op_halt(void)   { T("halt"); pc = -1; }
void op_read(void)   { unsigned char a; T("read"); fread(&a, sizeof(a), 1, stdin); push(a); }
void op_write(void)  { unsigned char a = pop(); T("write"); fwrite(&a, sizeof(a), 1, stdout); }
void op_print(void)  { T("print"); printf("%d\n", pop()); }

/* initalize the opcode table */
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
    optab[OP_MOD] =    op_mod;
    optab[OP_EQ] =     op_eq;
    optab[OP_NE] =     op_ne;
    optab[OP_LT] =     op_lt;
    optab[OP_LE] =     op_le;
    optab[OP_GT] =     op_gt;
    optab[OP_GE] =     op_ge;
    optab[OP_AND] =    op_and;
    optab[OP_OR] =     op_or;
    optab[OP_NOT] =    op_not;
    optab[OP_JUMP] =   op_jump;
    optab[OP_BRANCH] = op_branch;
    optab[OP_MARK] =   op_mark;
    optab[OP_CALL] =   op_call;
    optab[OP_RETURN] = op_return;
    optab[OP_UNMARK] = op_unmark;
    optab[OP_HALT] =   op_halt;
    optab[OP_READ] =   op_read;
    optab[OP_WRITE] =  op_write;
    optab[OP_PRINT] =  op_print;
}

/* read program into memory */
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
    if (argc != 2) {
        fprintf(stderr, "usage: uvm <program>\n");
        exit(1);
    }
    stack = calloc(stack_size, sizeof(*stack));
    init_optab();
    read_program(argv[1]);
    push(-1); /* base */
    push(-1); /* return */
    while (pc >= 0 && pc < program_size) {
        int code = program[pc++];
        if (code < 0 || code > NUMOPS) {
            fprintf(stderr, "uvm: invalid opcode %d at %d\n", code, pc-1);
            exit(1);
        }
        (*optab[code])();
        TS();
    }
    return 0;
}
