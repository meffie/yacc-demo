%{
#include <stdio.h>
int offset = 0;
%}
%option nounput
%option noinput

%%
#.*\n    /* ignore comments */ ;

nop      |
push     |
pop      |
swap     |
dup      |
add      |
sub      |
mul      |
div      |
and      |
or       |
not      |
eq       |
ne       |
lt       |
le       |
gt       |
ge       |
jump     |
branch   |
return   |
halt     |
read     |
write    |
print    { offset++; }

[a-z][a-z0-9]*  |
[0-9]+          { offset += 4; }

[a-z][a-z0-9]*:  { yytext[yyleng-1] = '\0';
                   printf("%s %d\n", yytext, offset); }

.|\n     ;
%%

int main(int argc, char *argv[])
{
    yylex();
    return 0;
}
