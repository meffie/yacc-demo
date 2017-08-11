%{
#include "y.tab.h"
#include "symtab.h"
#include <math.h>
extern YYSTYPE yylval;
%}
%option nounput
%option noinput

%%
[0-9]+	        |
[0-9]*\.[0-9]+ 	{ yylval.value = atof(yytext); return NUMBER; }

[ \t]	;		          /* ignore white space */

[a-zA-Z][a-zA-Z0-9]* { yylval.sym = sym_lookup(yytext); return NAME; }

"$"	    { return 0; /* end of input */ }

\n |
.	    return yytext[0];

%%
