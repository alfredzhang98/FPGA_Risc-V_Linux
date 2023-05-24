module ex_mem(
    input                       clk         ,
    input                       rst         ,

    input [`RegAddrBus]        ex_wd        ,
    input                      ex_wreg      ,
    input [`RegBus]            ex_wdata     ,

    output reg [`RegAddrBus]   men_wd       ,
    output reg                 men_wreg     ,
    output reg  [`RegBus]      men_wdata
    );

always @(posedge clk) begin
    if (rst) begin
        men_wd      <=      `NOPRegAddr;
        men_wreg    <=      `WriteDisable;
        men_wdata   <=      `ZeroWord;

    end
    else begin
        men_wd      <=      ex_wd;
        men_wreg    <=      ex_wreg;
        men_wdata   <=      ex_wdata;
    end
end


endmodule