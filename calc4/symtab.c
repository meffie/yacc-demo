
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "symtab.h"

struct symbol symtab[NSYMBOLS];

/**
 * Lookup a symbol and add it if not found.
 */
struct symbol* sym_lookup(char *name)
{
    int i;
    struct symbol *s;

    for (i = 0; i < NSYMBOLS; i++) {
        s = &symtab[i];
        if (s->name && strcmp(s->name, name) == 0) {
            return s;
        }
    }
    for (i = 0; i < NSYMBOLS; i++) {
        s = &symtab[i];
        if (!s->name) {
            s->name = strdup(name);
            return s;
        }
    }
    fprintf(stderr, "fatal: symtab size exceeded\n");
    exit(1);
}
