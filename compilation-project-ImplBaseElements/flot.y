%{
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include "foncTab.h"
    
int exp_bool_choice = 0;
int type_of_exp = 0;/* 1 -> int | 2 -> char */
Sym symboles[20];
int indexOfSymboles = 0;

int yyerror(char*);
int yylex();
FILE* yyin; 
//int yylval; 
int jump_label=0;
void inst(const char *);
void instarg(const char *,int);
void comment(const char *);
void add_sub_term(char* as);
void comp_exp_temp(char * as);
void switchExpBool(void);
int jump_if(void);
void div_star_term(char *as);
void insertNewVar(char * id, int value);

%}
%union {
    char cval;
    char sval[256];
    char svalt[16];
    char svalcmp[2];
    char svalas[1];
    char svalds[1];
    int signedint;
    int usint;
}
%token NEGATION CONST EGAL PV VRG LPAR RPAR LACC RACC COMMENT
%token IF PRINT ELSE WHILE MAIN READ READCH RETURN VOID LSQB RSQB
%token <cval> CARACTERE
%token <signedint> ENTIER
%token <sval> IDENT
%token <usint> NUM
%token <svalas> ADDSUB
%token <svalcmp> COMP
%token <svalt> TYPE
%token <svalds> DIVSTAR
%token <svalb> BOPE 

%left NOELSE
%left ELSE
%left BOPE
%left COMP
%left ADDSUB
%left DIVSTAR
%left NEGATION

%type <usint> JumpIf
%type <usint> JumpElse
%type <usint> WhileLab
%type <usint> JumpDec

%%
Prog : DeclConst DeclVarPuisFonct DeclMain
	;
	 
DeclConst : DeclConst CONST ListConst PV
    | /*Epsilon */
    ;
    
ListConst : ListConst VRG IDENT EGAL Litteral
    | IDENT EGAL Litteral
    ;
    
Litteral : NombreSigne
    | CARACTERE
    ;
    
NombreSigne : NUM
    | ADDSUB NUM
    ;
    
DeclVarPuisFonct : TYPE ListVar PV DeclVarPuisFonct
    | DeclFonct
    | /*Epsilon */
    ;
    
ListVar : ListVar VRG Ident
    | Ident
    ;
Ident : IDENT Tab 
    | IDENT EGAL NUM { insertNewVar($1, $3); }
    ;
	
Tab : Tab LSQB ENTIER RSQB
    | /*Epsilon */
    ;

DeclMain : EnTeteMain Corps
	;

EnTeteMain : MAIN LPAR RPAR
	;

DeclFonct : DeclFonct DeclUneFonct
    | DeclUneFonct
    ;

DeclUneFonct : EnTeteFonct JumpDec{instarg("LABEL",999);} Corps{instarg("LABEL",$2);} /* 999 must be replaced by $2 */
	;
	
JumpDec :  { 
    instarg("JUMP", $$=jump_label++);
};

EnTeteFonct : TYPE IDENT LPAR Parametres RPAR
    | VOID IDENT LPAR Parametres RPAR
    ;

Parametres : VOID
    | ListTypVar
    ;

ListTypVar : ListTypVar VRG TYPE IDENT
    | TYPE IDENT
    ;

Corps : LACC DeclConst DeclVar SuiteInstr RACC
	;
	
DeclVar : DeclVar TYPE { if($2[0] == 'e') { type_of_exp =1; }else {type_of_exp = 2; } } ListVar { type_of_exp = 0; } PV
    | /*Epsilon */
    ;

SuiteInstr : SuiteInstr Instr
    | /*Epsilon */
    ;

InstrComp : LACC SuiteInstr RACC
	;
	
Instr : LValue EGAL Exp PV
    | IF LPAR ExpBool RPAR JumpIf Instr %prec NOELSE { instarg("LABEL", $5);}
    | IF LPAR ExpBool RPAR JumpIf Instr ELSE JumpElse { instarg("LABEL", $5);} Instr { instarg("LABEL", $8);}
    | WHILE WhileLab LPAR ExpBool RPAR JumpIf Instr {instarg("JUMP",$2);}{instarg("LABEL",$6);}
    | RETURN Exp PV
    | RETURN PV
    | IDENT LPAR Arguments RPAR PV
    | READ LPAR IDENT RPAR PV { inst("READ"); }
    | READCH LPAR IDENT RPAR PV { inst("READCH"); }
    | PRINT LPAR Exp RPAR PV { inst("WRITE"); }
    | PV
    | InstrComp
    ;

WhileLab : {
    instarg("LABEL", $$ = jump_label++);
};

JumpIf:  { $$= jump_if(); };

JumpElse :  { 
    instarg("JUMP", $$=jump_label++);
};

Arguments : ListExp
    | /*Epsilon */
    ;

LValue : IDENT TabExp
	;

TabExp : TabExp LSQB Exp RSQB
    | /*Epsilon */
    ;

ListExp : ListExp VRG Exp
    | Exp
    ;

Exp : Exp ADDSUB Exp { add_sub_term($2); }
    | Exp DIVSTAR Exp { div_star_term($2); }
    | ADDSUB Exp
    | LPAR Exp RPAR
    | LValue
    | NUM { instarg("SET", $1); inst("PUSH"); }
    | CARACTERE { instarg("SET", $1); inst("PUSH"); }
    | IDENT LPAR Arguments RPAR
    ;

ExpBool :
      Exp COMP Exp { comp_exp_temp($2); } 
    | ExpBool BOPE ExpBool 
    | NEGATION ExpBool 
    ;

%%

void insertNewVar(char * id, int value){  
    instarg("SET", 1);
    inst("SWAP");
    instarg("SET", value);
    inst("SAVER");
    insert(id, type_of_exp, value, symboles, &indexOfSymboles);
}

//TOPST ALLOC
void div_star_term(char *as){
    inst("POP");
    inst("SWAP"); 
    inst("POP");  
    switch(as[0]){
    	case '/':
            inst("DIV"); break;
	case '*':
            inst("MUL"); break;
	case '%': 
            inst("MOD"); break;
    }
    inst("PUSH"); 
}

void add_sub_term(char* as){
    inst("POP");
    inst("SWAP"); 
    inst("POP");  
    if(as[0] == '+') {
        inst("ADD");
    }else{
        inst("SUB");
    }
    inst("PUSH"); 
}

void comp_exp_temp(char * comp){
    if(comp[0] == '=' && comp[1] == '='){
        exp_bool_choice = 1;
    }else if (comp[0] == '>' && comp[1] == '='){
        exp_bool_choice = 2;
    }else if (comp[0] == '<' && comp[1] == '='){
        exp_bool_choice = 3;
    }else if (comp[0] == '!' && comp[1] == '='){
        exp_bool_choice = 4;
    }else if (comp[0] == '>'){
        exp_bool_choice = 5;
    }else if (comp[0] == '<'){
        exp_bool_choice = 6;
    }
}
void switchExpBool(){
    switch(exp_bool_choice){
        case 1: inst("EQUAL");  break;
        case 2: inst("GEQ");    break;
        case 3: inst("LEQ");    break;
        case 4: inst("NOTEQ");  break;
        case 5: inst("GREATER");break;
        case 6: inst("LESS");   break;
    }
    exp_bool_choice = 0;
}
int jump_if(void){
    inst("POP"); 
    inst("SWAP"); 
    inst("POP");
    switchExpBool();
    int ret = jump_label++;
    instarg("JUMPF", ret);
    return ret;
}
int yyerror(char* s) {
    fprintf(stderr, "%s\n", s);
    return 0;
}

void endProgram() {
    printf("HALT\n");
}

void inst(const char *s) {
    printf("%s\n", s);
}

void instarg(const char *s, int n) {
    printf("%s\t%d\n", s, n);
}

void comment(const char *s) {
    printf("#%s\n", s);
}

int main(int argc, char** argv) {
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else if (argc == 1) {
        yyin = stdin;
    } else {
        fprintf(stderr, "usage: %s [src]\n", argv[0]);
        return 1;
    }
    yyparse();
    endProgram();
    return 0;
}
