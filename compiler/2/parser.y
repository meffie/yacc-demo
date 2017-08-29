%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "debug.h"
#include "compile.h"

extern int yylex(void);
extern void yyerror(const char *);
extern FILE *yyin;
extern FILE *yyout;
char *progname;
extern int enable_debug;
%}

%union {
    int number;
    char *string;
    struct node *node;
}

%token AND
%token DO
%token ELSE
%token END
%token EQ
%token GE
%token GT
%token IF
%token LE
%token LET
%token LT
%token NE
%token NOT
%token OR
%token PRINT
%token THEN
%token WHILE

%token <number> NUMBER
%token <string> NAME

%left EQ NE LT GT LE GE
%left AND OR
%left '+' '-'
%left '*' '/' '%'
%nonassoc NOT

%type <node> exp cond
%type <node> let_statement print_statement if_statement while_statement
%type <node> statement statements

%%

program: statements              { debug("program -> statements");
                                   preamble();
                                   walk($1); }
       ;

statements: statements statement { debug("statements -> statements statement");
                                   $$ = verb(';', 2, $1, $2); }
          | statement            { debug("statements -> statement"); }
          ;

statement: let_statement         { debug("statement -> let_statement"); }
         | print_statement       { debug("statement -> print_statement"); }
         | if_statement          { debug("statement -> if_statement"); }
         | while_statement       { debug("statement -> while_statement"); }
         ;

let_statement: LET NAME EQ exp
        { debug("let_statement -> LET NAME EQ exp");
          $$ = verb(LET, 2, symbol($2), $4); }

print_statement: PRINT exp
        { debug("print_statement -> PRINT exp");
          $$ = verb(PRINT, 1, $2); }

if_statement: IF cond DO statements END
                 { debug("if_statement -> IF cond DO statements END");
                   $$ = verb(IF, 2, $2, $4); }
            | IF cond THEN statements ELSE statements END
                 { debug("if_statement -> IF cond THEN statements ELSE statements END");
                   $$ = verb(IF, 3, $2, $4, $6); }

while_statement: WHILE cond DO statements END
        { debug("while_statement -> WHILE cond DO statements END");
          $$ = verb(WHILE, 2, $2, $4); }

cond: exp EQ exp         { debug("cond -> exp EQ exp"); $$ = verb(EQ, 2, $1, $3); }
    | exp NE exp         { debug("cond -> exp NE exp"); $$ = verb(NE, 2, $1, $3); }
    | exp LT exp         { debug("cond -> exp LT exp"); $$ = verb(LT, 2, $1, $3); }
    | exp GT exp         { debug("cond -> exp GT exp"); $$ = verb(GT, 2, $1, $3); }
    | exp LE exp         { debug("cond -> exp LE exp"); $$ = verb(LE, 2, $1, $3); }
    | exp GE exp         { debug("cond -> exp GE exp"); $$ = verb(GE, 2, $1, $3); }
    | NOT cond %prec NOT { debug("cond -> NOT cond"); $$ = verb(NOT, 1, $2); }
    | cond AND cond      { debug("cond -> cond AND cond"); $$ = verb(AND, 2, $1, $3); }
    | cond OR cond       { debug("cond -> cond OR cond"); $$ = verb(OR, 2, $1, $3); }
    | '(' cond ')'       { debug("cond -> '(' cond ')'"); $$ = $2; }
    ;

exp: exp '+' exp         { debug("exp -> exp + exp"); $$ = verb('+', 2, $1, $3); }
   | exp '-' exp         { debug("exp -> exp - exp"); $$ = verb('-', 2, $1, $3); }
   | exp '*' exp         { debug("exp -> exp * exp"); $$ = verb('*', 2, $1, $3); }
   | exp '/' exp         { debug("exp -> exp / exp"); $$ = verb('/', 2, $1, $3); }
   | exp '%' exp         { debug("exp -> exp %% exp"); $$ = verb('%', 2, $1, $3); }
   | '(' exp ')'         { debug("exp -> ( exp )"); $$ = $2; }
   | NUMBER              { debug("exp -> NUMBER=%d", $1); $$ = literal($1); }
   | NAME                { debug("exp -> NAME=%s", $1); $$ = symbol($1); }
   ;

%%

void yyerror(const char *s)
{
    fprintf(stderr, "%s\n", s);
    exit(1);
}


int main(int argc, char *argv[])
{
    progname = *argv;
    argv++;
    argc--;
    if (argc) {
        if (strcmp(*argv, "-d") == 0) {
            enable_debug = 1;
            argv++;
            argc--;
        }
    }
    if (argc) {
        yyin = fopen(*argv, "r");
        if (!yyin) {
            perror("Failed to open source file");
            exit(1);
        }
        argv++;
        argc--;
    }
    if (argc) {
        yyout = fopen(*argv, "w");
        if (!yyout) {
            perror("Failed to open output file");
            exit(1);
        }
        argv++;
        argc--;
    }

    yyparse();
    return 0;
}
