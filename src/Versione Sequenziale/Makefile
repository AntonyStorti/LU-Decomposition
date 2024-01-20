CC = gcc-13
CFLAGS = -Wall -Wextra
SRC = main.c Solve_LinearSystems.c
EXEC = LU_Sequenziale
SCRIPT = esegui_test.sh

all: $(EXEC) run

$(EXEC): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(EXEC)

run:
	./$(SCRIPT)

clean:
	rm -f $(EXEC)

.PHONY: run clean
