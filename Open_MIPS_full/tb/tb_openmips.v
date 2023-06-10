module tb_openmips;

    reg                     clk         ;
    reg                     rst         ;
    wire  [`InstBus]        rom_data    ;
    wire  [`InstAddrBus]    rom_addr    ;
    wire                    rom_ce      ;


    initial begin
        clk = 1'b0;
        rst = `RstEnalbe;
        #73;
        rst = `RstDisable;
        #4500;
        $finish;
    end

    always #10 clk = ~clk; //50Mhz

    rom u_rom(
        .rom_addr_i(rom_addr),
        .rom_ce_o  (rom_ce),
        .rom_data_o(rom_data  )
    );

    openmips u_openmips(
        .clk         (clk),
        .rst         (rst),

        .rom_data_i  (rom_data),
        .rom_addr_o  (rom_addr),
        .rom_ce_o    (rom_ce  )

    );


endmodule