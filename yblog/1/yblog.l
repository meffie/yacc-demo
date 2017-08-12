%{
#include <stdio.h>
#include "debug.h"
%}
%option nounput
%option noinput

comment ^#.*\n
blankline ^[ \t]*\n
date ^[.][d][ ]
title ^[.][t][ ]
par ^[.][p][ ]
special ["'&<>]
nl \n
ch .

%%
{comment}   { debug("COMMENT"); }
{blankline} { debug("WS"); }
{date}      { debug("DATE"); }
{title}     { debug("TITLE"); }
{par}       { debug("PAR"); }
{special}   { debug1("SPECIAL", yytext[0]); }
{nl}        { debug("NEWLINE"); }
{ch}        { debug1("CHAR", yytext[0]); }
%%

int main(void)
{
    enable_debug = 1;
    yylex();
    return 0;
}
