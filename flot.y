%{
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include "foncTab.h"
    
int exp_bool_choice = 0;
int type_of_exp = 0;/* 1 -> int | 2 -> char | 0-> void (for functions)*/
Sym symboles[20];
int indexOfSymboles = 0; /* Please do not change initalized val. */
int function_in_use; /* define the name of current function. */
int buff_param[32];/*buffer of parametres */
int index_of_buff_param = 0;/*index of buff_param*/

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
void replace_new_var(char * id);
void param_cpy(int src_param[32],int dest_param[32]);
void insert_param(int type);

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
    int * param;
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
%type <usint> EnTeteFonct
%type <param> Parametres
%type <param> ListTypVar
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
    | IDENT { insertNewVar($1, 0); }
    ;
	
Tab : Tab LSQB ENTIER RSQB
    | /*{ insertNewVar($1, 0); }*/
    ;

DeclMain : EnTeteMain { function_in_use = 0; } Corps { function_in_use = -1; }
	;

EnTeteMain : MAIN LPAR RPAR
	;

DeclFonct : DeclFonct DeclUneFonct
    | DeclUneFonct
    ;

DeclUneFonct : EnTeteFonct JumpDec{instarg("LABEL",$1);} Corps{instarg("LABEL",$2);}
	;
	
JumpDec :  { 
    instarg("JUMP", $$=jump_label++);
};

EnTeteFonct : TYPE IDENT LPAR Parametres RPAR {
	if($1[0] == 'e') 
		type_of_exp = 1; 
	else 
		type_of_exp = 2; 
	Signature sign;
	sign.type = type_of_exp;
	param_cpy($4,sign.param);
	insert_function($1,sign,$$ = jump_label++,symboles,&indexOfSymboles);
	}
    | VOID IDENT LPAR Parametres RPAR {$$ = jump_label++;}
    ;

Parametres : VOID {buff_param[0] = -1; $$ = buff_param;}
    | ListTypVar{index_of_buff_param = 0;$$ = $1;}
    ;

ListTypVar : ListTypVar VRG TYPE IDENT {if($3[0] == 'e') insert_param(1); else insert_param(2);index_of_buff_param++;$$ = $1;}
    | TYPE IDENT {if($1[0] == 'e') insert_param(1); else insert_param(2); ;index_of_buff_param = 0;$$ = buff_param;}
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
    | PRINT LPAR Exp RPAR PV { inst("WRITE"); inst("POP");  }
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
| IDENT { replace_new_var($1); } 
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

void insert_param(int type){
	buff_param[index_of_buff_param] = type;
}

void param_cpy(int src_param[32],int dest_param[32]){
	int i = 0;
	for(i = 0; i<32;i++){
		dest_param = src_param;
	}
}

void insertNewVar(char * id, int value){ 
    int newAddr =  getNewAddr(function_in_use, symboles, &indexOfSymboles);
    instarg("SET", newAddr);
    inst("SWAP");
    instarg("SET", value);
    instarg("ALLOC", 1);
    inst("SAVER"); 
    insert(id, type_of_exp, newAddr,function_in_use, symboles, &indexOfSymboles);
}

void replace_new_var(char * id){ 
    char var[255];
    strcpy(var,id);
    int addr = getValue(var, symboles, &indexOfSymboles);
    instarg("SET", addr);
    inst("LOADR"); 
}

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
    instarg("ALLOC", 1);
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
