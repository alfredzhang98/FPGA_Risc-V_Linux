module if_id(
    input                           clk     ,
    input                           rst     ,
    input           [`InstAddrBus]  if_pc   ,
    input           [`InstBus]      if_inst ,
    output reg      [`InstAddrBus]  id_pc   ,
    output reg      [`InstBus]      id_inst
    );

always @(posedge clk) begin
    if (rst == `RstEnalbe) begin
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
    end
    else begin
        id_pc <= if_pc;
        id_inst <= if_inst;
    end
end



endmodule