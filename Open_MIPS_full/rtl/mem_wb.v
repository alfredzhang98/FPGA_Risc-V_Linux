module mem_wb(
    input                       clk         ,
    input                       rst         ,

    input [5:0]                 stall       ,

    input [`RegAddrBus]         men_wd      ,
    input                       men_wreg    ,
    input [`RegBus]             men_wdata   ,
    input [`RegBus]             mem_hi      ,
    input [`RegBus]             mem_lo      ,
    input                       mem_whilo   ,
    input                       mem_LLbit_we,
    input                       mem_LLbit_value,

    output reg [`RegAddrBus]    wb_wd       ,
    output reg                  wb_wreg     ,
    output reg [`RegBus]        wb_wdata    ,
    output reg [`RegBus]        wb_hi       ,
    output reg [`RegBus]        wb_lo       ,
    output reg                  wb_whilo    ,
    output reg                  wb_LLbit_we ,
    output reg                  wb_LLbit_value

);

always @(posedge clk) begin
    if (rst) begin
        wb_wd       <= `NOPRegAddr  ;
        wb_wreg     <= `WriteDisable;
        wb_wdata    <= `ZeroWord    ;
        wb_hi       <= `ZeroWord    ;
        wb_lo       <= `ZeroWord    ;
        wb_whilo    <= `WriteDisable;
        wb_LLbit_we <= 1'b0;
        wb_LLbit_value <= 1'b0;
    end
    else if(stall[4] == `Stop && stall[5] == `NoStop) begin
        wb_wd       <= `NOPRegAddr  ;
        wb_wreg     <= `WriteDisable;
        wb_wdata    <= `ZeroWord    ;
        wb_hi       <= `ZeroWord    ;
        wb_lo       <= `ZeroWord    ;
        wb_whilo    <= `WriteDisable;
        wb_LLbit_we <= 1'b0;
        wb_LLbit_value <= 1'b0;
    end
    else if(stall[4] == `NoStop) begin
        wb_wd       <= men_wd      ;
        wb_wreg     <= men_wreg    ;
        wb_wdata    <= men_wdata   ;
        wb_hi       <= mem_hi      ;
        wb_lo       <= mem_lo      ;
        wb_whilo    <= mem_whilo   ;
        wb_LLbit_we <= mem_LLbit_we;
        wb_LLbit_value <= mem_LLbit_value;
    end
end




endmodule