module ex_mem(
    input                       clk         ,
    input                       rst         ,

    input [`RegAddrBus]         ex_wd       ,
    input                       ex_wreg     ,
    input [`RegBus]             ex_wdata    ,
    input [`RegBus]             ex_hi       ,
    input [`RegBus]             ex_lo       ,
    input                       ex_whilo    ,

    output reg [`RegAddrBus]    men_wd      ,
    output reg                  men_wreg    ,
    output reg [`RegBus]        men_wdata   ,
    output reg [`RegBus]        mem_hi      ,
    output reg [`RegBus]        mem_lo      ,
    output reg                  mem_whilo
);

always @(posedge clk) begin
    if (rst) begin
        men_wd      <=      `NOPRegAddr     ;
        men_wreg    <=      `WriteDisable   ;
        men_wdata   <=      `ZeroWord       ;
        mem_hi      <=      `ZeroWord       ;
        mem_lo      <=      `ZeroWord       ;
        mem_whilo   <=      `WriteDisable   ;

    end
    else begin
        men_wd      <=      ex_wd           ;
        men_wreg    <=      ex_wreg         ;
        men_wdata   <=      ex_wdata        ;
        mem_hi      <=      ex_hi           ;
        mem_lo      <=      ex_lo           ;
        mem_whilo   <=      ex_whilo        ;
    end
end


endmodule