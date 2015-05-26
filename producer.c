#include "producer.h"
#define NB_SYM 20
#define MAX_CALL 256
int jump_label = 0;
int exp_bool_choice = 0;
Sym symboles[NB_SYM];
int indexOfSymboles = 0; /* Please do not change initalized val. */
int buff_param[32]; /*buffer type of parametres */
int index_of_buff_param = 0; /*index of buff_param*/
int function_in_use = 0; /* define the number of the function in the table of symbols*/
int index_of_args = 0; /*Index of arguments tu push */
int nb_function = 0;/*Nb of function declared*/
int caller[MAX_CALL]; /*Number of the function who calls another function */
int nb_calls = 0;


void param_cpy(int src_param[32], int dest_param[32]);
void restore_regs();

void restore_caller(){
	nb_calls--;
	function_in_use = caller[nb_calls];
	printf("RESTORE FUNC_IN_USE:\t%d\nNB_FUNC:\t%d\n",function_in_use,nb_function);
}


void setFunctionInUse(int loc){
	function_in_use = loc;
}
void init_function_in_use(){
	function_in_use = nb_function;
}

int get_index_of_args(){
	return index_of_args;
}

void reset_index_of_args(){
	index_of_args = 0;
}

void push_arg(){
	index_of_args++;
	vm_set(index_of_args);
	vm_swap();
	vm_pop();
	vm_save();
	vm_push();
}

void init_param(int func_addr){
	int i = 0;
	int j = 0;
	for(i = 0;i<NB_SYM  ; i++){
		if(symboles[i].type == 3 && func_addr == symboles[i].addr){
			j = i;
		}
	}
	
	for(i = 0; symboles[j].sign.param[i] != -1 && i<32;i++){
		vm_set(i+1);
		vm_swap();
		vm_set(i+1);
		vm_load();
		vm_alloc(2);
		vm_saver();
	}
}

void print_symbole_debug(){
	int i = 0;
	printf("ID\tADDR\tTYPE\tFONCTION\n");
	for(i = 0; i<NB_SYM; i++){
		printf("%s\t%d\t%d\t%d\n",symboles[i].id,symboles[i].addr,symboles[i].type,symboles[i].loc_func);
	}
	
	printf("FUNC_IN_USE:\t%d\nNB_FUNC:\t%d\n",function_in_use,nb_function);
}

int getNbArg(Sym symbole){
	int nb_arg = 0;
	while(symbole.sign.param[nb_arg] != -1 && nb_arg<32	){
		nb_arg++;
	}
	return nb_arg;
}

Sym* getFunction(char * id){
	int i = 0;
	for(i = 0; i<indexOfSymboles;i++){
		if(strcmp(symboles[i].id,id) == 0 && symboles[i].id!=NULL){
	
	caller[nb_calls] = function_in_use;
	nb_calls++;
	function_in_use = symboles[i].loc_func;
	
	printf("GET FUNC_IN_USE:\t%d\nNB_FUNC:\t%d\n",function_in_use,nb_function);
			return &(symboles[i]);
		}
	}
	return NULL;
}
void insert_param(int type) {
    buff_param[index_of_buff_param] = type;
}

void insertNewVarTop(char * id,int type) {
    int newAddr = getNewAddr(nb_function, symboles, &indexOfSymboles);
    vm_set(newAddr);
    vm_swap();
    vm_pop();
    vm_alloc(2);
    vm_saver();
    insert(id, type, newAddr, nb_function, symboles, &indexOfSymboles);
}

void insertNewVar(char * id, int value, int type) {
    int newAddr = getNewAddr(nb_function, symboles, &indexOfSymboles);
    vm_set(newAddr);
    vm_swap();
    vm_set(value);
    vm_alloc(2);
    vm_saver();
    insert(id, type, newAddr, nb_function, symboles, &indexOfSymboles);
}

void insertNewTab(char * id, int size, int type, int nbdim) {
    int newAddr = getNewAddr(nb_function, symboles, &indexOfSymboles);
    vm_set(newAddr);
    vm_swap();
    vm_alloc(size);
    vm_set(size);
    vm_saver();
    restore_regs();
    int tab[10] = {size, -1};
    char var[255];
    strcpy(var, id);
    insertTab(var, type, newAddr, tab, nb_function, symboles, &indexOfSymboles);
}

int replace_new_var(char * id) {
    char var[255];
    int type = 0;
    strcpy(var, id);
    int addr = getValue(var, function_in_use, symboles, &indexOfSymboles, &type);
    vm_set(addr);
    vm_loadr();
    return type;
}

void div_star_term(char *as) {
    vm_pop();
    vm_swap();
    vm_pop();
    switch (as[0]) {
        case '/':
            vm_div();
            break;
        case '*':
            vm_mul();
            break;
        case '%':
            vm_mod();
            break;
    }
    vm_push();
}

void add_sub_term(char* as) {
    vm_pop();
    vm_swap();
    vm_pop();
    if (as[0] == '+') {
        vm_add();
    } else {
        vm_sub();
    }
    vm_push();
}

void comp_exp_temp(char * comp) {
    if (comp[0] == '=' && comp[1] == '=') {
        exp_bool_choice = 1;
    } else if (comp[0] == '>' && comp[1] == '=') {
        exp_bool_choice = 2;
    } else if (comp[0] == '<' && comp[1] == '=') {
        exp_bool_choice = 3;
    } else if (comp[0] == '!' && comp[1] == '=') {
        exp_bool_choice = 4;
    } else if (comp[0] == '>') {
        exp_bool_choice = 5;
    } else if (comp[0] == '<') {
        exp_bool_choice = 6;
    }
    vm_swap();
    switchExpBool();
}

void switchExpBool() {
    switch (exp_bool_choice) {
        case 1: vm_equal();
            break;
        case 2: vm_geq();
            break;
        case 3: vm_leq();
            break;
        case 4: vm_noteq();
            break;
        case 5: vm_greater();
            break;
        case 6: vm_less();
            break;
    }
    exp_bool_choice = 0;
}

int jump_if(void) {
    //    vm_pop();
    //    vm_swap();
    //    vm_pop();
    //    switchExpBool();
    int ret = jump_label++;
    vm_jumpf(ret);
    return ret;
}

int getNewLabel() {
    return jump_label++;
}

int entetfunc(int type, int* types, char * id) {
    int newLab = getNewLabel();
    insert_function(id, nb_function, type,types, newLab, symboles, &indexOfSymboles);
    return newLab;
}

void incNbFunction() {
    nb_function++;
}

void finish_parameter(){
   	buff_param[index_of_buff_param] = -1;
  	index_of_buff_param = 0;
}

int* select_parameter_to_insert(char test,char* id) {
    int type;
    if (test == 'e') {
        insert_param(1);
        type = 1;
    } else {
        insert_param(2);
        type = 2;
    }      
    
    insert(id, type, getNewAddr(nb_function, symboles, &indexOfSymboles), nb_function, symboles, &indexOfSymboles);
    index_of_buff_param++;
    return buff_param;
}

int* set_void_buffer() {
    buff_param[0] = -1;
    return buff_param;
}

void allocate_stack() {
    vm_alloc(32);
}

void print_value(int type) {
    if (type == 1) {
        vm_write();
        vm_pop();
    } else if (type == 2) {
        vm_writech();
        vm_pop();
    } else {
        printf("type=%d\n", type);
        vm_error("ERROR OF TYPE !");
    }
}

void read_int_val(char * id) {
    int type_of_id = 0;
    int addr = getValue(id, function_in_use, symboles, &indexOfSymboles, &type_of_id);
    if (type_of_id == 1) {
        vm_set(addr);
        vm_swap();
        vm_read();
        vm_saver();
        restore_regs();
    } else {
        vm_error("UNABLE TO READ OTHER THAN A 'ENTIER' IN READ FUNCTION.");
    }
}

void read_char_val(char * id) {
    int type_of_id = 0;
    int addr = getValue(id, function_in_use, symboles, &indexOfSymboles, &type_of_id);
    if (type_of_id == 2) {
        vm_set(addr);
        vm_swap();
        vm_readch();
        vm_saver();
        restore_regs();
    } else {
        vm_error("UNABLE TO READ OTHER THAN A 'ENTIER' IN READ FUNCTION.");
    }
}

void restore_regs() {
    vm_set(0);
    vm_swap();
    vm_set(0);
}

int update_value(char * id) {
    vm_swap();
    int type_of_id = -1;
    int addr = getValue(id, function_in_use, symboles, &indexOfSymboles, &type_of_id);
    vm_set(addr);
    vm_swap();
    vm_saver();
    return type_of_id;
}

void manage_neg() {
    vm_swap();
    vm_set(0);
    vm_equal();
}

void manage_bope(int bopevalue) {
    if (bopevalue == 1) { /* && */
        vm_swap();
        vm_pop();
        vm_pop();
        vm_pop();
        vm_equal();
    } else if (bopevalue == 2) { /* || */
        vm_swap();
        vm_pop();
        vm_pop();
        vm_pop();
        vm_add();
    } else {
        vm_error("UNABLE TO FIND WHAT YOU WANT.");
    }
}

int getValueInTab(char * id, int index, int dim) {
    vm_swap();
    int type_of_id = -1;
    char var[255];
    strncpy(var, id, strlen(id));
    var[strlen(id)] = '\0';
    int addr = getValue(var, function_in_use, symboles, &indexOfSymboles, &type_of_id);
    vm_set(addr);
    vm_add();
    vm_loadr();  
    return type_of_id;
}

int update_tab_value(char * id, int index) {
    restore_regs(); 
    vm_pop();
    vm_swap();
    int type_of_id = -1;
    int addr = getValue(id, function_in_use, symboles, &indexOfSymboles, &type_of_id);
    vm_set(addr + index);
    vm_swap();
    vm_saver();
    return type_of_id;
}
