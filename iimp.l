%{
#include "iimp.tab.h"
#include "environ.h"
#include <string.h>

char string[MAXIDENT];
%}

Nombre 0|[1-9][0-9]*
Nom [A-Za-z][A-Za-z0-9\_]*

%%
":=" {return(Affect);}
"+" {return(Plus);}
"-" {return(Moins);}
"*" {return(Mult);}
"while" {return(Wh);}
"do" {return(Do);}
"if" {return(If);}
"then" {return(Th);}
"else" {return(El);}
"skip" {return(Skip);}
";" {return(Se);}
"(" {return('(');}
")" {return(')');}
{Nombre} {yylval.val = atoi(yytext); return(I);}
{Nom} {yylval.str = malloc(yyleng * sizeof(char)); strcpy(yylval.str, yytext); return(V);}
[ \n\t] {}
. {}
%%
