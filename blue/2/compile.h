
struct symbol {
    char *ident;
    int address;
};

struct verb {
    int vid;
    int nargs;
    struct node *arg[3];
};

enum ntype { nlit, nsym, nverb };

struct node {
    enum ntype nid;
    union {
        int lit;
        struct symbol *sym;
        struct verb verb;
    };
};

struct node *literal(int value);
struct node *symbol(char *name);
struct node *verb(int id, int nargs, ...);

void preamble(void);
void walk(struct node *node);
