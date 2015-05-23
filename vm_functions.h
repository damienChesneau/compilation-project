/* 
 * File:   vm_functions.h
 * Author: Damien Chesneau <contact@damienchesneau.fr>
 *
 * Created on 23 mai 2015, 07:21
 */

#include <stdio.h>

void vm_alloc(int nb);
void vm_set(int toset);
void vm_jumpf(int label);
void vm_label(int label);
void vm_jump(int label);

void vm_swap();
void vm_pop();
void vm_saver();
void vm_loadr();
void vm_div();
void vm_mul();
void vm_mod();
void vm_push();
void vm_add();
void vm_sub();
void vm_equal();
void vm_geq();
void vm_leq() ;
void vm_noteq();
void vm_greater();
void vm_less();
void vm_read();
void vm_readch();
void vm_write();

void vm_endProgram();
void vm_comment(const char *s);