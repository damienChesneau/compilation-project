#ifndef __stdio__
#define __stdio__
#include <stdio.h>
#endif
#include <string.h>
#ifndef __funcTab__
#define __funcTab__

#define TAB_SIZE 1000

typedef struct {
    int type;
    int param[32];
} Signature;

typedef struct {
    char * id;
    int loc_func;
    int type; /*1 int, 2 char, 3 func*/
    int taille;
    int addr;
    int istab; /* 1 -> true*/
    int totalsize;
    int tabinfo[20]; /*i -> nb of dim. * -> length */
    Signature sign;
} Sym;

void insert_function(char * id, int func_in_use, int ret_type, int* param, int addr, Sym s[], int * indexTab);
/**
 New ADDR
 */
void param_cpy(int *src_param, int* dest_param);
void insert(char * id, int type, int addr, int func_in_use, Sym s[], int * indexTab);
void insertTab(char * id, int type, int addr, int dimsize[20], int func_in_use, Sym s[], int * indexTab);
int getValue(char * id, int func_in_use, Sym s[], int * indexTab, int * type);
/**
 * Returns a new addr for your locals variables. 
 * If you want's to have a global var insert a NULL pointer in 
 * First parameter.
 * @param func_name Name of the function.
 * @param s database
 * @param indexTab nb of occurs in database
 * @return a new addr
 */
int getNewAddr(int func_in_use, Sym symbol[], int * indexTab);

#endif
