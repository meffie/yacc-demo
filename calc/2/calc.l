%{
#include "y.tab.h"
extern int yylval;
%}
%option nounput
%option noinput

%%
[0-9]+	{ yylval = atoi(yytext); return NUMBER; } /* todo: NAME */
[ \t]	;		          /* ignore white space */
\n	    return 0;	      /* logical EOF */
.	    return yytext[0]; /* operators */
%%
