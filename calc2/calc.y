%{
#include <stdio.h>
#include <stdlib.h>
extern int yylex(void);
extern void yyerror(const char *);
%}

%token NAME
%token NUMBER

%left '+' '-'
%left '*' '/'
%nonassoc NEG

%%

statement: NAME '=' expression
    |      expression                   { printf("%d\n", $1); }
    ;

expression:  expression '+' expression  { $$ = $1 + $3; }
    |        expression '-' expression  { $$ = $1 - $3; }
    |        expression '*' expression  { $$ = $1 * $3; }
    |        expression '/' expression  { if (!$3) yyerror("divide by zero");
                                          else $$ = $1 / $3; }
    |        '-' expression %prec NEG   { $$ = -1 * $2; }
    |        '(' expression ')'         { $$ = $2; }
    |        NUMBER                     { $$ = $1; }
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
