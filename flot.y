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
char * id_of_tab_exp;
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
%token <usint> BOPE 

%left NOELSE
%left ELSE
%left BOPE
%left COMP
%left ADDSUB
%left DIVSTAR
%left NEGATION

%type <usint> TabExp
%type <usint> JumpIf 
%type <usint> Exp
%type <usint> LValue
%type <usint> JumpElse
%type <usint> WhileLab
%type <usint> JumpDec
%type <usint> EnTeteFonct
%type <param> Parametres
%type <param> ListTypVar
%%
Prog : Comment DeclConst DeclVarPuisFonct DeclMain 
    ;
Comment:
    COMMENT
    | /* Epsilon */
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
Ident : IDENT LSQB NUM RSQB { insertNewTab($1, $3, type_of_exp,1); }
    | IDENT EGAL NUM { insertNewVar($1, $3, type_of_exp); }
    | IDENT EGAL CARACTERE { insertNewVar($1, (int) $3, type_of_exp); }
    | IDENT { insertNewVar($1, 0, type_of_exp); }
    ;
/*
Tab : Tab LSQB ENTIER RSQB
    | { insertNewVar($1, 0); }
    ;*/

DeclMain : EnTeteMain { incFunctionInUse(); } Corps 
	;

EnTeteMain : MAIN LPAR RPAR
	;

DeclFonct : DeclFonct DeclUneFonct
    | DeclUneFonct
    ;

DeclUneFonct : EnTeteFonct JumpDec  { vm_label($1); init_param(); }Corps{ vm_label($2); }
	;
	
JumpDec :  { 
    vm_jump($$ = getNewLabel());
};

EnTeteFonct : TYPE IDENT LPAR Parametres RPAR {
    $$= entetfunc(($1[0] == 'e')?INTEGER:CHAR ,$4, $2);}
    | VOID IDENT LPAR Parametres RPAR {
	$$= entetfunc(VOIDVAL ,$4, $2);
    }
    ;

Parametres : VOID { $$ =set_void_buffer();  }
    | ListTypVar{ $$ = $1; }
    ;

ListTypVar : ListTypVar VRG TYPE IDENT { select_parameter_to_insert($3[0],1,$4); $$ = $1; }
    | TYPE IDENT { $$=select_parameter_to_insert($1[0],0,$2); }
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
	
Instr : 
     IDENT EGAL Exp PV  {  update_value($1); }
    | IF LPAR ExpBool RPAR JumpIf Instr %prec NOELSE { vm_label($5); }
    | IF LPAR ExpBool RPAR JumpIf Instr ELSE JumpElse { vm_label($5); } Instr { vm_label($8); }
    | WHILE WhileLab LPAR ExpBool RPAR JumpIf Instr { vm_jump($2); }{ vm_label($6); }
    | RETURN Exp PV
    | RETURN PV
//    | IDENT LPAR Arguments RPAR PV
    | READ LPAR IDENT RPAR PV { read_int_val($3); }
    | READCH LPAR IDENT RPAR PV { read_char_val($3); }
    | PRINT LPAR Exp RPAR PV { print_value($3); }
    | PV
    | InstrComp
    | COMMENT
    ;

WhileLab : {
    vm_label($$ = getNewLabel());
};

JumpIf:  { $$= jump_if(); };

JumpElse :  { 
    vm_jump($$ = getNewLabel());
};

Arguments : ListExp
    | /*Epsilon */
    ;

LValue : IDENT { $$ = replace_new_var($1); } 
    | IDENT {id_of_tab_exp = $1;} TabExp { $$ = $3; }
    ;

TabExp : TabExp LSQB Exp RSQB {$$= getValueInTab(id_of_tab_exp, 1, 1); }
    | /*Epsilon */
    ;

ListExp : ListExp VRG Exp
    | Exp
    ;

Exp : Exp ADDSUB Exp { add_sub_term($2); }
    | Exp DIVSTAR Exp { div_star_term($2); }
    | ADDSUB Exp { $$=INTEGER;  }
    | LPAR Exp RPAR { $$=INTEGER;  }
    | LValue { $$ = $1;  }
    | NUM { vm_swap(); vm_set($1); vm_push(); $$ = INTEGER; }
    | CARACTERE {vm_set($1); vm_push(); $$ = CHAR;}
    | IDENT LPAR Arguments RPAR { $$ = INTEGER; }
    ;

ExpBool :
      Exp COMP Exp { comp_exp_temp($2); } 
    | NEGATION ExpBool { manage_neg(); }
    | LPAR ExpBool RPAR 
    | ExpBool BOPE { vm_push(); } ExpBool { manage_bope($2); }
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
    vm_endProgram();
    return 0;
}
