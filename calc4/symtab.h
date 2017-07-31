
#define NSYMBOLS 256

struct symbol {
    char *name;
    double value;
};

struct symbol* sym_lookup(char *name);
