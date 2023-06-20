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
`define InDelaySlot         1'b1
`define NotInDelaySlot      1'b0
`define Branch              1'b1
`define NotBranch           1'b0


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



`define EXE_NOP             6'b000000       //The op code of "NOP"

`define EXE_MOVZ            6'b001010       //The op3 code of "MOVZ"
`define EXE_MOVN            6'b001011       //The op3 code of "MOVN"
`define EXE_MFHI            6'b010000       //The op3 code of "MFHI"
`define EXE_MTHI            6'b010001       //The op3 code of "MTHI"
`define EXE_MFLO            6'b010010       //The op3 code of "MFLO"
`define EXE_MTLO            6'b010011       //The op3 code of "MTLO"

`define EXE_SLT             6'b101010       //The op3 code of "SLT"
`define EXE_SLTU            6'b101011       //The op3 code of "SLTU"
`define EXE_SLTI            6'b001010       //The op code of "SLTI"
`define EXE_SLTIU           6'b001011       //The op code of "SLTIU"
`define EXE_ADD             6'b100000       //The op3 code of "ADD"
`define EXE_ADDU            6'b100001       //The op3 code of "ADDU"
`define EXE_SUB             6'b100010       //The op3 code of "SUB"
`define EXE_SUBU            6'b100011       //The op3 code of "SUBBU"
`define EXE_ADDI            6'b001000       //The op code of "ADDI"
`define EXE_ADDIU           6'b001001       //The op code of "ADDIU"
`define EXE_CLZ             6'b100000       //The op3 code of "CLZ"
`define EXE_CLO             6'b100001       //ThE op3 code of "CLO"

`define EXE_MULT            6'b011000       //The op3 code of "MULT"
`define EXE_MULTU           6'b011001       //The op3 code of "MULTU"
`define EXE_MUL             6'b000010       //The op3 code of "MUL"
`define EXE_MADD            6'b000000       //The op3 code of "MADD"
`define EXE_MADDU           6'b000001       //The op3 code of "MADDU"
`define EXE_MSUB            6'b000100       //The op3 code of "MSUB"
`define EXE_MSUBU           6'b000101       //The op3 code of "MSUBU"

`define EXE_J               6'b000010
`define EXE_JAL             6'b000011
`define EXE_JALR            6'b001001
`define EXE_JR              6'b001000
`define EXE_BEQ             6'b000100
`define EXE_BGEZ            5'b00001
`define EXE_BGEZAL          5'b10001
`define EXE_BGTZ            6'b000111
`define EXE_BLEZ            6'b000110
`define EXE_BLTZ            5'b00000
`define EXE_BLTZAL          5'b10000
`define EXE_BNE             6'b000101

`define EXE_LB              6'b100000
`define EXE_LBU             6'b100100
`define EXE_LH              6'b100001
`define EXE_LHU             6'b100101
`define EXE_LL              6'b110000
`define EXE_LW              6'b100011
`define EXE_LWL             6'b100010
`define EXE_LWR             6'b100110
`define EXE_SB              6'b101000
`define EXE_SC              6'b111000
`define EXE_SH              6'b101001
`define EXE_SW              6'b101011
`define EXE_SWL             6'b101010
`define EXE_SWR             6'b101110

`define EXE_DIV             6'b011010       //The op3 code of "DIV"
`define EXE_DIVU            6'b011011       //The op3 code of "DIVU"



`define EXE_SPECIAL_INST    6'b000000       //The op code of "SPECIAL"
`define EXE_REGIMM_INST     6'b000001
`define EXE_SPECIAL2_INST   6'b011100       //The op code of "SPECIAL2"


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


`define EXE_SLT_OP          8'b00101010
`define EXE_SLTU_OP         8'b00101011
`define EXE_SLTI_OP         8'b01010111
`define EXE_SLTIU_OP        8'b01011000
`define EXE_ADD_OP          8'b00100000
`define EXE_ADDU_OP         8'b00100001
`define EXE_SUB_OP          8'b00100010
`define EXE_SUBU_OP         8'b00100011
`define EXE_ADDI_OP         8'b01010101
`define EXE_ADDIU_OP        8'b01010110
`define EXE_CLZ_OP          8'b10110000
`define EXE_CLO_OP          8'b10110001

`define EXE_MULT_OP         8'b00011000
`define EXE_MULTU_OP        8'b00011001
`define EXE_MUL_OP          8'b10101001
`define EXE_MADD_OP         8'b10100110
`define EXE_MADDU_OP        8'b10101000
`define EXE_MSUB_OP         8'b10101010
`define EXE_MSUBU_OP        8'b10101011
`define EXE_MADDU_OP        8'b10101000
`define EXE_MSUB_OP         8'b10101010
`define EXE_MSUBU_OP        8'b10101011

`define EXE_DIV_OP          8'b00011010
`define EXE_DIVU_OP         8'b00011011

`define EXE_J_OP            8'b01001111
`define EXE_JAL_OP          8'b01010000
`define EXE_JALR_OP         8'b00001001
`define EXE_JR_OP           8'b00001000
`define EXE_BEQ_OP          8'b01010001
`define EXE_BGEZ_OP         8'b01000001
`define EXE_BGEZAL_OP       8'b01001011
`define EXE_BGTZ_OP         8'b01010100
`define EXE_BLEZ_OP         8'b01010011
`define EXE_BLTZ_OP         8'b01000000
`define EXE_BLTZAL_OP       8'b01001010
`define EXE_BNE_OP          8'b01010010

`define EXE_LB_OP           8'b11100000
`define EXE_LBU_OP          8'b11100100
`define EXE_LH_OP           8'b11100001
`define EXE_LHU_OP          8'b11100101
`define EXE_LL_OP           8'b11110000
`define EXE_LW_OP           8'b11100011
`define EXE_LWL_OP          8'b11100010
`define EXE_LWR_OP          8'b11100110
`define EXE_PREF_OP         8'b11110011
`define EXE_SB_OP           8'b11101000
`define EXE_SC_OP           8'b11111000
`define EXE_SH_OP           8'b11101001
`define EXE_SW_OP           8'b11101011
`define EXE_SWL_OP          8'b11101010
`define EXE_SWR_OP          8'b11101110
`define EXE_SYNC_OP         8'b00001111




//AluSel
`define EXE_RES_LOGIC       3'b001
`define EXE_RES_SHIFT       3'b010
`define EXE_RES_MOVE        3'b011
`define EXE_RES_NOP         3'b000
`define EXE_RES_LOAD_STORE  3'b111


`define EXE_RES_ARITHMETIC  3'b100
`define EXE_RES_MUL         3'b101
`define EXE_RES_JUMP_BRANCH 3'b110



//****************Global definitions ablout instruction ROM********************//
`define InstAddrBus         31:0            //The width of address bus
`define InstBus             31:0            //The width of data bus
`define InstMenNum          131071          //The size of Rom
`define InstMemNumLog2      17              //The width of used address bus

//****************Global definitions ablout instruction RAM********************//
`define DataAddrBus         31:0
`define DataBus             31:0
`define DataMemNum          5
`define DataMemNumLog2      17
`define ByteWidth           7:0



//*******************Global definitions about Regfile**************************//
`define RegAddrBus          4:0             //The address width of register
`define RegBus              31:0            //The width of data bus
`define RegWidth            32              //The width of data bus
`define DoubleRegWidth      64              //The width of two reg width
`define DoubleRegBus        63:0
`define RegNum              32              //The number of registers
`define RegNumLog2          5               //The address width
`define NOPRegAddr          5'b00000

//**************Global definitions about pipeline ctrl************************//
`define Stop                1'b1
`define NoStop              1'b0


//**************Global definitions about div*********************************//
`define DivFree             2'b00
`define DivByZero           2'b01
`define DivOn               2'b10
`define DivEnd              2'b11
`define DivResultReady      1'b1
`define DivResultNotReady   1'b0
`define DivStart            1'b1
`define DivStop             1'b0

