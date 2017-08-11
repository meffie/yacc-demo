%{
#include <stdio.h>
#include <stdlib.h>
extern int yylex(void);
extern void yyerror(const char *);

double vtable[26]; /* a .. z */
%}

%union {
    double value;
    int index;
}
%token <index> NAME
%token <value> NUMBER
%type <value> expression

%left '+' '-'
%left '*' '/'
%nonassoc NEG

%%

statements: statements statement '\n'
    |       statement '\n'
    ;

statement:  NAME '=' expression    { vtable[$1] = $3; }
    |       expression             { printf("%g\n", $1); }
    ;

expression:  expression '+' expression  { $$ = $1 + $3; }
    |        expression '-' expression  { $$ = $1 - $3; }
    |        expression '*' expression  { $$ = $1 * $3; }
    |        expression '/' expression  { if ($3 == 0.0) yyerror("divide by zero");
                                          else $$ = $1 / $3; }
    |        '-' expression %prec NEG   { $$ = -1 * $2; }
    |        '(' expression ')'         { $$ = $2; }
    |        NUMBER                     { $$ = $1; }
    |        NAME                       { $$ = vtable[$1]; }
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
