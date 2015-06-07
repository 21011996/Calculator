CXXFLAGS=-g -O0

YASM_FLAGS=-f elf64 -g dwarf2

all: project.o

test: test.o all
	g++ $(CXXFLAGS) -o test test.o project.o


project.o: project.asm
	yasm project.asm $(YASM_FLAGS) -o project.o
