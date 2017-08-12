%{
#include <stdio.h>
#include <stdlib.h>
#include "debug.h"
extern int yylex(void);
extern void yyerror(const char *);
%}

%union {
    char ch;
}
%token DATE
%token TITLE
%token PAR
%token <ch> CHAR

%%
blog: entries
entries: entries entry | entry
entry: date title pars

date: DATE text '\n'
title: TITLE text '\n'

pars: pars par | par
par: PAR text '\n'

text: text entity | entity
entity: CHAR | '\n' | '&' | '"' | '\'' | '>' | '<'

%%

void yyerror(const char *s)
{
    fprintf(stderr, "%s\n", s);
    exit(1);
}

int main(int argc, char *argv[])
{
    enable_debug = 0;
    yyparse();
    printf("parsed\n");
    return 0;
}
