CXXFLAGS=-g -O0

YASM_FLAGS=-f elf64 -g dwarf2

all: tester.o

test: test.o all
	g++ $(CXXFLAGS) -o test test.o tester.o -lgmp


tester.o: tester.asm
	yasm tester.asm $(YASM_FLAGS) -o tester.o