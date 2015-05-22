#include "producer.h"

int jump_label = 0;
int exp_bool_choice = 0;
Sym symboles[20];
int indexOfSymboles = 0; /* Please do not change initalized val. */
int buff_param[32]; /*buffer of parametres */
int index_of_buff_param = 0; /*index of buff_param*/
int function_in_use; /* define the name of current function. */

void param_cpy(int src_param[32], int dest_param[32]);

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
    instarg("SET", newAddr);
    inst("SWAP");
    instarg("SET", value);
    instarg("ALLOC", 2);
    inst("SAVER");
    insert(id, type, newAddr, function_in_use, symboles, &indexOfSymboles);
}

void replace_new_var(char * id) {
    char var[255];
    strcpy(var, id);
    int addr = getValue(var, function_in_use, symboles, &indexOfSymboles);
    instarg("SET", addr);
    inst("LOADR");
}

void div_star_term(char *as) {
    inst("POP");
    inst("SWAP");
    inst("POP");
    switch (as[0]) {
        case '/':
            inst("DIV");
            break;
        case '*':
            inst("MUL");
            break;
        case '%':
            inst("MOD");
            break;
    }
    inst("PUSH");
}

void add_sub_term(char* as) {
    inst("POP");
    inst("SWAP");
    inst("POP");
    if (as[0] == '+') {
        inst("ADD");
    } else {
        inst("SUB");
    }
    inst("PUSH");
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
}

void switchExpBool() {
    switch (exp_bool_choice) {
        case 1: inst("EQUAL");
            break;
        case 2: inst("GEQ");
            break;
        case 3: inst("LEQ");
            break;
        case 4: inst("NOTEQ");
            break;
        case 5: inst("GREATER");
            break;
        case 6: inst("LESS");
            break;
    }
    exp_bool_choice = 0;
}

int jump_if(void) {
    inst("POP");
    inst("SWAP");
    inst("POP");
    switchExpBool();
    int ret = jump_label++;
    instarg("JUMPF", ret);
    return ret;
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

int getNewLabel() {
    return jump_label++;
}

int entetfunc(int type, char * id, char * id2) {
    Signature sign;
    sign.type = type;
    param_cpy(id, sign.param);
    int newLab = getNewLabel();
    insert_function(id2, function_in_use, sign, newLab, symboles, &indexOfSymboles);
    return newLab;
}

int setFunctionInUse(int val) {
    function_in_use = val;
    return function_in_use;
}

int* select_parameter_to_insert(char test, int more) {
    if (test == 'e') {
        insert_param(1);
    } else {
        insert_param(2);
    }
    if(more==1 ){
        index_of_buff_param++;
    }else{
        index_of_buff_param = 0;
    }
    return buff_param;
}
int* set_void_buffer(){
    buff_param[0] = -1; 
    return buff_param;
}
void initialize_buffer_index(){
    index_of_buff_param = 0;
}
void allocate_stack(){
    instarg("ALLOC", 1);
}