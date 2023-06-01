module pc_reg(
    input                       clk,
    input                       rst,
    output reg [`InstAddrBus]   pc ,
    output reg                  ce
    );


    always @(posedge clk) begin
        if (rst == `RstEnalbe) begin
            ce <= `ChipDisable;
        end
        else begin
            ce <= `ChipEnable;
        end
    end

    always @(posedge clk) begin
        if (ce == `ChipDisable) begin
            pc <= 32'h00000000;
        end
        else begin
            pc <= pc + 32'h4;
        end
    end

endmodule