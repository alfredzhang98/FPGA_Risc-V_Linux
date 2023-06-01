module ex(
    input                           rst         ,

    input [`AluOpBus]               aluop_i     ,
    input [`AluSelBus]              alusel_i    ,
    input [`RegBus]                 reg1_i      ,
    input [`RegBus]                 reg2_i      ,
    input [`RegAddrBus]             wd_i        ,
    input                           wreg_i      ,

    output reg [`RegAddrBus]        wd_o        ,
    output reg                      wreg_o      ,
    output reg [`RegBus]            wdata_o     ,

    //input from HILO
    input   [`RegBus]               hi_i        ,
    input   [`RegBus]               lo_i        ,

    //data from wb stage
    input   [`RegBus]               wb_hi_i     ,
    input   [`RegBus]               wb_lo_i     ,
    input                           wb_whilo_i  ,

    //data from mem stage
    input   [`RegBus]               mem_hi_i    ,
    input   [`RegBus]               mem_lo_i    ,
    input                           mem_whilo_i ,

    //output to ex_mem
    output  reg [`RegBus]           hi_o        ,
    output  reg [`RegBus]           lo_o        ,
    output  reg                     whilo_o

);

    reg [`RegBus]   logicout;
    reg [`RegBus]   shiftres;
    reg [`RegBus]   moveres;
    reg [`RegBus]   HI;
    reg [`RegBus]   LO;


    always @(*) begin
        if(rst == `RstEnalbe) begin
            HI = `ZeroWord;
            LO = `ZeroWord;
        end
        else if(mem_whilo_i == `WriteEnable) begin
            HI = mem_hi_i;
            LO = mem_lo_i;
        end
        else if(wb_whilo_i == `WriteEnable) begin
            HI = wb_hi_i;
            LO = wb_lo_i;
        end
        else begin
            HI = hi_i;
            LO = lo_i;
        end
    end

    always @(*) begin
        if (rst == `RstEnalbe) begin
            moveres = `ZeroWord;
        end
        else begin
            case(aluop_i)
                `EXE_MFHI_OP: begin
                    moveres = HI;
                end
                `EXE_MFLO_OP: begin
                    moveres = LO;
                end
                `EXE_MOVZ_OP: begin
                    moveres = reg1_i;
                end
                `EXE_MOVN_OP: begin
                    moveres = reg1_i;
                end
                default: begin
                    moveres = `ZeroWord;
                end
            endcase
        end
    end

    always @(*) begin
        if (rst == `RstEnalbe) begin
            logicout = `ZeroWord;
        end
        else begin
            case(aluop_i)
                `EXE_OR_OP: begin
                    logicout = reg1_i | reg2_i;
                end
                `EXE_AND_OP: begin
                    logicout = reg1_i & reg2_i;
                end
                `EXE_NOR_OP: begin
                    logicout = ~(reg1_i | reg2_i);
                end
                `EXE_XOR_OP: begin
                    logicout = reg1_i ^ reg2_i;
                end
                default: begin
                    logicout = `ZeroWord;
                end
            endcase
        end
    end

    always @(*) begin
        if (rst == `RstEnalbe) begin
            shiftres = `ZeroWord;
        end
        else begin
            case(aluop_i)
                `EXE_SLL_OP: begin
                    shiftres = reg2_i << reg1_i[4:0];
                end
                `EXE_SRL_OP: begin
                    shiftres = reg2_i >> reg1_i[4:0];
                end
                `EXE_SRA_OP: begin
                    shiftres = ({32{reg2_i[31]}} << (6'd32 - {1'b0,reg1_i[4:0]})) | (reg2_i >> reg1_i[4:0]);
                end
                default: begin
                    shiftres = `ZeroWord;
                end
            endcase
        end
    end



    always@(*) begin
        wd_o = wd_i;
        wreg_o = wreg_i;
        case(alusel_i)
            `EXE_RES_LOGIC : begin
                wdata_o = logicout;
            end
            `EXE_RES_SHIFT: begin
                wdata_o = shiftres;
            end
            `EXE_RES_MOVE: begin
                wdata_o = moveres;
            end
            default: begin
                wdata_o = `ZeroWord;
            end
        endcase
    end


    always @(*) begin
        if (rst == `RstEnalbe) begin
            whilo_o = `WriteDisable;
            hi_o = `ZeroWord;
            lo_o = `ZeroWord;
        end
        else if (aluop_i == `EXE_MTHI_OP) begin
            whilo_o = `WriteEnable;
            hi_o = reg1_i;
            lo_o = LO;
        end
        else if (aluop_i == `EXE_MTLO_OP) begin
            whilo_o = `WriteEnable;
            hi_o = HI;
            lo_o = reg1_i;
        end
        else begin
            whilo_o = `WriteDisable;
            hi_o = `ZeroWord;
            lo_o = `ZeroWord;
        end
    end




endmodule


