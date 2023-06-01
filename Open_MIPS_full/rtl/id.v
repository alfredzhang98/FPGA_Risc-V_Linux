module id(
    input                               rst         ,

    //from if_id
    input       [`InstAddrBus]          pc_i        ,
    input       [`InstBus]              inst_i      ,

    //from regfile
    input       [`RegBus]               reg1_data_i ,
    input       [`RegBus]               reg2_data_i ,

    //from ex module
    input                               ex_wreg_i   ,
    input       [`RegBus]               ex_wdata_i  ,
    input       [`RegAddrBus]           ex_wd_i     ,

    //from mem module
    input                               mem_wreg_i  ,
    input       [`RegBus]               mem_wdata_i ,
    input       [`RegAddrBus]           mem_wd_i    ,

    //output to regfile
    output reg                          reg1_read_o ,
    output reg                          reg2_read_o ,
    output reg  [`RegAddrBus]           reg1_addr_o ,
    output reg  [`RegAddrBus]           reg2_addr_o ,

    //to ex
    output reg  [`AluOpBus]             aluop_o     ,
    output reg  [`AluSelBus]            alusel_o    ,
    output reg  [`RegBus]               reg1_o      ,
    output reg  [`RegBus]               reg2_o      ,
    output reg  [`RegAddrBus]           wd_o        ,
    output reg                          wreg_o
);

//*******************defitions***********************//
    wire [5:0] op  = inst_i[31:26];
    wire [4:0] op2 = inst_i[10:6];
    wire [5:0] op3 = inst_i[5:0];
    wire [4:0] op4 = inst_i[20:16];

    reg [`RegBus] imm;

    reg instvalid;

//***************decode for the insturction*********//
    always@(*) begin
        if(rst == `RstEnalbe) begin
            aluop_o     <= `EXE_NOP_OP;
            alusel_o    <= `EXE_RES_NOP;
            wd_o        <= `NOPRegAddr;
            wreg_o      <= `WriteDisable;
            instvalid   <= `InstValid;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= `NOPRegAddr;
            reg2_addr_o <= `NOPRegAddr;
            imm         <= `ZeroWord;
        end
        else begin
            aluop_o     <= `EXE_NOP_OP;
            alusel_o    <= `EXE_RES_NOP;
            wd_o        <= inst_i[15:11];
            wreg_o      <= `WriteDisable;
            instvalid   <= `InstValid;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= inst_i[25:21];
            reg2_addr_o <= inst_i[20:16];
            imm         <= `ZeroWord;


            case (op)
                `EXE_SPECIAL_INST: begin
                    case(op2)
                        5'b00000: begin
                            case(op3)
                                `ENE_AND: begin
                                    aluop_o     <= `EXE_AND_OP;
                                    alusel_o    <= `EXE_RES_LOGIC;
                                    wd_o        <= inst_i[15:11];
                                    wreg_o      <= `WriteEnable;
                                    instvalid   <= `InstValid;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    reg1_addr_o <= inst_i[25:21];
                                    reg2_addr_o <= inst_i[20:16];
                                    imm         <= `ZeroWord;
                                end
                                `EXE_OR: begin
                                    aluop_o     <= `EXE_OR_OP;
                                    alusel_o    <= `EXE_RES_LOGIC;
                                    wd_o        <= inst_i[15:11];
                                    wreg_o      <= `WriteEnable;
                                    instvalid   <= `InstValid;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    reg1_addr_o <= inst_i[25:21];
                                    reg2_addr_o <= inst_i[20:16];
                                    imm         <= `ZeroWord;
                                end
                                `EXE_XOR: begin
                                    aluop_o     <= `EXE_XOR_OP;
                                    alusel_o    <= `EXE_RES_LOGIC;
                                    wd_o        <= inst_i[15:11];
                                    wreg_o      <= `WriteEnable;
                                    instvalid   <= `InstValid;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    reg1_addr_o <= inst_i[25:21];
                                    reg2_addr_o <= inst_i[20:16];
                                    imm         <= `ZeroWord;
                                end
                                `EXE_NOR: begin
                                    aluop_o     <= `EXE_NOR_OP;
                                    alusel_o    <= `EXE_RES_LOGIC;
                                    wd_o        <= inst_i[15:11];
                                    wreg_o      <= `WriteEnable;
                                    instvalid   <= `InstValid;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    reg1_addr_o <= inst_i[25:21];
                                    reg2_addr_o <= inst_i[20:16];
                                    imm         <= `ZeroWord;
                                end
                                `EXE_SLLV: begin
                                    aluop_o     <= `EXE_SLL_OP;
                                    alusel_o    <= `EXE_RES_SHIFT;
                                    wd_o        <= inst_i[15:11];
                                    wreg_o      <= `WriteEnable;
                                    instvalid   <= `InstValid;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    reg1_addr_o <= inst_i[25:21];
                                    reg2_addr_o <= inst_i[20:16];
                                    imm         <= `ZeroWord;
                                end
                                `EXE_SRLV: begin
                                    aluop_o     <= `EXE_SRL_OP;
                                    alusel_o    <= `EXE_RES_SHIFT;
                                    wd_o        <= inst_i[15:11];
                                    wreg_o      <= `WriteEnable;
                                    instvalid   <= `InstValid;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    reg1_addr_o <= inst_i[25:21];
                                    reg2_addr_o <= inst_i[20:16];
                                    imm         <= `ZeroWord;
                                end
                                `EXE_SRAV: begin
                                    aluop_o     <= `EXE_SRA_OP;
                                    alusel_o    <= `EXE_RES_SHIFT;
                                    wd_o        <= inst_i[15:11];
                                    wreg_o      <= `WriteEnable;
                                    instvalid   <= `InstValid;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    reg1_addr_o <= inst_i[25:21];
                                    reg2_addr_o <= inst_i[20:16];
                                    imm         <= `ZeroWord;
                                end
                                `EXE_SYNC: begin
                                    aluop_o     <= `EXE_NOP_OP;
                                    alusel_o    <= `EXE_RES_NOP;
                                    wd_o        <= inst_i[15:11];
                                    wreg_o      <= `WriteDisable;
                                    instvalid   <= `InstValid;
                                    reg1_read_o <= 1'b0;
                                    reg2_read_o <= 1'b1;
                                    reg1_addr_o <= inst_i[25:21];
                                    reg2_addr_o <= inst_i[20:16];
                                    imm         <= `ZeroWord;
                                end
                                `EXE_MFHI: begin
                                    wreg_o      <= `WriteEnable;
                                    aluop_o     <= `EXE_MFHI_OP;
                                    alusel_o    <= `EXE_RES_MOVE;
                                    reg1_read_o <= 1'b0;
                                    reg2_read_o <= 1'b0;
                                    instvalid   <= `InstValid;
                                end
                                `EXE_MFLO: begin
                                    wreg_o      <= `WriteEnable;
                                    aluop_o     <= `EXE_MFLO_OP;
                                    alusel_o    <= `EXE_RES_MOVE;
                                    reg1_read_o <= 1'b0;
                                    reg2_read_o <= 1'b0;
                                    instvalid   <= `InstValid;
                                end
                                `EXE_MTHI: begin
                                    wreg_o      <= `WriteDisable;
                                    aluop_o     <= `EXE_MTHI_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b0;
                                    instvalid   <= `InstValid;
                                end
                                `EXE_MTLO: begin
                                    wreg_o      <= `WriteDisable;
                                    aluop_o     <= `EXE_MTLO_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b0;
                                    instvalid   <= `InstValid;
                                end
                                `EXE_MOVN: begin
                                    aluop_o     <= `EXE_MOVN_OP;
                                    alusel_o    <= `EXE_RES_MOVE;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    instvalid   <= `InstValid;
                                    if(reg2_o != `ZeroWord)
                                        wreg_o <= `WriteEnable;
                                    else
                                        wreg_o <= `WriteDisable;
                                end
                                `EXE_MOVZ: begin
                                    aluop_o     <= `EXE_MOVZ_OP;
                                    alusel_o    <= `EXE_RES_MOVE;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    instvalid   <= `InstValid;
                                    if(reg2_o == `ZeroWord)
                                        wreg_o <=  `WriteEnable;
                                    else
                                        wreg_o <= `WriteDisable;
                                end
                                default: begin
                                end
                            endcase //case(op3)
                        end
                        default: begin
                        end
                    endcase //case(op2)
                end //`EXE_SPECIAL_INST: begin
                `EXE_ORI: begin
                /*instructure sequence of ORI
                   31:26    |   25:21    |  20:16   | 15:0
                   op code  |   rs       |  rt      | immediate  */
                    wreg_o      <= `WriteEnable;
                    aluop_o     <= `EXE_OR_OP;
                    alusel_o    <= `EXE_RES_LOGIC;
                    reg1_read_o <= 1'b1;
                    reg1_addr_o <= inst_i[25:21];
                    reg2_read_o <= 1'b0;
                    reg2_addr_o <= inst_i[20:16];
                    imm         <= {16'b0,inst_i[15:0]};
                    wd_o        <= inst_i[20:16];
                    instvalid   <= `InstValid;
                end
                `EXE_ANDI: begin
                    wreg_o      <= `WriteEnable;
                    aluop_o     <= `EXE_AND_OP;
                    alusel_o    <= `EXE_RES_LOGIC;
                    reg1_read_o <= 1'b1;
                    reg1_addr_o <= inst_i[25:21];
                    reg2_read_o <= 1'b0;
                    reg2_addr_o <= inst_i[20:16];
                    imm         <= {16'b0,inst_i[15:0]};
                    wd_o        <= inst_i[20:16];
                    instvalid   <= `InstValid;
                end
                `EXE_XORI:begin
                    wreg_o      <= `WriteEnable;
                    aluop_o     <= `EXE_XOR_OP;
                    alusel_o    <= `EXE_RES_LOGIC;
                    reg1_read_o <= 1'b1;
                    reg1_addr_o <= inst_i[25:21];
                    reg2_read_o <= 1'b0;
                    reg2_addr_o <= inst_i[20:16];
                    imm         <= {16'b0,inst_i[15:0]};
                    wd_o        <= inst_i[20:16];
                    instvalid   <= `InstValid;
                end
                `EXE_LUI: begin
                    wreg_o      <= `WriteEnable;
                    aluop_o     <= `EXE_OR_OP;
                    alusel_o    <= `EXE_RES_LOGIC;
                    reg1_read_o <= 1'b1;
                    reg1_addr_o <= inst_i[25:21];
                    reg2_read_o <= 1'b0;
                    reg2_addr_o <= inst_i[20:16];
                    imm         <= {inst_i[15:0],16'b0};
                    wd_o        <= inst_i[20:16];
                    instvalid   <= `InstValid;
                end
                default: begin

                end
            endcase //case (op)


            if(inst_i[31:21] == 11'b0) begin
                case(op3)
                    `EXE_SLL: begin
                        aluop_o     <= `EXE_SLL_OP;
                        alusel_o    <= `EXE_RES_SHIFT;
                        wd_o        <= inst_i[15:11];
                        wreg_o      <= `WriteEnable;
                        instvalid   <= `InstValid;
                        reg1_read_o <= 1'b0;
                        reg2_read_o <= 1'b1;
                        reg1_addr_o <= inst_i[25:21];
                        reg2_addr_o <= inst_i[20:16];
                        imm         <= {27'b0,inst_i[10:6]};
                    end
                    `EXE_SRL: begin
                        aluop_o     <= `EXE_SRL_OP;
                        alusel_o    <= `EXE_RES_SHIFT;
                        wd_o        <= inst_i[15:11];
                        wreg_o      <= `WriteEnable;
                        instvalid   <= `InstValid;
                        reg1_read_o <= 1'b0;
                        reg2_read_o <= 1'b1;
                        reg1_addr_o <= inst_i[25:21];
                        reg2_addr_o <= inst_i[20:16];
                        imm         <= {27'b0,inst_i[10:6]};
                    end
                    `EXE_SRA: begin
                        aluop_o     <= `EXE_SRA_OP;
                        alusel_o    <= `EXE_RES_SHIFT;
                        wd_o        <= inst_i[15:11];
                        wreg_o      <= `WriteEnable;
                        instvalid   <= `InstValid;
                        reg1_read_o <= 1'b0;
                        reg2_read_o <= 1'b1;
                        reg1_addr_o <= inst_i[25:21];
                        reg2_addr_o <= inst_i[20:16];
                        imm         <= {27'b0,inst_i[10:6]};
                    end
                    default: begin
                    end
                endcase
            end //if(inst_i[31:21] == 11'b0) begin
        end //else
    end //always

    always @(*) begin
        if (rst) begin
            reg1_o = `ZeroWord;
        end
        else if(reg1_read_o == 1'b1 && ex_wreg_i == 1'b1 && ex_wd_i == reg1_addr_o) begin
            reg1_o = ex_wdata_i;
        end
        else if(reg1_read_o == 1'b1 && mem_wreg_i == 1'b1 && mem_wd_i == reg1_addr_o) begin
            reg1_o = mem_wdata_i;
        end
        else if (reg1_read_o == 1'b1) begin
            reg1_o = reg1_data_i;
        end
        else if(reg1_read_o == 1'b0) begin
            reg1_o = imm;
        end
        else begin
            reg1_o = `ZeroWord;
        end
    end

    always @(*) begin
        if (rst) begin
            reg2_o = `ZeroWord;
        end
        else if(reg2_read_o == 1'b1 && ex_wreg_i == 1'b1 && ex_wd_i == reg2_addr_o) begin
            reg2_o = ex_wdata_i;
        end
        else if(reg2_read_o == 1'b1 && mem_wreg_i == 1'b1 && mem_wd_i == reg2_addr_o) begin
            reg2_o = mem_wdata_i;
        end
        else if (reg2_read_o == 1'b1) begin
            reg2_o = reg2_data_i;
        end
        else if(reg2_read_o == 1'b0) begin
            reg2_o = imm;
        end
        else begin
            reg2_o = `ZeroWord;
        end
    end


endmodule