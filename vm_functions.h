/* 
 * File:   vm_functions.h
 * Author: Damien Chesneau <contact@damienchesneau.fr>
 *
 * Created on 23 mai 2015, 07:21
 */

#include <stdio.h>
/*
 * Alloue nb emplacements suppl´ementaires en tete de pile
 */
void vm_alloc(int nb);
/*
 * reg1 = toset
 */
void vm_set(int toset);
/*
 * Libere n emplacements en tete de pile
 */
void vm_free(int n);

/*
 * Branchement `a l’emplacement du label n dans le segment de code
si reg1 vaut 0
 */
void vm_jumpf(int label);
/*
 * D´eclare le label numero n
 */
void vm_label(int label);
/*
 * Branchement `a l’emplacement du label n dans le segment de code
 */
void vm_jump(int label);
/*
 *  Echange les valeurs de reg1 et reg2
 */
void vm_swap();
/*
 * Place la valeur en tˆete de pile dans reg1 et d´epile
 */
void vm_pop();
/*
 * Stocke la valeur de reg1 a l’adresse base+reg2 de la pile
 */
void vm_saver();
/*
 * Place dans reg1 la valeur situee `a l’adresse reg1+base de la pile
 */
void vm_loadr();
/**
 * reg1←reg1/reg2
 */
void vm_div();
/**
 * reg1←reg1∗reg2
 */
void vm_mul();
/**
 * reg1←reg1%reg2
 */
void vm_mod();
/*
 * Place la valeur de reg1 sur la pile
 */
void vm_push();
/**
 * reg1←reg1+reg2
 */
void vm_add();
/**
 * reg1←reg1−reg2
 */
void vm_sub();
/*
 * reg1←reg1=reg2
 */
void vm_equal();
/*
 * reg1←reg1>reg2
 */
void vm_geq();
/**
 * : reg1←reg16reg2
 */
void vm_leq() ;
/*
 *  reg1←reg16=reg2
 */
void vm_noteq();
/**
 * reg1←reg1>reg2
 */
void vm_greater();
/*
 * reg1←reg1<reg2
 */
void vm_less();
/*
 *  Lit un entier et le stocke en reg1
 */
void vm_read();
/*
 * Lit un caract`ere et le stocke en reg1 (comme entier)
 */
void vm_readch();
/*
 * Affiche la valeur stock´ee en reg1
 */
void vm_write();
/*
 * Affiche le contenu de reg1 vu comme un caractere
 */
void vm_writech();
/*
 *  reg1← −reg1
 */
void vm_neg();
/*
 * Fin du programme.
 */
void vm_endProgram();
/*
 * comment
 */
void vm_comment(const char *s);
/*
 * Print your message 
 */
void vm_error(char * message);
/*
	Call the function at the label n
*/
void vm_call(int n);
