%{
#include <stdio.h>
#include <stdlib.h>
extern int yylex(void);
extern void yyerror(const char *);
%}

%token NUMBER

%%

statement:   expression               { printf("%d\n", $1); }
    ;

expression:  expression '+' NUMBER    { $$ = $1 + $3; }
    |        expression '-' NUMBER    { $$ = $1 - $3; }
    |        NUMBER                   { $$ = $1; }
    ;

%%

void yyerror(const char *s)
{
    fprintf(stderr, "%s\n", s);
    exit(1);
}

int main(int argc, char *argv[])
{
    return yyparse();
}
