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
['a'-'z']| ['A'-'Z'] {sscanf(yytext,"%c",&yylval); return CARACTERE;}
[0-9]+ { sscanf(yytext,"%d",&yylval); return NUM;}
{lettre}(_|{lettre}|{chiffre10})* { sscanf(yytext,"%s",&yylval.id); return IDENT;}
"entier" { sscanf(yytext,"%s",&yylval.id); return TYPE;}
"caractere" { sscanf(yytext,"%s",&yylval.id); return TYPE;}
"==" | ">" | "<" | ">=" | "<=" | "!=" { sscanf(yytext,"%s",&yylval.id); return COMP;}
"+"|"-" { sscanf(yytext,"%s",&yylval.id); return ADDSUB;}
"*"| "/" | "%" { sscanf(yytext,"%s",&yylval.id); return DIVSTAR;}
"&&" | "||" { sscanf(yytext,"%s",&yylval.id); return BOPE;}
"!" {return NEGATION;}
"=" {return EGAL;}
";" {return PV;}
"," {return VRG;}
"(" {return LPAR;}
")" {return RPAR;}
"{" {return LACC;}
"}" {return RACC;}
"[" {return LSQB;}
"]" {return RSQB;}

"if" {return IF;}
"print" {return PRINT;}
"else" {return ELSE;}
"while" {return WHILE;}

. return yytext[0]; 
%%
