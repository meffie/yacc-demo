
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "compile.h"
#include "debug.h"

int enable_debug = 0;

void debug(char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    if (enable_debug) {
        printf(" ** ");
        vfprintf(stderr, fmt, ap);
        printf("\n");
    }
    va_end(ap);
}

void indent(int level)
{
    int i;
    for (i = 0; i < level; i++) {
        printf("  ");
    }
}

/* debug dump */
void dump(struct node *node)
{
    static int level = 0;
    int i;

    switch(node->nid) {
    case nlit:
        indent(level);
        printf("lit %d\n", node->lit);
        break;
    case nsym:
        indent(level);
        printf("sym ident=%s address=%d\n", node->sym->ident, node->sym->address);
        break;
    case nverb:
        indent(level);
        printf("verb %d nargs=%d\n", node->verb.vid, node->verb.nargs);
        for (i = 0; i < node->verb.nargs; i++) {
            indent(level++);
            printf("arg %d\n", i);
            dump(node->verb.arg[i]);
            level--;
        }
        break;
    default:
        printf("invalid node id! %d\n", node->nid);
        exit(1);
    }
}
