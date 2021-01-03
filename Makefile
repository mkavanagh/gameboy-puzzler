ASM=rgbasm --halt-without-nop --preserve-ld
LINK=rgblink
FIX=rgbfix --validate --pad-value 0

ifeq ($(OS),Windows_NT)
	DELETE=del
else
	DELETE=rm -f
endif

all: main.gb
	$(FIX) main.gb

main.gb: main.o functions.o vectors.o font.o messages.o graph.o puzzle.o \
	dictionary.o

	$(LINK) -o main.gb -m main.map -n main.sym main.o functions.o vectors.o \
		font.o messages.o graph.o puzzle.o dictionary.o

main.o: main.asm hardware.inc lcd.inc font.chr
	$(ASM) -o main.o main.asm

functions.o: functions.asm
	$(ASM) -o functions.o functions.asm

vectors.o: vectors.asm
	$(ASM) -o vectors.o vectors.asm

font.o: font.asm
	$(ASM) -o font.o font.asm

messages.o: messages.asm
	$(ASM) -o messages.o messages.asm

graph.o: graph.asm graph.inc
	$(ASM) -o graph.o graph.asm

puzzle.o: puzzle.asm
	$(ASM) -o puzzle.o puzzle.asm

dictionary.o: dictionary.asm
	$(ASM) -o dictionary.o dictionary.asm

dictionary.asm: generate-dictionary.py
	python generate-dictionary.py > dictionary.asm

clean:
	$(DELETE) *.gb *.map *.sym *.o dictionary.asm
