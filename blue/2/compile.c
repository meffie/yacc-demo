
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "y.tab.h"
#include "compile.h"

extern FILE* yyout;
extern void yyerror(const char *);


int nsymbols = 0;
struct symbol table[100];

struct symbol *getsym(char *ident)
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

struct node *literal(int value)
{
    struct node *node = malloc(sizeof(struct node));
    if (!node)
        yyerror("out of memory");
    memset(node, 0, sizeof(struct node));
    node->nid = nlit;
    node->lit = value;
    return node;
}

struct node *symbol(char *name)
{
    struct node *node = malloc(sizeof(struct node));
    if (!node)
        yyerror("out of memory");
    memset(node, 0, sizeof(struct node));
    node->nid = nsym;
    node->sym = getsym(name);
    if (!node->sym) {
        if (nsymbols == sizeof(table)/sizeof(*table)) {
            yyerror("max number of symbols exceeded");
        }
        node->sym = &table[nsymbols];
        node->sym->ident = strdup(name);
        node->sym->address = nsymbols;
        nsymbols++;
    }
    return node;
}

struct node *verb(int id, int nargs, ...)
{
    int i;
    va_list ap;
    struct node *node;

    if (nargs < 0 || nargs > 3)
        yyerror("number of args out of range");

    node = malloc(sizeof(struct node));
    if (!node)
        yyerror("out of memory");
    memset(node, 0, sizeof(struct node));

    node->nid = nverb;
    node->verb.vid = id;
    node->verb.nargs = nargs;
    va_start(ap, nargs);
    for (i = 0; i < nargs; i++) {
        node->verb.arg[i] = va_arg(ap, struct node*);
    }
    va_end(ap);
    return node;
}

void emit(char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    vfprintf(yyout, fmt, ap);
    va_end(ap);
}

void preamble(void)
{
    struct symbol *s = table;
    while (s->ident) {
        emit("\tpush 0  # %d:%s\n", s->address, s->ident);
        s++;
    }
    emit("\n");
}

void walk(struct node *node)
{
    static int label = 0;
    int label0, label1;
    struct symbol *sym;
    struct verb *verb;

    switch(node->nid) {
    case nlit:
        emit("\tpush %d\n", node->lit);
        break;
    case nsym:
        sym = node->sym;
        emit("\tpeek %d # %s\n", sym->address, sym->ident);
        break;
    case nverb:
        verb = &node->verb;
        switch (verb->vid) {
        case LET:
            walk(verb->arg[1]);
            sym = verb->arg[0]->sym;
            emit("\tpoke %d # let %s\n", sym->address, sym->ident);
            break;
        case PRINT:
            walk(verb->arg[0]);
            emit("\tprint\n"); break;
            break;
        case IF:
            label0 = label++;
            label1 = label++;
            emit("\t# if\n");
            walk(verb->arg[0]);  /* if ... */
            emit("\tbranch $label%02d\n", label0);
            if (verb->nargs == 3) {
                walk(verb->arg[2]); /* else ... end */
            }
            emit("\tjump $label%02d\nlabel%02d:\n", label1, label0);
            walk(verb->arg[1]);     /* then ... else */
            emit("label%02d: # end if\n\tnop\n", label1);
            break;
        case WHILE:
            label0 = label++;
            label1 = label++;
            emit("label%02d: # while\n", label0);
            walk(verb->arg[0]);
            emit("\tnot\n\tbranch $label%02d\n", label1);
            walk(verb->arg[1]);
            emit("\tjump $label%02d\n", label0);
            emit("label%02d: # end while\n\tnop\n", label1);
            break;
        case NOT:
            walk(verb->arg[0]);
            emit("    not\n");
            break;
        default:
            walk(verb->arg[0]);
            walk(verb->arg[1]);
            switch (verb->vid) {
            case EOS: break;
            case '+': emit("\tadd\n"); break;
            case '*': emit("\tmul\n"); break;
            case '-': emit("\tsub\n"); break;
            case '/': emit("\tdiv\n"); break;
            case '%': emit("\tmod\n"); break;
            case AND: emit("\tand\n"); break;
            case EQ:  emit("\teq\n");  break;
            case GE:  emit("\tge\n");  break;
            case GT:  emit("\tgt\n");  break;
            case LE:  emit("\tle\n");  break;
            case LT:  emit("\tlt\n");  break;
            case NE:  emit("\tne\n");  break;
            case OR:  emit("\tor\n");  break;
            default: yyerror("invalid verb"); break;
            }
        }
    }
}

