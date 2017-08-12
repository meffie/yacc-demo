%{
#include <stdio.h>
#include "debug.h"
#include "y.tab.h"
extern YYSTYPE yylval;
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
{comment}   { debug("COMMENT (ignored)"); }
{blankline} { debug("WS (ignored)"); }
{date}      { debug("DATE"); return DATE; }
{title}     { debug("TITLE"); return TITLE; }
{par}       { debug("PAR"); return PAR; }
{special}   { debug1("SPECIAL", yytext[0]); return yytext[0]; }
{nl}        { debug("NEWLINE"); return '\n'; }
{ch}        { debug1("CHAR", yytext[0]); yylval.ch = yytext[0]; return CHAR; }
%%

