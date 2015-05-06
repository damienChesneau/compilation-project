#include "foncTab.h"


int getNewAddr(char * func_name, Sym s[], int * indexTab){
    int i, new_addr = 0;
    for(i = 0 ; i < *indexTab ; i++){ 
	if(strcmp(s[i].loc_func_name, func_name) == 0){ 
            new_addr++;
        }
    }
    return new_addr;
}
void insert(char * id, int type, int addr, Sym s[], int * indexTab){
    if(sizeof(s) != TAB_SIZE && getValue(id,s, *indexTab) == -1){
        Sym n;
        n.id = id;
	n.type = type;
	switch (type){
            case 1: n.taille = sizeof(int);break;
            case 2: n.taille = sizeof(char);break;
            default: n.taille = 0;
	} 
        n.addr = addr;
	s[*indexTab] = n; 
	*indexTab +=1;
    }
}
int getValue(char * id, Sym s[], int indexTab){
    int i;
    for(i = 0 ; i < indexTab ; i++){ 
	if(strcmp(s[i].id, id) == 0){ 
            return s[i].addr;		
        }
    }
    return -1;
}

void insert_function(char * id, int valeur,Signature sign, int addr, Sym s[], int * indexTab){
    if(sizeof(s) != TAB_SIZE && getValue(id,s,*indexTab) == -1){
        Sym n;
	n.id = id;
	n.type = 3;
	n.taille = 0;
	n.sign = sign;
	n.addr = addr;
	s[*indexTab] = n; 
	*indexTab +=1;
   }
}
