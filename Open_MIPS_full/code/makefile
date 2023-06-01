all:
	make comp
	make connect
	make get_rom
	make translate
	cp ./inst_rom.mem ./../sim/.
comp: inst_rom.S
	mips-linux-gnu-as -mips32 inst_rom.S -o inst_rom.o
connect: 
	mips-linux-gnu-ld -T ram.ld inst_rom.o -o inst_rom.om
get_rom:
	mips-linux-gnu-objcopy -O binary inst_rom.om inst_rom.bin
translate:
	./bin_to_mem.py

read:
	mips-linux-gnu-readelf -S inst_rom.o

clear:
	rm *.o *.om *.bin *.mem -rf