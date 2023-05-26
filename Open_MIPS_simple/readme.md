This is the basic structure of MIPS softcore, which can only realize the instruction of "ori". 

The softcore contains 5-pipline stage, which are instruction fetch, instruction decode, excution, Memory access and Write back.

The project is used in vcs and verdi. You can also copy the rtl and tb and mem file in sim dir into modelsim for simulation


----------------------------------------------------------------
2023.05.26
1. The bug of filelist.py has been fixed. The path of definition.v will be set as the first to avoid error during comp.

2. The makefile in code dir has been modified. The inst_rom.mem will be copy to sim dir automatically once it is generated.


