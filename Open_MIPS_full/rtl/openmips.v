module openmips(
    input                       clk         ,
    input                       rst         ,

    input   [`InstBus]          rom_data_i  ,
    output  [`InstAddrBus]      rom_addr_o  ,
    output                      rom_ce_o

);

    //************definitions******************//
    //connection between pc_reg and if_id

    wire                        ce          ;

    //connection between if_id and id

    wire [`InstBus]             id_inst     ;
    wire [`InstAddrBus]         id_pc       ;

    //connection between id and id_ex
    wire [`AluOpBus]            id_aluop    ;
    wire [`AluSelBus]           id_alusel   ;
    wire [`RegBus]              id_reg1     ;
    wire [`RegBus]              id_reg2     ;
    wire [`RegAddrBus]          id_wd       ;
    wire                        id_wreg     ;

    //connection between id_ex and ex
    wire [`AluOpBus]            ex_aluop    ;
    wire [`AluSelBus]           ex_alusel   ;
    wire [`RegBus]              ex_reg1     ;
    wire [`RegBus]              ex_reg2     ;
    wire [`RegAddrBus]          ex_wd       ;
    wire                        ex_wreg     ;

    //connection between ex and ex_mem
    wire [`RegAddrBus]          ex_mem_wd   ;
    wire                        ex_mem_wreg ;
    wire [`RegBus]              ex_mem_wdata;
    wire [`RegBus]              ex_mem_hi   ;
    wire [`RegBus]              ex_mem_lo   ;
    wire                        ex_mem_whilo;

    //connection between ex_mem and mem
    wire [`RegAddrBus]          ex_men_mem_wd   ;
    wire                        ex_men_mem_wreg ;
    wire [`RegBus]              ex_men_mem_wdata;
    wire [`RegBus]              ex_mem_mem_hi   ;
    wire [`RegBus]              ex_mem_mem_lo   ;
    wire                        ex_mem_mem_whilo;

    //connection between mem and mem_wb
    wire [`RegAddrBus]          men_mem_wb_wd   ;
    wire                        men_mem_wb_wreg ;
    wire [`RegBus]              men_mem_wb_wdata;
    wire [`RegBus]              mem_mem_wb_hi   ;
    wire [`RegBus]              mem_mem_wb_lo   ;
    wire                        mem_mem_wb_whilo;

    //connection between mem_wb and regfile
    wire [`RegAddrBus]          wb_regfile_wd   ;
    wire                        wb_regfile_wreg ;
    wire [`RegBus]              wb_regfile_wdata;

    //connection between mem_wb and hilo_reg
    wire [`RegBus]              mem_wb_hilo_reg_hi   ;
    wire [`RegBus]              mem_wb_hilo_reg_lo  ;
    wire                        mem_wb_hilo_reg_whilo;

    //connection between id and regfile

    wire [`RegBus]              reg1_data_i     ;
    wire [`RegBus]              reg2_data_i     ;

    wire                        reg1_read_o     ;
    wire                        reg2_read_o     ;
    wire [`RegAddrBus]          reg1_addr_o     ;
    wire [`RegAddrBus]          reg2_addr_o     ;

    //connection between hilo_reg and ex
    wire [`RegBus]              hilo_reg_ex_hi;
    wire [`RegBus]              hilo_reg_ex_lo;


    //************inst of modules*************//
    //inst of pc_reg
    pc_reg pc_reg_inst(
            .clk        (clk        ),
            .rst        (rst        ),
            .pc         (rom_addr_o ),
            .ce         (rom_ce_o   )
        );

    //inst of if_id
    if_id if_id_inst(
            .clk        (clk       ),
            .rst        (rst       ),
            .if_pc      (rom_addr_o),
            .if_inst    (rom_data_i),
            .id_pc      (id_pc     ),
            .id_inst    (id_inst   )
        );

    //inst of id
    id id_inst0(
        .rst            (rst            ),

        //from if_id
        .pc_i           (id_pc          ),
        .inst_i         (id_inst        ),

        //from regfile
        .reg1_data_i    (reg1_data_i    ),
        .reg2_data_i    (reg2_data_i    ),

        //from ex module
        .ex_wreg_i      (ex_mem_wreg    ),
        .ex_wdata_i     (ex_mem_wdata   ),
        .ex_wd_i        (ex_mem_wd      ),

        //from mem module
        .mem_wreg_i     (men_mem_wb_wreg),
        .mem_wdata_i    (men_mem_wb_wdata),
        .mem_wd_i       (men_mem_wb_wd  ),

        //output to regfile
        .reg1_read_o    (reg1_read_o    ),
        .reg2_read_o    (reg2_read_o    ),
        .reg1_addr_o    (reg1_addr_o    ),
        .reg2_addr_o    (reg2_addr_o    ),

        //to ex
        .aluop_o        (id_aluop       ),
        .alusel_o       (id_alusel      ),
        .reg1_o         (id_reg1        ),
        .reg2_o         (id_reg2        ),
        .wd_o           (id_wd          ),
        .wreg_o         (id_wreg        )
        );

    id_ex id_ex_inst(
        .clk         (clk       ),
        .rst         (rst       ),

        //from instruction decode module
        .id_aluop    (id_aluop  ),
        .id_alusel   (id_alusel ),
        .id_reg1     (id_reg1   ),
        .id_reg2     (id_reg2   ),
        .id_wd       (id_wd     ),
        .id_wreg     (id_wreg   ),

        //to excution module
        .ex_aluop    (ex_aluop  ),
        .ex_alusel   (ex_alusel ),
        .ex_reg1     (ex_reg1   ),
        .ex_reg2     (ex_reg2   ),
        .ex_wd       (ex_wd     ),
        .ex_wreg     (ex_wreg   )

        );


    ex ex_inst(
        .rst        (rst          ),

        .aluop_i    (ex_aluop     ),
        .alusel_i   (ex_alusel    ),
        .reg1_i     (ex_reg1      ),
        .reg2_i     (ex_reg2      ),
        .wd_i       (ex_wd        ),
        .wreg_i     (ex_wreg      ),

        .wd_o       (ex_mem_wd    ),
        .wreg_o     (ex_mem_wreg  ),
        .wdata_o    (ex_mem_wdata ),

        .hi_i       (hilo_reg_ex_hi),
        .lo_i       (hilo_reg_ex_lo),

        .wb_hi_i    (mem_wb_hilo_reg_hi ),
        .wb_lo_i    (mem_wb_hilo_reg_lo ),
        .wb_whilo_i (mem_wb_hilo_reg_whilo),

        .mem_hi_i   (mem_mem_wb_hi   ),
        .mem_lo_i   (mem_mem_wb_lo   ),
        .mem_whilo_i(mem_mem_wb_whilo),

        .hi_o       (ex_mem_hi  ),
        .lo_o       (ex_mem_lo  ),
        .whilo_o    (ex_mem_whilo)

    );

    ex_mem ex_mem_inst(
        .clk            (clk            ),
        .rst            (rst            ),

        .ex_wd          (ex_mem_wd      ),
        .ex_wreg        (ex_mem_wreg    ),
        .ex_wdata       (ex_mem_wdata   ),
        .ex_hi          (ex_mem_hi      ),
        .ex_lo          (ex_mem_lo      ),
        .ex_whilo       (ex_mem_whilo   ),

        .men_wd         (ex_men_mem_wd   ),
        .men_wreg       (ex_men_mem_wreg ),
        .men_wdata      (ex_men_mem_wdata),
        .mem_hi         (ex_mem_mem_hi   ),
        .mem_lo         (ex_mem_mem_lo   ),
        .mem_whilo      (ex_mem_mem_whilo)
    );

    mem mem_inst(
            .rst        (rst             ),

            .wd_i       (ex_men_mem_wd   ),
            .wreg_i     (ex_men_mem_wreg ),
            .wdata_i    (ex_men_mem_wdata),
            .hi_i       (ex_mem_mem_hi   ),
            .lo_i       (ex_mem_mem_lo   ),
            .whilo_i    (ex_mem_mem_whilo),

            .wd_o       (men_mem_wb_wd   ),
            .wreg_o     (men_mem_wb_wreg ),
            .wdata_o    (men_mem_wb_wdata),
            .hi_o       (mem_mem_wb_hi   ),
            .lo_o       (mem_mem_wb_lo   ),
            .whilo_o    (mem_mem_wb_whilo)
        );

    mem_wb mem_wb_inst(
        .clk            (clk            ),
        .rst            (rst            ),

        .men_wd         (men_mem_wb_wd  ),
        .men_wreg       (men_mem_wb_wreg),
        .men_wdata      (men_mem_wb_wdata),
        .mem_hi         (mem_mem_wb_hi   ),
        .mem_lo         (mem_mem_wb_lo   ),
        .mem_whilo      (mem_mem_wb_whilo),

        .wb_wd          (wb_regfile_wd  ),
        .wb_wreg        (wb_regfile_wreg),
        .wb_wdata       (wb_regfile_wdata),
        .wb_hi          (mem_wb_hilo_reg_hi ),
        .wb_lo          (mem_wb_hilo_reg_lo ),
        .wb_whilo       (mem_wb_hilo_reg_whilo)

        );

    regfile regfile_inst(
        .clk     (clk           ),
        .rst     (rst           ),

        //write port
        .we      (wb_regfile_wreg),
        .waddr   (wb_regfile_wd ),
        .wdata   (wb_regfile_wdata),

        //read port1
        .re1     (reg1_read_o   ),
        .raddr1  (reg1_addr_o   ),
        .rdata1  (reg1_data_i   ),

        //read port2
        .re2     (reg2_read_o   ),
        .raddr2  (reg2_addr_o   ),
        .rdata2  (reg2_data_i   )
        );

    hilo_reg hilo_reg_inst(

        .clk    (clk    ),
        .rst    (rst    ),

        .we     (mem_wb_hilo_reg_whilo),
        .hi_i   (mem_wb_hilo_reg_hi),
        .lo_i   (mem_wb_hilo_reg_lo),

        .hi_o   (hilo_reg_ex_hi),
        .lo_o   (hilo_reg_ex_lo)


        );

endmodule