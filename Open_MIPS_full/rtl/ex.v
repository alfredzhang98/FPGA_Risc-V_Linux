//author: Kieran
//changed date 10 Jun 2023
//
//Function descrition:
//This file realizes the function of the excution of instructions
//

module ex(
    input                           rst         ,

    //The decode information from id
    input [`AluOpBus]               aluop_i     ,
    input [`AluSelBus]              alusel_i    ,
    input [`RegBus]                 reg1_i      ,
    input [`RegBus]                 reg2_i      ,
    input [`RegAddrBus]             wd_i        ,
    input                           wreg_i      ,
    input [`RegBus]                 link_address_i,
    input                           is_in_delayslot_i,
    input [`RegBus]                 inst_i      ,

    //The temp value from ex_mem for MADD, MADDU, MSUB, MSUBU
    input [`DoubleRegBus]           hilo_temp_i ,
    input [1:0]                     cnt_i       ,

    //control write of regfiles
    output reg [`RegAddrBus]        wd_o        ,
    output reg                      wreg_o      ,
    output reg [`RegBus]            wdata_o     ,

    //for multi cycle instructions
    output reg [`DoubleRegBus]      hilo_temp_o ,
    output reg [1:0]                cnt_o       ,

    //input from HILO
    input [`RegBus]                 hi_i        ,
    input [`RegBus]                 lo_i        ,

    //data from wb stage
    input [`RegBus]                 wb_hi_i     ,
    input [`RegBus]                 wb_lo_i     ,
    input                           wb_whilo_i  ,

    //data from mem stage
    input [`RegBus]                 mem_hi_i    ,
    input [`RegBus]                 mem_lo_i    ,
    input                           mem_whilo_i ,

    //output to ex_mem
    output reg [`RegBus]            hi_o        ,
    output reg [`RegBus]            lo_o        ,
    output reg                      whilo_o     ,
    output [`AluOpBus]              aluop_o     ,
    output [`RegBus]                mem_addr_o  ,
    output [`RegBus]                reg2_o      ,

    //to ctrl
    output reg                      stallreq    ,

    //connection with div module
    input [`DoubleRegBus]           div_result_i,
    input                           div_ready_i ,

    output reg [`RegBus]            div_opdata1_o,
    output reg [`RegBus]            div_opdata2_o,
    output reg                      div_start_o ,
    output reg                      signed_div_o
);

//**********Contents of the file**************************//
//
//  Part 1. Definitions
//  Part 2. The excution of logic instructions
//  Part 3. The excution of shift instructions
//  Part 4. The excution of mov instructions
//  Part 5. The logic of latest HILO and the output of HILO
//  Part 6. The logics of arithmetic
//  Part 7. The logics of mul
//  Part 8. The logics of MADD, MADDU, MSUB, MSUBU and stallreq_for_madd_msub
//  Part 9. The logic of controlling div module and stallreq_for_div
//  Part 10. The logic of write back output
//  Part 11. The mux of stallreq
//  Part 12. The logics of load (from) and save (to) ram
//

//***********Part 1. Definitions*************************//

    reg [`RegBus]           logicout;
    reg [`RegBus]           shiftres;
    reg [`RegBus]           moveres;
    reg [`RegBus]           HI;
    reg [`RegBus]           LO;

    wire                    ov_sum;         //store the value of overflow
    wire                    reg1_eq_reg2;   //justify whether reg1 == reg2
    wire                    reg1_lt_reg2;   //justify whether reg1 < reg2
    reg [`RegBus]           arithmeticres;  //Store the value of arithemetric
    wire [`RegBus]          reg2_i_mux;     //The 2's complement of reg2
    wire [`RegBus]          reg1_i_not;     //The 1's complement of reg1
    wire [`RegBus]          result_sum;     //The result of sum operation
    wire [`RegBus]          opdata1_mult;
    wire [`RegBus]          opdata2_mult;
    wire [`DoubleRegBus]    hilo_temp;      //Store the mul outcome temporarily
    reg [`DoubleRegBus]     hilo_temp1;     //Store the madd, maddu, msub, msubu temporarily
    reg [`DoubleRegBus]     mulres;         //Store the mul outcome

    //stalling signals
    reg                     stallreq_for_madd_msub;
    reg                     stallreq_for_div;


//****Part 2. The excution of logic instructions*****//
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

//****Part 3. The excution of shift instructions*****//
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


//****Part 4. The excution of mov instructions*****//
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


//*******Part 5. The logic of latest HILO and the output of HILO****//
//The logic of HI and LO, which store the latest value of hilo reg
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

    //The logic of hilo output
    always @(*) begin
        if (rst == `RstEnalbe) begin
            whilo_o = `WriteDisable;
            hi_o = `ZeroWord;
            lo_o = `ZeroWord;
        end
        else if((aluop_i == `EXE_DIV_OP) || (aluop_i == `EXE_DIVU_OP)) begin
            whilo_o = `WriteEnable;
            hi_o = div_result_i[63:32];
            lo_o = div_result_i[31:0];
        end
        else if((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)) begin
            whilo_o = `WriteEnable;
            hi_o = mulres[63:32];
            lo_o = mulres[31:0];
        end
        else if((aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MADDU_OP)) begin
            whilo_o <= `WriteEnable;
            hi_o <= hilo_temp1[63:32];
            lo_o <= hilo_temp1[31:0];
        end
        else if((aluop_i == `EXE_MSUB_OP) || (aluop_i == `EXE_MSUBU_OP)) begin
            whilo_o <= `WriteEnable;
            hi_o <= hilo_temp1[63:32];
            lo_o <= hilo_temp1[31:0];
        end
        else if (aluop_i == `EXE_MTHI_OP) begin
            whilo_o = `WriteEnable;
            hi_o = reg1_i;
            lo_o = LO;
        end
        else if(aluop_i == `EXE_MTLO_OP) begin
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


//*****************Part 6. The logics of arithmetic******************//
    //for sub instructions, calculate the 2's componment of the second
    // op data
    assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP)  ||
                         (aluop_i == `EXE_SUBU_OP) ||
                         (aluop_i == `EXE_SLT_OP)) ?
                         (~reg2_i) + 1 : reg2_i;

    //The result of sum and sub
    assign result_sum = reg1_i + reg2_i_mux;

    //Justify whether there is overflow
    assign ov_sum = ((!reg1_i[31]) && (!reg2_i_mux[31]) && result_sum[31]) ||
                    (reg1_i[31] && reg2_i_mux[31] && (!result_sum[31]));

    //The outcome of SLT instruction
    assign reg1_lt_reg2 = (aluop_i == `EXE_SLT_OP) ?
                           ((reg1_i[31] && (!reg2_i[31])) ||
                            (reg1_i[31] && reg2_i[31] && result_sum[31]) ||
                            (!reg1_i[31] && !reg2_i[31] && result_sum[31]))
                            : (reg1_i < reg2_i);

    //For the convenient of CLO instruction
    assign reg1_i_not = ~reg1_i;

    //The mux for the reslut of arithmeticres
    always@(*) begin
        if(rst == `RstEnalbe) begin
            arithmeticres = `ZeroWord;
        end
        else begin
            case(aluop_i)
                `EXE_SLT_OP, `EXE_SLTU_OP: begin
                    arithmeticres = reg1_lt_reg2;
                end
                `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP: begin
                    arithmeticres = result_sum;
                end
                `EXE_SUB_OP, `EXE_SUBU_OP: begin
                    arithmeticres = result_sum;
                end
                `EXE_CLZ_OP: begin
                    arithmeticres = reg1_i[31] ? 32'd0 :
                                    reg1_i[30] ? 32'd1 :
                                    reg1_i[29] ? 32'd2 :
                                    reg1_i[28] ? 32'd3 :
                                    reg1_i[27] ? 32'd4 :
                                    reg1_i[26] ? 32'd5 :
                                    reg1_i[25] ? 32'd6 :
                                    reg1_i[24] ? 32'd7 :
                                    reg1_i[23] ? 32'd8 :
                                    reg1_i[22] ? 32'd9 :
                                    reg1_i[21] ? 32'd10 :
                                    reg1_i[20] ? 32'd11 :
                                    reg1_i[19] ? 32'd12 :
                                    reg1_i[18] ? 32'd13 :
                                    reg1_i[17] ? 32'd14 :
                                    reg1_i[16] ? 32'd15 :
                                    reg1_i[15] ? 32'd16 :
                                    reg1_i[14] ? 32'd17 :
                                    reg1_i[13] ? 32'd18 :
                                    reg1_i[12] ? 32'd19 :
                                    reg1_i[11] ? 32'd20 :
                                    reg1_i[10] ? 32'd21 :
                                    reg1_i[9] ? 32'd22 :
                                    reg1_i[8] ? 32'd23 :
                                    reg1_i[7] ? 32'd24 :
                                    reg1_i[6] ? 32'd25 :
                                    reg1_i[5] ? 32'd26 :
                                    reg1_i[4] ? 32'd27 :
                                    reg1_i[3] ? 32'd28 :
                                    reg1_i[2] ? 32'd29 :
                                    reg1_i[1] ? 32'd30 :
                                    reg1_i[0] ? 32'd31 : 32'd32;
                end
                `EXE_CLO_OP: begin
                    arithmeticres = reg1_i_not[31] ? 32'd0 :
                                    reg1_i_not[30] ? 32'd1 :
                                    reg1_i_not[29] ? 32'd2 :
                                    reg1_i_not[28] ? 32'd3 :
                                    reg1_i_not[27] ? 32'd4 :
                                    reg1_i_not[26] ? 32'd5 :
                                    reg1_i_not[25] ? 32'd6 :
                                    reg1_i_not[24] ? 32'd7 :
                                    reg1_i_not[23] ? 32'd8 :
                                    reg1_i_not[22] ? 32'd9 :
                                    reg1_i_not[21] ? 32'd10 :
                                    reg1_i_not[20] ? 32'd11 :
                                    reg1_i_not[19] ? 32'd12 :
                                    reg1_i_not[18] ? 32'd13 :
                                    reg1_i_not[17] ? 32'd14 :
                                    reg1_i_not[16] ? 32'd15 :
                                    reg1_i_not[15] ? 32'd16 :
                                    reg1_i_not[14] ? 32'd17 :
                                    reg1_i_not[13] ? 32'd18 :
                                    reg1_i_not[12] ? 32'd19 :
                                    reg1_i_not[11] ? 32'd20 :
                                    reg1_i_not[10] ? 32'd21 :
                                    reg1_i_not[9]  ? 32'd22 :
                                    reg1_i_not[8]  ? 32'd23 :
                                    reg1_i_not[7]  ? 32'd24 :
                                    reg1_i_not[6]  ? 32'd25 :
                                    reg1_i_not[5]  ? 32'd26 :
                                    reg1_i_not[4]  ? 32'd27 :
                                    reg1_i_not[3]  ? 32'd28 :
                                    reg1_i_not[2]  ? 32'd29 :
                                    reg1_i_not[1]  ? 32'd30 :
                                    reg1_i_not[0]  ? 32'd31 : 32'd32;
                end
                default: begin
                    arithmeticres = `ZeroWord;
                end
            endcase
        end
    end

//***************Part 7. The logics of mul*******************************//
    //prepare the values of opdata for mul
    assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) ||
                            (aluop_i == `EXE_MULT_OP) ||
                            (aluop_i == `EXE_MADD_OP) ||
                            (aluop_i == `EXE_MSUB_OP)) &&
                            (reg1_i[31] == 1'b1)) ? (~reg1_i + 1'b1) : reg1_i;

    assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) ||
                            (aluop_i == `EXE_MULT_OP) ||
                            (aluop_i == `EXE_MADD_OP) ||
                            (aluop_i == `EXE_MSUB_OP)) &&
                            (reg2_i[31] == 1'b1)) ? (~reg2_i + 1'b1) : reg2_i;

    //The temp value of mul outcome
    assign hilo_temp =opdata1_mult * opdata2_mult;

    //The result value of mul
    always@(*) begin
        if(rst == `RstEnalbe) begin
            mulres = {`ZeroWord,`ZeroWord};
        end
        else if((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP)) begin
            if(reg1_i[31] ^ reg2_i[31] == 1'b1) begin
                mulres = ~hilo_temp + 1'b1;
            end
            else begin
                mulres = hilo_temp;
            end
        end
        else begin
            mulres = hilo_temp;
        end
    end


//***Part 8. The logics of MADD, MADDU, MSUB, MSUBU and stallreq_for_madd_msub****//
    always@(*) begin
        if(rst == `RstEnalbe) begin
            hilo_temp_o = {`ZeroWord,`ZeroWord};
            cnt_o = 2'b00;
            stallreq_for_madd_msub = `NoStop;
        end
        else begin
            case(aluop_i)
                `EXE_MADD_OP,`EXE_MADDU_OP: begin
                    if(cnt_i == 2'b00) begin
                        hilo_temp_o = mulres;
                        cnt_o = 2'b01;
                        hilo_temp1 = {`ZeroWord,`ZeroWord};
                        stallreq_for_madd_msub = `Stop;
                    end
                    else if(cnt_i == 2'b01) begin
                        hilo_temp_o = {`ZeroWord,`ZeroWord};
                        cnt_o = 2'b10;
                        hilo_temp1 = hilo_temp_i + {HI,LO};
                        stallreq_for_madd_msub = `NoStop;
                    end
                end
                `EXE_MSUB_OP,`EXE_MSUBU_OP: begin
                    if(cnt_i == 2'b00) begin
                        hilo_temp_o = ~mulres + 1;
                        cnt_o = 2'b01;
                        hilo_temp1 = {`ZeroWord,`ZeroWord};
                        stallreq_for_madd_msub = `Stop;
                    end
                    else if(cnt_i == 2'b01) begin
                        hilo_temp_o = {`ZeroWord,`ZeroWord};
                        cnt_o = 2'b10;
                        hilo_temp1 = hilo_temp_i + {HI,LO};
                        stallreq_for_madd_msub = `NoStop;
                    end
                end
                default: begin
                    hilo_temp_o = {`ZeroWord,`ZeroWord};
                    cnt_o = 2'b00;
                    stallreq_for_madd_msub = `NoStop;
                end
            endcase
        end
    end

//*****Part 9. The logic of controlling div module and stallreq_for_div********//
    always@(*) begin
        if(rst == `RstEnalbe) begin
            stallreq_for_div = `NoStop;
            div_opdata1_o    = `ZeroWord;
            div_opdata2_o    = `ZeroWord;
            div_start_o      = `DivStop;
            signed_div_o     = 1'b0;
        end
        else begin
            case(aluop_i)
                `EXE_DIV_OP: begin
                    if(div_ready_i == `DivResultNotReady) begin
                        stallreq_for_div = `Stop;
                        div_opdata1_o    = reg1_i;
                        div_opdata2_o    = reg2_i;
                        div_start_o      = `DivStart;
                        signed_div_o     = 1'b1;
                    end
                    else if(div_ready_i == `DivResultReady) begin
                        stallreq_for_div = `NoStop;
                        div_opdata1_o    = reg1_i;
                        div_opdata2_o    = reg2_i;
                        div_start_o      = `DivStart;
                        signed_div_o     = 1'b1;
                    end
                    else begin
                        stallreq_for_div = `NoStop;
                        div_opdata1_o    = `ZeroWord;
                        div_opdata2_o    = `ZeroWord;
                        div_start_o      = `DivStop;
                        signed_div_o     = 1'b0;
                    end
                end
                `EXE_DIVU_OP: begin
                    if(div_ready_i == `DivResultNotReady) begin
                        stallreq_for_div = `Stop;
                        div_opdata1_o    = reg1_i;
                        div_opdata2_o    = reg2_i;
                        div_start_o      = `DivStart;
                        signed_div_o     = 1'b0;
                    end
                    else if(div_ready_i == `DivResultReady) begin
                        stallreq_for_div = `NoStop;
                        div_opdata1_o    = reg1_i;
                        div_opdata2_o    = reg2_i;
                        div_start_o      = `DivStart;
                        signed_div_o     = 1'b0;
                    end
                    else begin
                        stallreq_for_div = `NoStop;
                        div_opdata1_o    = `ZeroWord;
                        div_opdata2_o    = `ZeroWord;
                        div_start_o      = `DivStop;
                        signed_div_o     = 1'b0;
                    end
                end
                default: begin
                    stallreq_for_div = `NoStop;
                    div_opdata1_o    = `ZeroWord;
                    div_opdata2_o    = `ZeroWord;
                    div_start_o      = `DivStop;
                    signed_div_o     = 1'b0;
                end
            endcase
        end
    end


//***********Part 10. The logic of write back output**************************//
    always@(*) begin
        wd_o = wd_i;

        if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
            wreg_o = `WriteDisable;
        end
        else begin
            wreg_o = wreg_i;
        end
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
            `EXE_RES_ARITHMETIC: begin
                wdata_o = arithmeticres;
            end
            `EXE_RES_MUL: begin
                wdata_o = mulres[31:0];
            end
            `EXE_RES_JUMP_BRANCH: begin
                wdata_o = link_address_i;
            end
            default: begin
                wdata_o = `ZeroWord;
            end
        endcase
    end


//*******Part 11. The mux of stallreq*****************//
    always@(*) begin
        stallreq = stallreq_for_madd_msub || stallreq_for_div;
    end


//****Part 12. The logics of load (from) and save (to) ram***//
assign aluop_o = aluop_i;
assign mem_addr_o = reg1_i +{{16{inst_i[15]}},inst_i[15:0]};
assign reg2_o = reg2_i;

endmodule


