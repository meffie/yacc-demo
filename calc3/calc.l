%{
#include "y.tab.h"
#include <math.h>
extern YYSTYPE yylval;
extern double vtable[26];
%}

%%
[0-9]+	        |
[0-9]*\.[0-9]+ 	{ yylval.value = atof(yytext); return NUMBER; }

[ \t]	;		          /* ignore white space */

[a-z]	{ yylval.index = yytext[0] - 'a'; return NAME; }

"$"	    { return 0; /* end of input */ }

\n |
.	    return yytext[0];

%%
