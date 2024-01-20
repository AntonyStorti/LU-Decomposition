CC = mpicc
CFLAGS = -Wall -Wextra -lm -fopenmp
SRC = main.c Solve_LinearSystems.c
EXEC = Parallelo
SCRIPT = esegui_test.sh

all: $(EXEC) run

$(EXEC): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(EXEC)

run:
	./$(SCRIPT)

clean:
	rm -f $(EXEC)

.PHONY: run clean