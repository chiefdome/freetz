BINARY=getText
OBJS=getText.o

all: 
	${CC} ${CFLAGS} -Wall ${LIBS} -o getText getText.c
	${CC} ${CFLAGS} -Wall ${LIBS} -o createDB createDB.c

$(BINARY): $(OBJS)

createDB: createDB.o

clean:
	$(RM) $(BINARY) $(OBJS) createDB createDB.o
