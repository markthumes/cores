target=a.out
LIBS=-lm
CFLAGS=-Wall -Wextra -ggdb 

a.out: main.o
	g++ -o $@ $< $(LIBS)

main.o: main.c
	g++ -c $< -o $@ $(CFLAGS)
