%{
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include "producer.h"    
#include <fcntl.h>

int yyerror(char*);
int yylex();
FILE* yyin; 
int type_of_exp = 0; /* 1 -> int | 2 -> char | 0-> void (for functions)*/
char * id_of_tab_exp;
Sym* tmp_sym = NULL;
int updateable_var = 0;
int is_glob= 0;
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
/*%type <usint> ListExp
%type <usint> Arguments*/
%%
Prog : Comment {is_glob = 1 ;} DeclConst {is_glob = 0 ;} DeclVarPuisFonct DeclMain 
    ;
Comment:
    COMMENT
    | /* Epsilon */
    ;
DeclConst : DeclConst CONST ListConst PV /*For allocate const var, must do SAVE and begin the list at 33 */
    | /*Epsilon */
    ;
    
ListConst : ListConst VRG IDENT EGAL Litteral {  insertNewConst($3,is_glob,type_of_exp);   type_of_exp=0;}
    | IDENT EGAL Litteral {  insertNewConst($1,is_glob,type_of_exp);   type_of_exp=0;}
    ;
    
Litteral : { type_of_exp=1; } NombreSigne  
    | { type_of_exp=2; } CARACTERE { vm_set($2); }
    ;
    
NombreSigne : NUM { vm_set($1); }
    | ADDSUB NUM { vm_set($2); if($1[0] == '-'){ vm_neg(); } }
    ;
    
DeclVarPuisFonct : TYPE ListVar PV DeclVarPuisFonct /*Here, I don't know how I can get the type... */
    | DeclFonct
    | /*Epsilon */
    ;
    
ListVar : ListVar VRG Ident 
    | Ident
    ;
    
Ident : IDENT LSQB NUM RSQB {insertNewTab($1, $3, type_of_exp,1); }
    | IDENT EGAL NUM { insertNewVar($1, $3, type_of_exp); }
    | IDENT EGAL CARACTERE { insertNewVar($1, (int) $3, type_of_exp); }
    | IDENT { insertNewVar($1, 0, type_of_exp); }
    | IDENT EGAL Exp {insertNewVarTop($1,$3);}	
    ;
/*
Tab : Tab LSQB ENTIER RSQB
    | { insertNewVar($1, 0); }
    ;*/

DeclMain : EnTeteMain Corps 
	;

EnTeteMain : MAIN LPAR RPAR 
	;

DeclFonct : DeclFonct DeclUneFonct
    | DeclUneFonct
    ;

DeclUneFonct : EnTeteFonct JumpDec  { vm_label($1); init_param($1);}Corps{incFunctionInUse();vm_return(); vm_label($2); }
	;
	
JumpDec :  { 
    vm_jump($$ = getNewLabel());
};

EnTeteFonct : TYPE IDENT LPAR {set_function_in_use();} Parametres RPAR { set_function_in_use();$$= entetfunc(($1[0] == 'e')?INTEGER:CHAR ,$5, $2);}
    | VOID IDENT LPAR  {set_function_in_use();}Parametres RPAR { $$= entetfunc(VOIDVAL ,$5, $2); }
    ;

Parametres : { $$ = set_void_buffer();  }
	| VOID { $$ = set_void_buffer();  }
    | ListTypVar{ $$ = $1;finish_parameter(); }
    ;

ListTypVar : ListTypVar VRG TYPE IDENT { select_parameter_to_insert($3[0],$4); $$ = $1; }
    | TYPE IDENT { $$=select_parameter_to_insert($1[0],$2); }
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
     COMMENT
    | IDENT EGAL Exp PV  {  update_value($1); }
    | IDENT LSQB NUM RSQB EGAL Exp PV  { update_tab_value($1, $3); }
    | IF LPAR ExpBool RPAR JumpIf Instr %prec NOELSE { vm_label($5); }
    | IF LPAR ExpBool RPAR JumpIf Instr ELSE JumpElse { vm_label($5); } Instr { vm_label($8); }
    | WHILE WhileLab LPAR ExpBool RPAR JumpIf Instr { vm_jump($2); }{ vm_label($6); }
    | RETURN Exp PV {vm_pop();}
    | RETURN PV
    | IDENT LPAR Arguments RPAR PV{tmp_sym = getFunction($1); if(tmp_sym == NULL) vm_error("Fonction inexistante"); if( get_index_of_args()!= getNbArg(*tmp_sym)) printf("%d\t%d\tNombre d'arguments invalide",get_index_of_args(),getNbArg(*tmp_sym)); vm_call(tmp_sym->addr);}
    | READ LPAR IDENT RPAR PV { read_int_val($3); }
    | READCH LPAR IDENT RPAR PV { read_char_val($3); }
    | PRINT LPAR Exp RPAR PV { print_value($3); }
    | PV
    | InstrComp

    ;

WhileLab : {
    vm_label($$ = getNewLabel());
};

JumpIf:  { $$= jump_if(); };

JumpElse :  { 
    vm_jump($$ = getNewLabel());
};

Arguments : /*Epsilon */{/*$$ = 0;*/reset_index_of_args();}
	| VOID {/*$$ = 0;*/reset_index_of_args();}
	| ListExp {/*$$ = $1;*/}
    ;

LValue : IDENT { $$ = replace_new_var($1);vm_push();} 
    | IDENT {id_of_tab_exp = $1;} TabExp { $$ = $3; }
    ;

TabExp : TabExp LSQB Exp RSQB {$$= getValueInTab(id_of_tab_exp, 1, 1); }
    | /*Epsilon */ { $$ = VOIDVAL; }
    ;

ListExp : ListExp VRG Exp {/*$$ = $3+1; */ push_arg();}
    | Exp {/*$$ = 1;*/  reset_index_of_args(); push_arg();}
    ;

Exp : Exp ADDSUB Exp { add_sub_term($2); }
    | Exp DIVSTAR Exp { div_star_term($2); }
    | ADDSUB Exp { $$=INTEGER;  }
    | LPAR Exp RPAR { $$=INTEGER;  }
    | LValue { $$ = $1;  }
    | NUM { vm_swap(); vm_set($1); vm_push(); $$ = INTEGER; }
    | CARACTERE {vm_set($1); vm_push(); $$ = CHAR;}
    | IDENT LPAR Arguments RPAR {tmp_sym = getFunction($1); if(tmp_sym == NULL) vm_error("Fonction inexistante"); if(get_index_of_args() != getNbArg(*tmp_sym)) printf("%d\t%d\tNombre d'arguments invalide",get_index_of_args(),getNbArg(*tmp_sym)); $$ = tmp_sym->sign.type; vm_call(tmp_sym->addr); vm_push();}
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

char* appendTo(char * dest, const char *s) {
    int sLength = strlen(s);
    int destLen = strlen(dest);
 
    int totalLength = sLength + destLen;
    char * strBuf = (char *) malloc(sizeof(char)*(totalLength+1));
    strcpy(strBuf, dest);
    strcpy(strBuf + destLen, s);
    free(dest);
    return strBuf;
}
int main(int argc, char** argv) {
    int tempout =0;
    int oldout= 0;
    int newout = 0;
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else if (argc == 1) {
        printf("1\n");
        yyin = stdin;
    } else {
         if(argc > 2 ){
            if( strcmp(argv[2], "-o") == 0){
                yyin = fopen(argv[1], "r");
                printf("To file\n"); 
                char outputname[255];
                strcpy(outputname, argv[1]);
                sscanf(argv[1],"%[^.]",outputname);  
                outputname[strlen(outputname)-4] ='\0';
                sprintf(outputname,"%s.vm",outputname);
                tempout = open(outputname, O_RDWR | O_TRUNC | O_CREAT);
                oldout = dup(1);
                close(1);
                newout = dup(tempout);
            }
        }
    }
    allocate_stack();
    yyparse();
    vm_endProgram();
    if(argc > 2 ){
        if( strcmp(argv[2],"-o") == 0){
            close(tempout);
            close(1);
            newout = dup(oldout);
            close(oldout);
        }
    }
    return 0;
}
