module tb_openmips;

    reg                     clk             ;
    reg                     rst             ;
    wire  [`InstBus]        rom_data        ;
    wire  [`InstAddrBus]    rom_addr        ;
    wire                    rom_ce          ;

    wire                    ram_ce          ;
    wire                    ram_we          ;
    wire [`DataAddrBus]     ram_addr        ;
    wire [3:0]              ram_sel         ;
    wire [`DataBus]         ram_data_mosi   ;
    wire [`DataBus]         ram_data_miso   ;


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
        .clk         (clk           ),
        .rst         (rst           ),

        .rom_data_i  (rom_data      ),
        .rom_addr_o  (rom_addr      ),
        .rom_ce_o    (rom_ce        ),

        .ram_data_i  (ram_data_miso ),
        .ram_addr_o  (ram_addr      ),
        .ram_we_o    (ram_we        ),
        .ram_sel_o   (ram_sel       ),
        .ram_data_o  (ram_data_mosi ),
        .ram_ce_o    (ram_ce        )

    );

    data_ram u_data_ram(
        .clk        (clk            ),
        .ce         (ram_ce         ),
        .we         (ram_we         ),
        .addr       (ram_addr       ),
        .sel        (ram_sel        ),
        .data_i     (ram_data_mosi  ),
        .data_o     (ram_data_miso  )
    );


endmodule
