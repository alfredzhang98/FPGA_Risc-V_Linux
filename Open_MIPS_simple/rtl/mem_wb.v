module mem_wb(
    input                       clk         ,
    input                       rst         ,

    input [`RegAddrBus]         men_wd      ,
    input                       men_wreg    ,
    input  [`RegBus]            men_wdata   ,

    output reg [`RegAddrBus]    wb_wd      ,
    output reg                  wb_wreg     ,
    output reg [`RegBus]        wb_wdata

    );

always @(posedge clk) begin
    if (rst) begin
        wb_wd      <=      `NOPRegAddr;
        wb_wreg    <=      `WriteDisable;
        wb_wdata   <=      `ZeroWord;
    end
    else begin
        wb_wd      <=       men_wd      ;
        wb_wreg    <=       men_wreg    ;
        wb_wdata   <=       men_wdata   ;
    end
end




endmodule