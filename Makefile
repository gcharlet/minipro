CC = gcc

CFLAGS = -std=c99 -g

all: iimp

%o: %c
	$(CC) $(CFLAGS) -c -o $@ $<

%tab.c %tab.h: %y
	bison -d $<

%.l.c: %.l
	flex -o $@ $<

clean:
	rm iimp.tab* iimp.y.c iimp.l.c
	rm *.o

environ.o: environ.c environ.h
bilquad.o: bilquad.c environ.h bilquad.h
arbre_imp.o: arbre_imp.c arbre_imp.h environ.h
iimp.y.c: iimp.tab.c
	cp iimp.tab.c iimp.y.c
iimp.l.o: iimp.l.c iimp.tab.h environ.h
iimp: iimp.y.o iimp.l.o environ.o arbre_imp.o bilquad.o
	$(CC) $(CFLAGS) iimp.y.o iimp.l.o environ.o arbre_imp.o bilquad.o -o $@ -lfl
