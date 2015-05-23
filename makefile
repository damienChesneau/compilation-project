CC=gcc
CFLAGS=-Wall
LDFLAGS=-Wall -lfl
EXEC=flot

all: $(EXEC) clean

$(EXEC): $(EXEC).o symbols_table.o producer.o vm_functions.o lex.yy.o 
	gcc  -o $@ $^ $(LDFLAGS) 

$(EXEC).c: $(EXEC).y
	bison -d -o $(EXEC).c $(EXEC).y

$(EXEC).h: $(EXEC).c

lex.yy.c: $(EXEC).lex $(EXEC).h
	flex $(EXEC).lex  

%.o: %.c
	gcc -o $@ -c $< $(CFLAGS)

clean:
	rm -f *.o lex.yy.c $(EXEC).[ch]