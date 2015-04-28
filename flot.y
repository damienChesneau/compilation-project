%{
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
    
int exp_bool_choice = 0;

int yyerror(char*);
int yylex();
FILE* yyin; 
int yylval; 
int jump_label=0;
void inst(const char *);
void instarg(const char *,int);
void comment(const char *);
/*Personnal functions*/
%}

%token IF
%token PRINT 
%token NOMBRE_ENTIER 
%token ELSE 
%token AO
%token AF
%token WHILE
%token EE
%token SE
%token IE
%token NE
%token SUP
%token INF

%left NOELSE
%left ELSE
%left '+'
%left '*'

%%
PROGRAMME : /* rien */ | PROGRAMME INSTRUCTION 
       ;
INSTRUCTION : PRINT /*E*/ ';' { inst("POP"); inst("WRITE");	comment("---affichage"); }
    ;
%%

int yyerror(char* s) {
  fprintf(stderr,"%s\n",s);
  return 0;
}

void endProgram() {
  printf("HALT\n");
}

void inst(const char *s){
  printf("%s\n",s);
}

void instarg(const char *s,int n){
  printf("%s\t%d\n",s,n);
}

void comment(const char *s){
  printf("#%s\n",s);
}

int main(int argc, char** argv) {
  if(argc==2){
    yyin = fopen(argv[1],"r");
  }
  else if(argc==1){
    yyin = stdin;
  }
  else{
    fprintf(stderr,"usage: %s [src]\n",argv[0]);
    return 1;
  }
  yyparse();
  endProgram();
  return 0;
}
