//********************global definitions********************//
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


//***********Global definitions about instructions**********//
`define EXE_ORI             6'b001101       //The op code of "ORI"
`define EXE_NOP             6'b000000       //The op code of "NOP"


//AluOp
`define EXE_OR_OP           8'b00100101
`define EXE_NOP_OP          8'b00000000

//AluSel
`define EXE_RES_LOGIC       3'b001

`define EXE_RES_NOP         3'b000

//******Global definitions ablout instruction ROM**********//
`define InstAddrBus         31:0            //The width of address bus
`define InstBus             31:0            //The width of data bus
`define InstMenNum          131071          //The size of Rom
`define InstMemNumLog2      17              //The width of used address bus



//*********Global definitions about Regfile****************//
`define RegAddrBus          4:0             //The address width of register
`define RegBus              31:0            //The width of data bus
`define RegWidth            32              //The width of data bus
`define DoubleRegWidth      64              //The width of two reg width
`define DoubleRegBus        63:0
`define RegNum              32              //The number of registers
`define RegNumLog2          5               //The address width
`define NOPRegAddr          5'b00000