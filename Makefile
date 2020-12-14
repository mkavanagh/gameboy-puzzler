ifeq ($(OS),Windows_NT)
	DELETE=del
else
	DELETE=rm -f
endif

all: main.gb
	rgbfix -v -p 0 main.gb

main.gb: main.o functions.o vectors.o
	rgblink -o main.gb -m main.map -n main.sym main.o functions.o vectors.o

main.o: main.asm hardware.inc font.chr
	rgbasm -o main.o main.asm

functions.o: functions.asm
	rgbasm -o functions.o functions.asm

vectors.o: vectors.asm
	rgbasm -o vectors.o vectors.asm

clean:
	$(DELETE) *.gb *.map *.sym *.o
