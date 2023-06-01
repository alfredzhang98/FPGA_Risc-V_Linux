module mem_wb(
    input                       clk         ,
    input                       rst         ,

    input [`RegAddrBus]         men_wd      ,
    input                       men_wreg    ,
    input [`RegBus]             men_wdata   ,
    input [`RegBus]             mem_hi      ,
    input [`RegBus]             mem_lo      ,
    input                       mem_whilo   ,

    output reg [`RegAddrBus]    wb_wd       ,
    output reg                  wb_wreg     ,
    output reg [`RegBus]        wb_wdata    ,
    output reg [`RegBus]        wb_hi       ,
    output reg [`RegBus]        wb_lo       ,
    output reg                  wb_whilo

);

always @(posedge clk) begin
    if (rst) begin
        wb_wd       <= `NOPRegAddr  ;
        wb_wreg     <= `WriteDisable;
        wb_wdata    <= `ZeroWord    ;
        wb_hi       <= `ZeroWord    ;
        wb_lo       <= `ZeroWord    ;
        wb_whilo    <= `WriteDisable;
    end
    else begin
        wb_wd       <= men_wd      ;
        wb_wreg     <= men_wreg    ;
        wb_wdata    <= men_wdata   ;
        wb_hi       <= mem_hi      ;
        wb_lo       <= mem_lo      ;
        wb_whilo    <= mem_whilo   ;
    end
end




endmodule