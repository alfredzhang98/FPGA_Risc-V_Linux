module ex_mem(
    input                       clk         ,
    input                       rst         ,

    input [5:0]                 stall       ,

    input [`DoubleRegBus]       hilo_i      ,
    input [1:0]                 cnt_i       ,

    input [`RegAddrBus]         ex_wd       ,
    input                       ex_wreg     ,
    input [`RegBus]             ex_wdata    ,
    input [`RegBus]             ex_hi       ,
    input [`RegBus]             ex_lo       ,
    input                       ex_whilo    ,
    input [`AluOpBus]           ex_aluop    ,
    input [`RegBus]             ex_mem_addr ,
    input [`RegBus]             ex_reg2     ,

    output reg [`DoubleRegBus]  hilo_o      ,
    output reg [1:0]            cnt_o       ,

    output reg [`RegAddrBus]    men_wd      ,
    output reg                  men_wreg    ,
    output reg [`RegBus]        men_wdata   ,
    output reg [`RegBus]        mem_hi      ,
    output reg [`RegBus]        mem_lo      ,
    output reg                  mem_whilo   ,
    output reg [`AluOpBus]      mem_aluop   ,
    output reg [`RegBus]        mem_mem_addr,
    output reg [`RegBus]        mem_reg2

);

    always @(posedge clk) begin
        if (rst) begin
            men_wd          <= `NOPRegAddr          ;
            men_wreg        <= `WriteDisable        ;
            men_wdata       <= `ZeroWord            ;
            mem_hi          <= `ZeroWord            ;
            mem_lo          <= `ZeroWord            ;
            mem_whilo       <= `WriteDisable        ;
            hilo_o          <= {`ZeroWord,`ZeroWord};
            cnt_o           <= 2'b00                ;
            mem_aluop       <= `EXE_NOP_OP          ;
            mem_mem_addr    <= `ZeroWord            ;
            mem_reg2        <= `ZeroWord            ;
        end
        else if(stall[3] == `Stop && stall[4] == `NoStop) begin
            men_wd          <= `NOPRegAddr          ;
            men_wreg        <= `WriteDisable        ;
            men_wdata       <= `ZeroWord            ;
            mem_hi          <= `ZeroWord            ;
            mem_lo          <= `ZeroWord            ;
            mem_whilo       <= `WriteDisable        ;
            hilo_o          <= hilo_i               ;
            cnt_o           <= cnt_i                ;
            mem_aluop       <= `EXE_NOP_OP          ;
            mem_mem_addr    <= `ZeroWord            ;
            mem_reg2        <= `ZeroWord            ;
        end
        else if(stall[3] == `NoStop) begin
            men_wd          <= ex_wd                ;
            men_wreg        <= ex_wreg              ;
            men_wdata       <= ex_wdata             ;
            mem_hi          <= ex_hi                ;
            mem_lo          <= ex_lo                ;
            mem_whilo       <= ex_whilo             ;
            hilo_o          <= {`ZeroWord,`ZeroWord};
            cnt_o           <= 2'b00                ;
            mem_aluop       <= ex_aluop             ;
            mem_mem_addr    <= ex_mem_addr          ;
            mem_reg2        <= ex_reg2              ;
        end
        else begin
            hilo_o          <= hilo_i               ;
            cnt_o           <= cnt_i                ;
        end
    end

endmodule
