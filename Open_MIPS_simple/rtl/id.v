module id(
    input                               rst         ,

    //from if_id
    input       [`InstAddrBus]          pc_i        ,
    input       [`InstBus]              inst_i      ,

    //from regfile
    input       [`RegBus]               reg1_data_i ,
    input       [`RegBus]               reg2_data_i ,

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
    wire [5:0] op = inst_i[31:26];
    wire [4:0] op2 = inst_i[10:6];
    wire [5:0] op3 = inst_i[5:0];
    wire [4:0] op4 = inst_i[20:16];

    reg [`RegBus] imm;

    reg instvalid;

//***************decode for the insturction*********//
    always@(*) begin
        if(rst == `RstEnalbe) begin
            aluop_o     = `EXE_NOP_OP;
            alusel_o    = `EXE_RES_NOP;
            wd_o        = `NOPRegAddr;
            wreg_o      = `WriteDisable;
            instvalid   = `InstValid;
            reg1_read_o = 1'b0;
            reg2_read_o = 1'b0;
            reg1_addr_o = `NOPRegAddr;
            reg2_addr_o = `NOPRegAddr;
            imm         = `ZeroWord;
        end
        else begin
            //aluop_o     = `EXE_NOP_OP;
            //alusel_o    = `EXE_RES_NOP;
            //wd_o        = inst_i[15:11];
            //wreg_o      = `WriteDisable;
            //instvalid   =` InstValid;
            //reg1_read_o = 1'b0;
            //reg2_read_o = 1'b0;
            //reg1_addr_o = inst_i[25:21];
            //reg2_addr_o = inst_i[20:16];
            //imm         = `ZeroWord;

            case (op)
                `EXE_ORI: begin
                /*instructure sequence of ORI
                   31:26    |   25:21    |  20:16   | 15:0
                   op code  |   rs       |  rt      | immediate  */
                    wreg_o = `WriteEnable;
                    aluop_o = `EXE_OR_OP;
                    alusel_o = `EXE_RES_LOGIC;
                    reg1_read_o = 1'b1;
                    reg1_addr_o = inst_i[25:21];
                    reg2_read_o = 1'b0;
                    reg2_addr_o = inst_i[20:16];
                    imm = {16'b0,inst_i[15:0]};
                    wd_o = inst_i[20:16];
                    instvalid = `InstValid;
                end
                default: begin
                    aluop_o     = `EXE_NOP_OP;
                    alusel_o    = `EXE_RES_NOP;
                    wd_o        = `NOPRegAddr;
                    wreg_o      = `WriteDisable;
                    instvalid   = `InstValid;
                    reg1_read_o = 1'b0;
                    reg2_read_o = 1'b0;
                    reg1_addr_o = `NOPRegAddr;
                    reg2_addr_o = `NOPRegAddr;
                    imm         = `ZeroWord;
                end
            endcase
        end
    end

    always @(*) begin
        if (rst) begin
            reg1_o = `ZeroWord;

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