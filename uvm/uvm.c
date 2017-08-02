/* demo bytecode interpreter */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <arpa/inet.h>
#include "uvm.h"

int enable_trace = 0;
char *program = NULL;
int *stack = NULL;
int psize = 0;
int ssize = 0;
int pc = 0;
int sp = -1;
void (*optab[NUMOPS])(void);

#define push(x) stack[++sp]=(x)
#define pop()   stack[sp--]
#define peek()  stack[sp]

void trace_stack(void) {
    int i;
    for (i = sp; i >= 0; i--) {
        printf("   %d: %d\n", i, stack[i]);
    }
}
void trace(char *text) {
    if (enable_trace) printf("=> %s\n", text);
}
void trace1(char *text, int data) {
    if (enable_trace) printf("=> %s %d\n", text, data);
}
void trace2(char *text, int a, int b) {
    if (enable_trace) printf("=> %s %d %d\n", text, a, b);
}

int fetch(void)
{
    int arg;
    memcpy(&arg, &program[pc], sizeof(uint32_t));
    pc += sizeof(uint32_t);
    return ntohl(arg);
}

void op_nop(void)    { trace("nop"); }
void op_push(void)   { int arg = fetch(); trace1("push", arg); push(arg); }
void op_pop(void)    { int a = pop(); trace1("pop", a); }
void op_swap(void)   { int a = pop(); int b = pop(); trace2("swap", b, a); push(a); push(b); }
void op_dup(void)    { int a = pop();                trace1("dup", a);     push(a); push(a); }
void op_add(void)    { int a = pop(); int b = pop(); trace2("add", b, a);  push(b + a); }
void op_sub(void)    { int a = pop(); int b = pop(); trace2("sub", b, a);  push(b - a); }
void op_mul(void)    { int a = pop(); int b = pop(); trace2("mul", b, a);  push(b * a); }
void op_div(void)    { int a = pop(); int b = pop(); trace2("div", b, a);  push(b / a); }
void op_mod(void)    { int a = pop(); int b = pop(); trace2("div", b, a);  push(b % a); }
void op_and(void)    { int a = pop(); int b = pop(); trace2("and", b, a);  push(b && a); }
void op_or(void)     { int a = pop(); int b = pop(); trace2("or", b, a);   push(b || a); }
void op_not(void)    { int a = pop();                trace1("not", a);     push(!a); }
void op_eq(void)     { int a = pop(); int b = pop(); trace2("eq", b, a);   push(b == a); }
void op_ne(void)     { int a = pop(); int b = pop(); trace2("ne", b, a);   push(b != a); }
void op_lt(void)     { int a = pop(); int b = pop(); trace2("lt", b ,a);   push(b < a);  }
void op_le(void)     { int a = pop(); int b = pop(); trace2("le", b, a);   push(b <= a); }
void op_gt(void)     { int a = pop(); int b = pop(); trace2("gt", b, a);   push(b > a); }
void op_ge(void)     { int a = pop(); int b = pop(); trace2("ge", b, a);   push(b >= a); }
void op_jump(void)   { int arg = fetch(); trace1("jump", arg); pc = arg; }
void op_branch(void) { int arg = fetch(); trace1("branch", arg); pc = (peek()!=0 ? arg : pc); }
void op_return(void) { int a = pop(); trace1("return", a); pc = a; }
void op_halt(void)   { trace("halt"); pc = -1; }
void op_read(void)   { unsigned char a; fread(&a, sizeof(a), 1, stdin); trace1("read", a); push(a); }
void op_write(void)  { unsigned char a = pop(); trace1("write", a); fwrite(&a, sizeof(a), 1, stdout); }
void op_print(void)  { trace("print"); printf("%d\n", pop()); }

void init_optab(void) {
    memset(optab, 0, sizeof(optab));
    optab[OP_NOP] =    op_nop;
    optab[OP_PUSH] =   op_push;
    optab[OP_POP] =    op_pop;
    optab[OP_SWAP] =   op_swap;
    optab[OP_DUP] =    op_dup;
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
    optab[OP_RETURN] = op_return;
    optab[OP_HALT] =   op_halt;
    optab[OP_READ] =   op_read;
    optab[OP_WRITE] =  op_write;
    optab[OP_PRINT] =  op_print;
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
    psize = (int)stat.st_size;
    program = calloc(psize + 1, sizeof(char));
    if (fread(program, 1, psize, fp) != psize) {
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
        enable_trace = 1;
        argv++;
    }
    ssize = 256;
    stack = calloc(ssize, sizeof(*stack));
    init_optab();
    read_program(*argv);
    while (pc >= 0 && pc < psize) {
        int code = program[pc++];
        if (code < 0 || code > NUMOPS) {
            fprintf(stderr, "uvm: invalid opcode %d\n", code);
            exit(1);
        }
        (*optab[code])();
        if (enable_trace) trace_stack();
    }
    return 0;
}
