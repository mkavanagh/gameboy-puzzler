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

main.gb: main.o functions.o vectors.o font.o messages.o graph.o
	$(LINK) -o main.gb -m main.map -n main.sym main.o functions.o vectors.o \
		font.o messages.o graph.o

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

words.o: words.asm
	$(ASM) -o words.o words.asm

clean:
	$(DELETE) *.gb *.map *.sym *.o
