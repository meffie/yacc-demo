%{
/* uvm assember - first pass */
#include <stdio.h>
#include <arpa/inet.h>
int offset = 0;
%}
%option nounput
%option noinput

%%
#.*\n            /* ignore comments */ ;
[a-z]+           { /* keyword */  offset++; }
\$[a-z][a-z0-9]* { /* variable */ offset += sizeof(uint32_t); }
-?[0-9]+         { /* value */    offset += sizeof(uint32_t); }
[a-z][a-z0-9]*:  { /* label */
                   yytext[yyleng-1] = '\0'; /* trim : */
                   printf("%s %d\n", yytext, offset); }
.|\n             ;
%%

int main(int argc, char *argv[])
{
    yylex();
    return 0;
}
