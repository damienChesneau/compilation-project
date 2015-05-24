#include "producer.h"

int jump_label = 0;
int exp_bool_choice = 0;
Sym symboles[20];
int indexOfSymboles = 0; /* Please do not change initalized val. */
int buff_param[32]; /*buffer type of parametres */
int index_of_buff_param = 0; /*index of buff_param*/
int function_in_use = 0; /* define the number of the function in the table of symbols. Never decrease, always increase, 0 is for global variables */
char temp_id[32][256];

void init_param() {
    int i = 0;
    while (buff_param[i] != -1) {
        insertNewVar(temp_id[i], 0, buff_param[i]);
        i++;
    }
}


void param_cpy(int src_param[32], int dest_param[32]);
void restore_regs();

void insert_param(int type) {
    buff_param[index_of_buff_param] = type;
}

void param_cpy(int src_param[32], int dest_param[32]) {
    int i = 0;
    for (i = 0; i < 32; i++) {
        dest_param = src_param;
    }
}

void insertNewVar(char * id, int value, int type) {
    int newAddr = getNewAddr(function_in_use, symboles, &indexOfSymboles);
    vm_set(newAddr);
    vm_swap();
    vm_set(value);
    vm_alloc(2);
    vm_saver();
    insert(id, type, newAddr, function_in_use, symboles, &indexOfSymboles);
}

void insertNewTab(char * id, int size, int type, int nbdim) { 
    int newAddr = getNewAddr(function_in_use, symboles, &indexOfSymboles);
    vm_set(newAddr);
    vm_swap();
    vm_alloc(size);
    vm_set(size);
    vm_saver();
    restore_regs();
    int tab[10] = {size, -1};
    char var[255];
    strcpy(var, id); 
    insertTab(var, type, newAddr, tab, function_in_use, symboles, &indexOfSymboles);
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
    Signature sign;
    sign.type = type;
    param_cpy(types, sign.param);
    int newLab = getNewLabel();
    insert_function(id, function_in_use, sign, newLab, symboles, &indexOfSymboles);
    return newLab;
}

void incFunctionInUse() {
    function_in_use++;
}

int* select_parameter_to_insert(char test, int more, char* id) {
    if (test == 'e') {
        insert_param(1);
    } else {
        insert_param(2);
    }
    strncpy(temp_id[index_of_buff_param], id, 256);

    if (more == 1) {
        index_of_buff_param++;
    } else {
        buff_param[index_of_buff_param + 1] = -1;
        index_of_buff_param = 0;
    }
    return buff_param;
}

int* set_void_buffer() {
    buff_param[0] = -1;
    return buff_param;
}

void allocate_stack() {
    vm_alloc(1);
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
    if (bopevalue == 1) {
        vm_swap();
        vm_pop();
        vm_pop();
        vm_pop();
        vm_equal();
    } else if (bopevalue == 2) {
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
    int type_of_id = -1;
    char var[255];
    strncpy(var,id, strlen(id));
    int addr = getValue(var, function_in_use, symboles, &indexOfSymboles, &type_of_id);
    vm_set(addr+index);
    vm_swap();
    vm_loadr();
    return INTEGER;
}