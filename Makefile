main: main.gb
	rgbfix -v -p 0 main.gb

main.gb: main.o
	rgblink -o main.gb -m main.map -n main.sym main.o

main.o: main.asm hardware.inc font.chr
	rgbasm -o main.o main.asm

clean:
	rm -rf main.gb main.map main.sym main.o
