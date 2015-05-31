#ifndef __stdio__
#define __stdio__
#include <stdio.h>
#endif
#include "vm_functions.h"
#include "symbols_table.h"

#define PARAMETER_SPACE 32
#define INTEGER 1 
#define CHAR 2 
#define CONSTVAL 3
#define VOIDVAL 0

/*
	Add or sub the two elements on the top of the stack. As has the sign of the operation.
*/
void add_sub_term(char* as);

/*
	Set on the vm the compare operation set in as.
*/	
void comp_exp_temp(char * as);

/*
	Do the compare operation on the vm.
*/
void switchExpBool(void);

/*	
	Do the jump if operation on the vm. Return the label to jump.
*/
int jump_if(void);

/*
	Multiply or divide the two elements on the top of the stack. As has  the sign of the operation.
*/
void div_star_term(char *as);

/*
	Do the load of a variable to do with his id on the vm. Returns the type of the variable. 
*/
int replace_new_var(char * id);

/*
	Insert the parameter in the buffer of parameter.
*/
void insert_param(int type);

/*
	Get a new label for vm.
*/
int getNewLabel();

/*
	Insert a new variable by id, value of adress and type in the table of symbols and on the vm.
*/
void insertNewVar(char * id, int value, int type);

/*
	Allocate the space for parameters on the stack.
*/
void allocate_stack();

/*
	Do the write operation on the vm. Type is the type of write operation to do.
*/
void print_value(int type);

/*
	Read a integer value in stdin and put it in the variable id.
*/
void read_int_val(char * id);

/*
	Read a character value in stdin and put it in the variable id.
*/
void read_char_val(char * id);

/*
	Update the value of the adress of the id with the value in reg2. Generate an error if id is constant. Returns the type of id.
*/
int update_value(char * id);

/*
	Update the value of the addre of the id + index with the value of reg2. Generate an error if id is constant. Returns the type of id.
*/
int update_tab_value(char * id, int index);

/*
	Manage the boolean neg operation.
*/
void manage_neg();

/*
	Manage the bope of bopevalue on booleans. 
*/
void manage_bope(int bopevalue);

/*
	Insert a new array by id, size, value of adress and type in the table of symbols and on the vm.
*/
void insertNewTab(char * id, int size, int type, int nbdim);

/*
	Do the load of an array to do with his id on the vm. Returns the type of the array. 
*/
int getValueInTab(char * id, int index, int dim);

/*
	Insert a new constant variable by id and type in the table of symbols and on the vm. Isglob says in wich function is set or if it's global.
*/
void insertNewConst(char * id, int isglob,int type);

/*
	Returns if the variable id in the table of symbols is constant.
*/
int is_global(char *id);

/*
	Initialize the function in use.
*/
void set_function_in_use();

/*
	Increment the function in use. It means that we are changing of function.
*/
void incFunctionInUse();

/*
	Returns the index of arguments to push.
*/
int get_index_of_args();

/*
	Set the value of end in the array of parameter.
*/
void finish_parameter();

/*
	Set the index of args to zero.
*/
void reset_index_of_args();

/*
	Push an argument of a function in the stack.
*/
void push_arg();

/*
	Recuperate arguments in the stack for the function in use.
*/
void init_param();

/*
	Insert the argumebts on the top of the stack on the vm.
*/
void insertNewVarTop(char * id, int type);

/*
	Print table of symbols (for debug).
*/
void print_symbole_debug();

/*
	Returns the numbers of arguments of the symbole.
*/
int getNbArg(Sym symbole);

/*
	Get the function id in a symbole. Returns the symbole of id. 
*/
Sym* getFunction(char * id);

/*
	Insert a function in the table of symbole by type of return, parameters and id. Returns the label of the function.
*/
int entetfunc(int type, int* types, char * id);

/*
	Insert parameter of function of id in the table of symboles. Returns array of parameters added.
*/
int* select_parameter_to_insert(char test, char* id);

/*
	Set the buffer of parameter to zero by seting the end of array on the first tile.
*/
int* set_void_buffer();
