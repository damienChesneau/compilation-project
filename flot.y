%{
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

    int exp_bool_choice = 0;

    int yyerror(char*);
    int yylex();
    FILE* yyin;
//    int yylval;
    int jump_label = 0;
    void inst(const char *);
    void instarg(const char *, int);
    void comment(const char *);
    /*Personnal functions*/
%}
%union {
    char cval;
    char * sval;
    char * svalt;
    char * svalcmp;
    char * svalas;
    char * svalds;
    int signedint;
    int usint;
}
%token NEGATION CONST EGAL PV VRG LPAR RPAR LACC RACC 
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

%left BOPE
%left COMP
%left ADDSUB
%left DIVSTAR
%left NEGATION

%%
Prog : DeclConst DeclVarPuisFonct DeclMain

DeclConst : DeclConst CONST ListConst PV
    | /*Epsilon */
ListConst : ListConst VRG IDENT EGAL Litteral
    | IDENT EGAL Litteral
Litteral : NombreSigne
    | CARACTERE
NombreSigne : NUM
    | ADDSUB NUM
DeclVarPuisFonct : TYPE ListVar PV DeclVarPuisFonct
    | DeclFonct
    | /*Epsilon */
ListVar : ListVar VRG Ident
    | Ident
Ident : IDENT Tab
Tab : Tab LSQB ENTIER RSQB
    | /*Epsilon */
DeclMain : EnTeteMain Corps
EnTeteMain : MAIN LPAR RPAR 
DeclFonct : DeclFonct DeclUneFonct
    | DeclUneFonct
DeclUneFonct : EnTeteFonct Corps
EnTeteFonct : TYPE IDENT LPAR Parametres RPAR
    | VOID IDENT LPAR Parametres RPAR
Parametres : VOID
    | ListTypVar
ListTypVar : ListTypVar VRG TYPE IDENT
    | TYPE IDENT
Corps : LACC DeclConst DeclVar SuiteInstr RACC
DeclVar : DeclVar TYPE ListVar PV
    | /*Epsilon */
SuiteInstr : SuiteInstr Instr
    | /*Epsilon */
InstrComp : LACC SuiteInstr RACC
Instr : LValue EGAL Exp PV
    | IF LPAR Exp RPAR Instr
    | IF LPAR Exp RPAR Instr ELSE Instr
    | WHILE LPAR Exp RPAR Instr
    | RETURN Exp PV
    | RETURN PV
    | IDENT LPAR Arguments RPAR PV
    | READ LPAR IDENT RPAR PV
    | READCH LPAR IDENT RPAR PV
    | PRINT LPAR Exp RPAR PV
    | PV
    | InstrComp
Arguments : ListExp
    | /*Epsilon */
LValue : IDENT TabExp
TabExp : TabExp LSQB Exp RSQB
    | /*Epsilon */
ListExp : ListExp VRG Exp
    | Exp
Exp : Exp ADDSUB Exp
    | Exp DIVSTAR Exp
    | Exp COMP Exp
    | ADDSUB Exp
    | Exp BOPE Exp
    | NEGATION Exp
    | LPAR Exp RPAR
    | LValue
    | NUM
    | CARACTERE
    | IDENT LPAR Arguments RPAR
%%

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
