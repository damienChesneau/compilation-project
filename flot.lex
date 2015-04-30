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
"main" { return MAIN;}
"readch" { return READCH; }
"read" { return READ; }
"return" { return RETURN; }
"void" { return VOID; }
'*' |'/'|'%' { sscanf(yytext,"%s",&yylval.svalds); return DIVSTAR;}
"&&" | "||" { sscanf(yytext,"%s",&yylval.svalbp); return BOPE;}
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
"entier" { sscanf(yytext,"%s", yylval.svalt); return TYPE;}
"caractere" { sscanf(yytext,"%s", yylval.svalt); return TYPE;}
"==" | ">" | "<" | ">=" | "<=" | "!=" { sscanf(yytext,"%s",&yylval.svalcmp); return COMP;}
"+"|"-" { sscanf(yytext,"%s",  yylval.svalas); return ADDSUB;}
^lettre$ {sscanf(yytext,"%c",&yylval.cval); return CARACTERE;}
[0-9]+ { sscanf(yytext,"%d",&yylval.usint); return NUM;}
{lettre}(_|{lettre}|{chiffre10})* { sscanf(yytext,"%s", yylval.sval); return IDENT;}
^('-')?({chiffre10})*$ { sscanf(yytext,"%d",&yylval.signedint); return ENTIER;}

. return yytext[0]; 
%%
