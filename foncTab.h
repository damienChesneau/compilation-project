#ifndef __stdio__
#define __stdio__
#include <stdio.h>
#endif
#include <string.h>
#ifndef __funcTab__
#define __funcTab__

#define TAB_SIZE 20


typedef struct{
	int type;
	int param[32];
} Signature;


typedef struct {
	char * id;
        char * loc_func_name;
	int type;
	int taille;
	int addr;
	Signature sign;
} Sym;

void insert_function(char * id, int valeur, Signature sign, int addr, Sym s[], int * indexTab);
/**
 New ADDR
 */
void insert(char * id, int type, int valeur, Sym s[], int * indexTab);
int getValue(char * id, Sym s[], int indexTab);
/**
 * Returns a new addr for your locals variables. 
 * If you want's to have a global var insert a NULL pointer in 
 * First parameter.
 * @param func_name Name of the function.
 * @param s database
 * @param indexTab nb of occurs in database
 * @return a new addr
 */
int getNewAddr(char * func_name, Sym symbol[], int * indexTab);

#endif
