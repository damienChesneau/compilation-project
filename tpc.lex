%{
#include "tpc.h"
  int fileno (FILE *stream); /*non ansi*/
%}
lettre [A-Za-z]        
chiffre10 [0-9]
%option noyywrap
/* evite d'utiliser -lfl */
%%

[ \t\n]+ ;
"/*"(_|{lettre}|{chiffre10}|(\t)*|(\n)*|(.)*|(\s)*|("(")*|(")")*|(";")*)*"*/" { return COMMENT;}
"main" { return MAIN;}
"readch" { return READCH; }
"read" { return READ; }
"return" { return RETURN; }
"void" { return VOID; }
("==")|(">=")|("<=")|("!=")|(">")|("<") { strncpy(yylval.svalcmp, yytext, yyleng); yylval.svalcmp[yyleng]='\0'; return COMP; }
"&&" { yylval.usint = 1; return BOPE;}
"||" { yylval.usint = 2; return BOPE;}
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
"entier" { strncpy(yylval.svalt, yytext, yyleng); yylval.svalt[yyleng]='\0'; return TYPE;}
"int" { strncpy(yylval.svalt, "entier", yyleng); yylval.svalt[yyleng]='\0'; return TYPE;}
"caractere" { strncpy(yylval.svalt, yytext, yyleng); yylval.svalt[yyleng]='\0'; return TYPE;}
"char" { strncpy(yylval.svalt, "caractere", yyleng); yylval.svalt[yyleng]='\0'; return TYPE;}

("+")|("-") { strncpy(yylval.svalas, yytext, yyleng); yylval.svalas[yyleng]='\0'; return ADDSUB; }
("*")|("/")|("%") { strncpy(yylval.svalds, yytext, yyleng); yylval.svalds[yyleng]='\0'; return DIVSTAR;}
'{lettre}' { yylval.cval = yytext[1];return CARACTERE; }
[0-9]+ { sscanf(yytext,"%d",&yylval.usint); return NUM;}
{lettre}(_|{lettre}|{chiffre10})* { strncpy(yylval.sval,yytext,yyleng); yylval.sval[yyleng]='\0'; return IDENT;}
^('-')?({chiffre10})*$ { sscanf(yytext,"%d",&yylval.signedint); return ENTIER;}

. return yytext[0]; 
%%
