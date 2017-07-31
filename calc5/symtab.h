
#define NSYMBOLS 256

struct symbol {
    char *name;
    double value;
    double (*fn)(double arg);
};

struct symbol* sym_lookup(char *name);
void sym_addfn(char *name, double (*fn)(double));
