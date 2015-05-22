%{
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include "producer.h"    

int yyerror(char*);
int yylex();
FILE* yyin; 
int type_of_exp = 0; /* 1 -> int | 2 -> char | 0-> void (for functions)*/

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
Ident : IDENT LSQB ENTIER RSQB
    | IDENT EGAL NUM { insertNewVar($1, $3, type_of_exp); }
    | IDENT { insertNewVar($1, 0, type_of_exp); }
    ;
/*
Tab : Tab LSQB ENTIER RSQB
    | { insertNewVar($1, 0); }
    ;*/

DeclMain : EnTeteMain { setFunctionInUse(0); } Corps { setFunctionInUse(-1); }
	;

EnTeteMain : MAIN LPAR RPAR
	;

DeclFonct : DeclFonct DeclUneFonct
    | DeclUneFonct
    ;

DeclUneFonct : EnTeteFonct JumpDec{instarg("LABEL",$1);} Corps{instarg("LABEL",$2);}
	;
	
JumpDec :  { 
    instarg("JUMP", $$=getNewLabel());
};

EnTeteFonct : TYPE IDENT LPAR Parametres RPAR {
    $$= entetfunc(($1[0] == 'e')?1:2 ,(char*)$4, $2);}
    | VOID IDENT LPAR Parametres RPAR {
	$$= entetfunc(0 ,(char*)$4, $2);}
    ;

Parametres : VOID { $$ =set_void_buffer();  }
    | ListTypVar{ $$ = $1; }
    ;

ListTypVar : ListTypVar VRG TYPE IDENT { select_parameter_to_insert($3[0],1); $$ = $1; }
    | TYPE IDENT { $$=select_parameter_to_insert($1[0],0); }
    ;

Corps : LACC DeclConst DeclVar SuiteInstr RACC 
	;
	
DeclVar : DeclVar TYPE { if($2[0] == 'e') { type_of_exp =1; }else { type_of_exp = 2; } } ListVar { type_of_exp = 0; } PV
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
    instarg("LABEL", $$ = getNewLabel());
};

JumpIf:  { $$= jump_if(); };

JumpElse :  { 
    instarg("JUMP", $$ = getNewLabel());
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

int yyerror(char* s) {
    fprintf(stderr, "%s\n", s);
    return 0;
}

int main(int argc, char** argv) {
    allocate_stack();
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
