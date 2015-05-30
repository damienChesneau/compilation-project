#include "symbols_table.h"
#include "producer.h"

int getIndex(Sym s[]);

void param_cpy(int* src_param, int* dest_param) {
    int i = 0;
    for (i = 0; i < 32; i++) {
        dest_param[i] = src_param[i];
    }
}

int getNewAddr(int func_in_use, Sym s[], int * indexTab) {
    int i, new_addr = 1;
    for (i = 0; i < *indexTab; i++) {
        if (s[i].loc_func == func_in_use) {
            if (s[i].istab == 1) {
                new_addr += s[i].totalsize;
            } else {
                new_addr++;
            }
        }
    }
    return new_addr;
}

int getNewConstAddr(int func_in_use, Sym s[], int * indexTab) {
    int i, new_addr = PARAMETER_SPACE + 1;
    for (i = 0; i < *indexTab; i++) {
        if (s[i].isconst == 1) {
            new_addr++;
        }
    }
    return new_addr;
}

void insert(char * id, int type, int addr, int func_in_use, Sym s[], int * indexTab, int isconst) {
    if (sizeof (s) != TAB_SIZE) {
        Sym n;
        n.id = strdup(id);
        n.istab = 0;
        n.isconst = isconst;
        n.type = type;
        n.loc_func = func_in_use;
        switch (type) {
            case 1: n.taille = sizeof (int);
                break;
            case 2: n.taille = sizeof (char);
                break;
            default: n.taille = 0;
        }
        n.addr = addr;
        //        printf("-----------------%d\n",n.addr);
        s[*indexTab] = n;
        *indexTab += 1;
    }
}

void insertTab(char * id, int type, int addr, int dimsize[20], int func_in_use, Sym s[], int * indexTab) {
    if (sizeof (s) != TAB_SIZE) {
        Sym n;
        n.id = strdup(id);
        n.istab = 1;
        n.type = type;
        n.loc_func = func_in_use;
        switch (type) {
            case 1: n.taille = sizeof (int);
                break;
            case 2: n.taille = sizeof (char);
                break;
            default: n.taille = 0;
        }
        int b = 0;
        n.totalsize = 1;
        for (b = 0; dimsize[b] != -1; b++) {
            n.tabinfo[b] = dimsize[b];
            n.totalsize *= dimsize[b];
        }
        n.tabinfo[b] = -1;
        n.addr = addr;
        s[*indexTab] = n;
        *indexTab += 1;
    }
}

int getValue(char * id, int func_in_use, Sym s[], int * indexTab, int * type, int * isconst) {
    int i = 0;
    for (i = 0; i < getIndex(s); i++) {
        if (strcmp(s[i].id, id) == 0) {
            if (s[i].loc_func == func_in_use || s[i].loc_func == -1) {
                *type = s[i].type;
                *isconst = s[i].isconst;
                return s[i].addr;
            }
        }
    }
    return -1;
}

int getIndex(Sym s[]) {
    int i;
    for (i = 0; i < 100; i++) {
        if (s[i].id == NULL) {
            return i;
        }
    }
    return 0;
}

void insert_function(char * id, int func_in_use, int ret_type, int* param, int addr, Sym s[], int * indexTab) {
    if (sizeof (s) != TAB_SIZE && getValue(id, func_in_use, s, indexTab, NULL, NULL) == -1) {
        s[*indexTab].id = strdup(id);
        s[*indexTab].loc_func = func_in_use;
        s[*indexTab].type = 3;
        s[*indexTab].taille = 0;
        s[*indexTab].sign.type = ret_type;
        param_cpy(param, s[*indexTab].sign.param);
        s[*indexTab].addr = addr;
        *indexTab += 1;
    }
}
