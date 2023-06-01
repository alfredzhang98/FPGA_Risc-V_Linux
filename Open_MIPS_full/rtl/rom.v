module rom(

        input       [`InstAddrBus]  rom_addr_i  ,
        input                       rom_ce_o    ,
        output reg  [`InstBus]      rom_data_o
    );

reg [`InstBus] mem [0:`InstMenNum];

initial begin $readmemh("inst_rom.mem",mem); end

always @(*) begin
    if (rom_ce_o == `ChipDisable) begin
        rom_data_o = `ZeroWord;
    end
    else begin
        rom_data_o = mem[rom_addr_i[31:2]];

    end
end



endmodule