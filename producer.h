#ifndef __stdio__
#define __stdio__
#include <stdio.h>
#endif
#include "vm_functions.h"
#include "symbols_table.h"


void add_sub_term(char* as);
void comp_exp_temp(char * as);
void switchExpBool(void);
int jump_if(void);
void div_star_term(char *as);
void replace_new_var(char * id);
void param_cpy(int src_param[32], int dest_param[32]);
void insert_param(int type);
void vm_endProgram();
int getNewLabel();
int setFunctionInUse(int val);
void insertNewVar(char * id, int value, int type);
void allocate_stack();

int entetfunc(int type, char * id, char * id2);
int* select_parameter_to_insert(char test, int more);
int* set_void_buffer();
void initialize_buffer_index();