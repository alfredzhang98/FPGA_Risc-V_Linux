//*************************global definitions**************************//
`define RstEnalbe           1'b1            //reset enable
`define RstDisable          1'b0            //reset disable
`define ZeroWord            32'b0
`define WriteEnable         1'b1
`define WriteDisable        1'b0
`define ReadEnable          1'b1
`define ReadDisable         1'b0
`define AluOpBus            7:0             //The width of aluop_o
`define AluSelBus           2:0             //The width of alusel_o
`define InstValid           1'b0            //Instruction valid
`define InstInvalid         1'b1            //INstruction invalid
`define True_v              1'b1            //"True" in logic
`define False_v             1'b0            //"False" in logic
`define ChipEnable          1'b1
`define ChipDisable         1'b0


//**************************Instruction definitions******************//
`define ENE_AND             6'b100100       //THe op3 code of "AND"
`define EXE_OR              6'b100101       //The op3 code of "OR"
`define EXE_XOR             6'b100110       //The op3 code of "XOR"
`define EXE_NOR             6'b100111       //THe op3 code of "NOR"
`define EXE_ANDI            6'b001100       //The op code of "ANDI"
`define EXE_ORI             6'b001101       //The op code of "ORI"
`define EXE_XORI            6'b001110       //THe op code of "XORI"
`define EXE_LUI             6'b001111       //The op code of "LUI"

`define EXE_SLL             6'b000000       //The op3 code of "SLL"
`define EXE_SLLV            6'b000100       //The op3 code of "SLLV"
`define EXE_SRL             6'b000010       //The op3 code of "SRL"
`define EXE_SRLV            6'b000110       //The op3 code of "SRLV"
`define EXE_SRA             6'b000011       //The op3 code of "SRA"
`define EXE_SRAV            6'b000111       //The op3 code of "SRAV"

`define EXE_SYNC            6'b001111       //The op3 code of "SYNC"
`define EXE_PREF            6'b110011       //the op code of "PREF"
`define EXE_SPECIAL_INST    6'b000000       //the op code of "SPECIAL"


`define EXE_NOP             6'b000000       //The op code of "NOP"

`define EXE_MOVZ            6'b001010       //The op3 code of "MOVZ"
`define EXE_MOVN            6'b001011       //The op3 code of "MOVN"
`define EXE_MFHI            6'b010000       //The op3 code of "MFHI"
`define EXE_MTHI            6'b010001       //The op3 code of "MTHI"
`define EXE_MFLO            6'b010010       //The op3 code of "MFLO"
`define EXE_MTLO            6'b010011       //The op3 code of "MTLO"





//AluOp
`define EXE_AND_OP          8'b00100100
`define EXE_OR_OP           8'b00100101
`define EXE_XOR_OP          8'b00100110
`define EXE_NOR_OP          8'b00100111

`define EXE_LUI_OP          8'b01011100

`define EXE_SLL_OP          8'b01111100
`define EXE_SRL_OP          8'b00000010
`define EXE_SRA_OP          8'b00000011

`define EXE_NOP_OP          8'b00000000

`define EXE_MOVZ_OP         8'b00001010
`define EXE_MOVN_OP         8'b00001011
`define EXE_MFHI_OP         8'b00010000
`define EXE_MTHI_OP         8'b00010001
`define EXE_MFLO_OP         8'b00010010
`define EXE_MTLO_OP         8'b00010011


//AluSel
`define EXE_RES_LOGIC       3'b001
`define EXE_RES_SHIFT       3'b010
`define EXE_RES_MOVE        3'b011
`define EXE_RES_NOP         3'b000

//****************Global definitions ablout instruction ROM********************//
`define InstAddrBus         31:0            //The width of address bus
`define InstBus             31:0            //The width of data bus
`define InstMenNum          131071          //The size of Rom
`define InstMemNumLog2      17              //The width of used address bus



//*******************Global definitions about Regfile**************************//
`define RegAddrBus          4:0             //The address width of register
`define RegBus              31:0            //The width of data bus
`define RegWidth            32              //The width of data bus
`define DoubleRegWidth      64              //The width of two reg width
`define DoubleRegBus        63:0
`define RegNum              32              //The number of registers
`define RegNumLog2          5               //The address width
`define NOPRegAddr          5'b00000

