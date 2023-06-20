module pc_reg(
    input                       clk                     ,
    input                       rst                     ,

    //from id
    input                       branch_flag_i           ,
    input [`RegBus]             branch_target_address_i ,

    //from ctrl
    input      [5:0]            stall                   ,

    //to rom and if_id
    output reg [`InstAddrBus]   pc                      ,
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
        else if(stall[0] == `Stop) begin
            pc <= pc;
        end
        else if(branch_flag_i == `Branch) begin
            pc <= branch_target_address_i;
        end
        else begin
            pc <= pc + 32'h4;
        end

    end

endmodule

