%{
/* usm assember - second pass */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>
#include "uvm.h"
void emit(char op);
void emitlong(int value);
int lookup(char *text);
FILE *out = NULL;
struct label {
    struct label *next;
    char *name;
    int offset;
};
struct label *head = NULL;
%}
%option nounput
%option noinput

%%
nop      emit(OP_NOP);

push     emit(OP_PUSH);
pop      emit(OP_POP);
swap     emit(OP_SWAP);
dup      emit(OP_DUP);

add      emit(OP_ADD);
sub      emit(OP_SUB);
mul      emit(OP_MUL);
div      emit(OP_DIV);

and      emit(OP_AND);
or       emit(OP_OR);
not      emit(OP_NOT);

eq       emit(OP_EQ);
ne       emit(OP_NE);
lt       emit(OP_LT);
le       emit(OP_LE);
gt       emit(OP_GT);
ge       emit(OP_GE);

jump     emit(OP_JUMP);
branch   emit(OP_BRANCH);
return   emit(OP_RETURN);
halt     emit(OP_HALT);

read     emit(OP_READ);
write    emit(OP_WRITE);
print    emit(OP_PRINT);

#.*\n            /* ignore comments */ ;
[ \t\n]          /* ignore whitespace */ ;
[a-z][a-z0-9]*:  /* labels were read in the first pass */ ;
\$[a-z][a-z0-9]* { emitlong(lookup(yytext+1)); }
[0-9]+           { emitlong(atoi(yytext)); }
.                { fprintf(stderr, "bug: %s\n", yytext); exit(1); }
%%

void emit(char code)
{
    fwrite(&code, sizeof(code), 1, out);
}

void emitlong(int value)
{
    int32_t data = htonl(value);
    fwrite(&data, sizeof(data), 1, out);
}

void read_labels(char *filename)
{
    FILE *fp = NULL;
    int offset = 0;
    char buffer[64];

    if ((fp = fopen(filename, "r")) == NULL) {
        fprintf(stderr, "uasm2: failed to open file %s\n", filename);
        exit(1);
    }
    while (fscanf(fp, "%63s %d\n", buffer, &offset) == 2) {
        struct label *label = calloc(1, sizeof(*label));
        label->name = strdup(buffer);
        label->offset = offset;
        label->next = head;
        head = label;
    }
    fclose(fp);
}

int lookup(char *name)
{
    struct label *label = head;
    while (label) {
        if (strcmp(label->name, name) == 0) {
            return label->offset;
        }
        label = label->next;
    }
    fprintf(stderr, "uasm2: label not found: %s\n", name);
    exit(1);
    return -1; /* not found */
}

int main(int argc, char *argv[])
{
    if (argc != 3) {
        fprintf(stderr, "usage: uasm2 <labels> <output>\n");
        exit(1);
    }
    read_labels(argv[1]);
    if ((out = fopen(argv[2], "w")) == NULL) {
        fprintf(stderr, "uasm2: failed to open file %s\n", argv[2]);
        exit(1);
    }
    yylex();
    fclose(out);
    return 0;
}
