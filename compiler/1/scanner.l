%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "y.tab.h"
extern int enable_debug;
void ldebug(char *fmt, ...);
extern YYSTYPE yylval;

#define TOKEN(x) ldebug("%s", #x); return(x);

%}
%option nounput
%option noinput

comment [/][/].*\n
ws [ \t\n]+
number -?[0-9]+
name [a-zA-Z_][a-zA-Z0-9_]*
eq   =
ge   >=
gt   >
le   <=
lt   <
ne   <>

%%
{comment} { ldebug("comment=%s", yytext); }
{ws}      { ; }
^[ \t]*\n { ; }

and       { TOKEN(AND); }
do        { TOKEN(DO); }
else      { TOKEN(ELSE); }
end       { TOKEN(END); }
if        { TOKEN(IF); }
let       { TOKEN(LET); }
not       { TOKEN(NOT); }
or        { TOKEN(OR); }
then      { TOKEN(THEN); }
while     { TOKEN(WHILE); }
var       { TOKEN(VAR); }
print     { TOKEN(PRINT); }

{eq}      { TOKEN(EQ); }
{ge}      { TOKEN(GE); }
{gt}      { TOKEN(GT); }
{le}      { TOKEN(LE); }
{lt}      { TOKEN(LT); }
{ne}      { TOKEN(NE); }

{number}  { yylval.number = atoi(yytext); ldebug("number=%d", yylval.number); return NUMBER; }
{name}    { yylval.string = strdup(yytext); ldebug("name='%s'", yylval.string); return NAME; }
.         { ldebug("ch='%c'", yytext[0]); return yytext[0]; }
%%

void ldebug(char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    if (enable_debug) {
        printf("token: <");
        vprintf(fmt, ap);
        printf(">\n");
    }
    va_end(ap);
}

