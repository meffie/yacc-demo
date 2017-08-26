%{
/* uvm assember */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <arpa/inet.h>
#include "uvm.h"

int yywrap(void);
extern FILE *yyin;
extern FILE *yyout;

void error(char *fmt, ...);
void opcode(enum uvm_opcode op);
void number(int n);
void ident(char *s);
void label(char *s);
%}
%option nounput
%option noinput

%%
nop      opcode(OP_NOP);
ton      opcode(OP_TON);
toff     opcode(OP_TOFF);
push     opcode(OP_PUSH);
pop      opcode(OP_POP);
peek     opcode(OP_PEEK);
poke     opcode(OP_POKE);
ipeek    opcode(OP_IPEEK);
ipoke    opcode(OP_IPOKE);
dup      opcode(OP_DUP);
swap     opcode(OP_SWAP);
add      opcode(OP_ADD);
sub      opcode(OP_SUB);
mul      opcode(OP_MUL);
div      opcode(OP_DIV);
mod      opcode(OP_MOD);
eq       opcode(OP_EQ);
ne       opcode(OP_NE);
lt       opcode(OP_LT);
le       opcode(OP_LE);
gt       opcode(OP_GT);
ge       opcode(OP_GE);
jump     opcode(OP_JUMP);
branch   opcode(OP_BRANCH);
mark     opcode(OP_MARK);
call     opcode(OP_CALL);
return   opcode(OP_RETURN);
unmark   opcode(OP_UNMARK);
halt     opcode(OP_HALT);
read     opcode(OP_READ);
write    opcode(OP_WRITE);
print    opcode(OP_PRINT);

#.*\n            /* ignore comments */ ;
[ \t\n]          /* ignore whitespace */ ;
[a-z][a-z0-9]*:  { yytext[yyleng-1] = '\0'; label(yytext); }
\$[a-z][a-z0-9]* ident(yytext+1);
-?[0-9]+         number(atoi(yytext));
.                error("unexpected char %s\n");

%%

char *src;
char *bin;
int pass = 1;
int offset = 0;

struct symbol {
    char *ident;
    int offset;
};

int tail = 0;
struct symbol table[100];

struct symbol*
getsym(char *ident)
{
    struct symbol *s = table;
    while (s->ident) {
        if (strcmp(ident, s->ident) == 0) {
            return s;
        }
        s++;
    }
    return NULL;
}

void
addsym(char *ident, int offset)
{
    if (getsym(ident)) {
        error("attempt to redefine symbol: %s\n", ident);
    }
    if (tail == sizeof(table)/sizeof(*table)) {
        error("max symbols exceeded\n");
    }
    table[tail].ident = strdup(ident);
    table[tail].offset = offset;
    tail++;
}

void opcode(enum uvm_opcode op)
{
    unsigned char data = op;
    if (pass == 1) {
        offset += sizeof(data);
    } else {
        fwrite(&data, sizeof(data), 1, yyout);
    }
}

void number(int n)
{
    int32_t data = htonl(n);
    if (pass == 1) {
        offset += sizeof(data);
    } else {
        fwrite(&data, sizeof(data), 1, yyout);
    }
}

void ident(char *ident)
{
    uint32_t data;
    struct symbol *sym;

    if (pass == 1) {
        offset += sizeof(data);
    } else {
        if ((sym = getsym(ident)) == NULL) {
            error("unresolved name: %s\n", ident);
        }
        data = htonl(sym->offset);
        fwrite(&data, sizeof(data), 1, yyout);
    }
}

void label(char *name)
{
    if (pass == 1) {
        addsym(yytext, offset);
    }
}

void error(char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    exit(1);
}

/* Reopen src file for second pass. */
int yywrap(void)
{
    int done;

    if (pass > 1) {
        done = 1;
    } else {
        if (fclose(yyin)) {
            error("failed to close src file.\n");
        }
        if ((yyin = fopen(src, "r")) == NULL) {
            error("failed to reopen src file.\n");
        }
        pass++;
        done = 0;
    }
    return done;
}

int main(int argc, char *argv[])
{
    if (argc != 3) {
        error("usage: uasm <src> <bin>\n");
    }
    src = argv[1];
    bin = argv[2];
    if ((yyin = fopen(src, "r")) == NULL) {
        error("failed to open source %s\n", src);
    }
    if ((yyout = fopen(bin, "w")) == NULL) {
        error("failed to open output %s\n", bin);
    }
    memset(table, 0, sizeof(table));
    yylex();
    fclose(yyin);
    fclose(yyout);
    return 0;
}
