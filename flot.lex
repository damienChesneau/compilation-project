%{
#include "flot.h"
  int fileno (FILE *stream); /*non ansi*/
%}
lettre [A-Za-z]        
chiffre10 [0-9]
%option noyywrap
/* evite d'utiliser -lfl */
%%
        
[ \t\n]+ ;
[0-9]+ {sscanf(yytext,"%d",&yylval); return NOMBRE_ENTIER;}
"if" {return IF;}
"print" {return PRINT;}
"else" {return ELSE;}
"while" {return WHILE;}
"==" {return EE;}
">" {return SUP;}
"<" {return INF;}
">=" {return SE;}
"<=" {return IE;}
"!=" {return NE;}
"{" {return AO;}
"}" {return AF;}
. return yytext[0]; 
%%