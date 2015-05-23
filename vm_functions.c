#include "vm_functions.h"

void inst(const char *s);
void instarg(const char *s, int n);

void vm_alloc(int nb) {
    instarg("ALLOC", nb);
}

void vm_set(int toset) {
    instarg("SET", toset);
}

void vm_swap() {
    inst("SWAP");
}

void vm_pop() {
    inst("POP");
}

void vm_saver() {
    inst("SAVER");
}

void vm_loadr() {
    inst("LOADR");
}

void vm_div() {
    inst("DIV");
}

void vm_mul() {
    inst("MUL");
}

void vm_mod() {
    inst("MOD");
}

void vm_push() {
    inst("PUSH");
}

void vm_add() {
    inst("ADD");
}

void vm_sub() {
    inst("SUB");
}

void vm_equal() {
    inst("EQUAL");
}

void vm_geq() {
    inst("GEQ");
}

void vm_leq() {
    inst("LEQ");
}

void vm_noteq() {
    inst("NOTEQ");
}

void vm_less() {
    inst("LESS");
}

void vm_greater() {
    inst("GREATER");
}

void vm_jumpf(int label) {
    instarg("JUMPF", label);
}

void vm_label(int label) {
    instarg("LABEL", label);
}

void vm_jump(int label) {
    instarg("JUMP", label);
}

void vm_read() {
    inst("READ");
}

void vm_readch() {
    inst("READCH");
}

void vm_write() {
    inst("WRITE");
}

void vm_writech() {
    inst("WRITECH");
}

void vm_free(int n){
    instarg("FREE",n);
}

void vm_endProgram() {
    printf("HALT\n");
}

void vm_comment(const char *s) {
    printf("#%s\n", s);
}

void vm_error(char * message) {
    printf("!!! ERROR -> %s\n", message);
}

void inst(const char *s) {
    printf("%s\n", s);
}

void instarg(const char *s, int n) {
    printf("%s\t%d\n", s, n);
}


