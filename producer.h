#ifndef __stdio__
#define __stdio__
#include <stdio.h>
#endif
#include "vm_functions.h"
#include "symbols_table.h"

#define INTEGER 1 
#define CHAR 2 
#define VOIDVAL 0

void add_sub_term(char* as);
void comp_exp_temp(char * as);
void switchExpBool(void);
int jump_if(void);
void div_star_term(char *as);
int replace_new_var(char * id);
void insert_param(int type);
void vm_endProgram();
int getNewLabel();
void insertNewVar(char * id, int value, int type);
void allocate_stack();
void print_value(int type);
void read_int_val(char * id);
void read_char_val(char * id);
int update_value(char * id);
int update_tab_value(char * id, int index);
void manage_neg();
void manage_bope(int bopevalue);
void insertNewVar(char * id, int value, int type);
void insertNewTab(char * id, int size, int type,int nbdim);
int getValueInTab(char * id, int index, int dim);
void insertNewConst(void);

//void incNbFunction();
void incFunctionInUse();
/*void setFunctionInUse(int loc);
void restore_caller();
void init_function_in_use();*/
int get_index_of_args();
void finish_parameter();
void reset_index_of_args();
void push_arg();
void init_param();
void insertNewVarTop(char * id,int type);
void print_symbole_debug();
int getNbArg(Sym symbole);
Sym* getFunction(char * id);
int entetfunc(int type, int* types, char * id);
int* select_parameter_to_insert(char test,char* id);
int* set_void_buffer();
void initialize_buffer_index();
