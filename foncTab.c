#include "foncTab.h"

int getIndex(Sym s[]);

int getNewAddr(char * func_name, Sym s[], int * indexTab){
    int i, new_addr = 1;
    for(i = 0 ; i < *indexTab ; i++){ 
	if(strcmp(s[i].loc_func_name, func_name) == 0){ 
            new_addr++;
        }
    }
    return new_addr;
}
void insert(char * id, int type, int addr, char * func_name, Sym s[], int * indexTab){ 
    if(sizeof(s) != TAB_SIZE ){
        Sym n;
        n.id =   strdup(id);
	n.type = type;
        n.loc_func_name = func_name;
	switch (type){
            case 1: n.taille = sizeof(int);break;
            case 2: n.taille = sizeof(char);break;
            default: n.taille = 0;
	} 
        n.addr = addr;
	s[*indexTab] = n; 
	*indexTab += 1;
    }
}
int getValue(char * id, Sym s[], int * indexTab){
    int i;
    for(i = 0 ; i < getIndex(s) ; i++){    
	if(strcmp(s[i].id, id) == 0){ 
            return s[i].addr;		
        }
    }
    return -1;
}
int getIndex(Sym s[]){
    int i;
    for(i = 0 ; i < 100 ; i++){
        if(s[i].id == NULL){
            return i;
        }
    }
    return 0;
}
void insert_function(char * id, int valeur,Signature sign, int addr, Sym s[], int * indexTab){
    if(sizeof(s) != TAB_SIZE && getValue(id,s, indexTab) == -1){
        Sym n;
	n.id = strdup(id);
	n.type = 3;
	n.taille = 0;
	n.sign = sign;
	n.addr = addr;
	s[*indexTab] = n; 
	*indexTab +=1;
   }
}
