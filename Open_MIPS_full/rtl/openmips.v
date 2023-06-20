module openmips(
    input                       clk         ,
    input                       rst         ,

    //connect to rom
    input   [`InstBus]          rom_data_i  ,
    output  [`InstAddrBus]      rom_addr_o  ,
    output                      rom_ce_o    ,

    //connect to ram
    input   [`RegBus]           ram_data_i  ,
    output  [`RegBus]           ram_addr_o  ,
    output                      ram_we_o    ,
    output  [3:0]               ram_sel_o   ,
    output  [`RegBus]           ram_data_o  ,
    output                      ram_ce_o
);

    //************definitions******************//
    //connection between pc_reg and if_id
    wire                        ce              ;

    //connection between if_id and id
    wire [`InstBus]             id_inst         ;
    wire [`InstAddrBus]         id_pc           ;

    //connection between id and id_ex
    wire [`AluOpBus]            id_aluop        ;
    wire [`AluSelBus]           id_alusel       ;
    wire [`RegBus]              id_reg1         ;
    wire [`RegBus]              id_reg2         ;
    wire [`RegAddrBus]          id_wd           ;
    wire                        id_wreg         ;
    wire                        is_in_delayslot_id_idex;
    wire                        is_in_delayslot_idex_id;
    wire [`RegBus]              link_addr_o     ;
    wire                        next_inst_in_delayslot;
    wire [`RegBus]              id_idex_inst    ;


    //connection between id_ex and ex
    wire [`AluOpBus]            ex_aluop        ;
    wire [`AluSelBus]           ex_alusel       ;
    wire [`RegBus]              ex_reg1         ;
    wire [`RegBus]              ex_reg2         ;
    wire [`RegAddrBus]          ex_wd           ;
    wire                        ex_wreg         ;
    wire                        is_in_delayslot_idex_ex;
    wire [`RegBus]              link_addr_idex_ex;
    wire [`RegBus]              idex_ex_inst    ;

    //connection between ex and ex_mem
    wire [`RegAddrBus]          ex_mem_wd       ;
    wire                        ex_mem_wreg     ;
    wire [`RegBus]              ex_mem_wdata    ;
    wire [`RegBus]              ex_mem_hi       ;
    wire [`RegBus]              ex_mem_lo       ;
    wire                        ex_mem_whilo    ;

    wire [`DoubleRegBus]        hilo_temp_ex_ex_mem;
    wire [1:0]                  cnt_ex_ex_mem    ;

    wire [`DoubleRegBus]        hilo_temp_ex_mem_ex;
    wire [1:0]                  cnt_ex_mem_ex   ;

    wire  [`AluOpBus]           ex_exmem_aluop  ;
    wire  [`RegBus]             ex_exmem_mem_addr;
    wire  [`RegBus]             ex_exmem_reg2   ;

    //connection between ex_mem and mem
    wire [`RegAddrBus]          ex_men_mem_wd   ;
    wire                        ex_men_mem_wreg ;
    wire [`RegBus]              ex_men_mem_wdata;
    wire [`RegBus]              ex_mem_mem_hi   ;
    wire [`RegBus]              ex_mem_mem_lo   ;
    wire                        ex_mem_mem_whilo;

    wire [`AluOpBus]            exmem_mem_aluop   ;
    wire [`RegBus]              exmem_mem_mem_addr;
    wire [`RegBus]              exmem_mem_reg2    ;

    //connection between mem and mem_wb
    wire [`RegAddrBus]          men_mem_wb_wd   ;
    wire                        men_mem_wb_wreg ;
    wire [`RegBus]              men_mem_wb_wdata;
    wire [`RegBus]              mem_mem_wb_hi   ;
    wire [`RegBus]              mem_mem_wb_lo   ;
    wire                        mem_mem_wb_whilo;
    wire                        mem_memwb_LLbit_we;
    wire                        mem_memwb_LLbit_value;

    //connection between mem_wb and regfile
    wire [`RegAddrBus]          wb_regfile_wd   ;
    wire                        wb_regfile_wreg ;
    wire [`RegBus]              wb_regfile_wdata;

    //connection between mem_wb and hilo_reg
    wire [`RegBus]              mem_wb_hilo_reg_hi  ;
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
    wire [`RegBus]              hilo_reg_ex_hi  ;
    wire [`RegBus]              hilo_reg_ex_lo  ;

    //stall signal
    wire [5:0]                  stall           ;
    wire                        stallreq_from_id;
    wire                        stallreq_from_ex;

    //connection between ex and div
    wire                        signed_div      ;
    wire [31:0]                 opdata1_div     ;
    wire [31:0]                 opdata2_div     ;
    wire                        start_div       ;
    wire [63:0]                 result_div      ;
    wire                        ready_div       ;

    //connection between id and pc
    wire                        branch_flag     ;
    wire [`RegBus]              branch_target_address;

    //connection between LLbit_reg and mem
    wire                        LLbitreg_mem_LLbit_reg;

    //connection between mem_wb and mem
    wire                        memwb_mem_LLbit_we;
    wire                        memwb_mem_LLbit_value;

    //************inst of modules*************//
    //inst of pc_reg
    pc_reg pc_reg_inst(
        .clk                (clk                ),
        .rst                (rst                ),
        .stall              (stall              ),
        .pc                 (rom_addr_o         ),
        .ce                 (rom_ce_o           ),
        .branch_flag_i      (branch_flag        ),
        .branch_target_address_i(branch_target_address)
    );

    //inst of if_id
    if_id if_id_inst(
        .clk                (clk                ),
        .rst                (rst                ),
        .stall              (stall              ),
        .if_pc              (rom_addr_o         ),
        .if_inst            (rom_data_i         ),
        .id_pc              (id_pc              ),
        .id_inst            (id_inst            )
    );

    //inst of id
    id id_inst0(
        .rst                 (rst               ),

        //from if_id
        .pc_i                (id_pc             ),
        .inst_i              (id_inst           ),

        //from regfile
        .reg1_data_i         (reg1_data_i       ),
        .reg2_data_i         (reg2_data_i       ),

        //from ex module
        .ex_wreg_i           (ex_mem_wreg       ),
        .ex_wdata_i          (ex_mem_wdata      ),
        .ex_wd_i             (ex_mem_wd         ),

        //from mem module
        .mem_wreg_i          (men_mem_wb_wreg   ),
        .mem_wdata_i         (men_mem_wb_wdata  ),
        .mem_wd_i            (men_mem_wb_wd     ),

        //output to regfile
        .reg1_read_o         (reg1_read_o       ),
        .reg2_read_o         (reg2_read_o       ),
        .reg1_addr_o         (reg1_addr_o       ),
        .reg2_addr_o         (reg2_addr_o       ),

        //to ex
        .aluop_o             (id_aluop          ),
        .alusel_o            (id_alusel         ),
        .reg1_o              (id_reg1           ),
        .reg2_o              (id_reg2           ),
        .wd_o                (id_wd             ),
        .wreg_o              (id_wreg           ),
        .inst_o              (id_idex_inst      ),

        .stallreq            (stallreq_from_id  ),

        .branch_flag_o       (branch_flag       ),
        .branch_target_address_o (branch_target_address  ),
        .is_in_delayslot_o   (is_in_delayslot_id_idex),
        .link_addr_o         (link_addr_o       ),
        .next_inst_in_delayslot_o (next_inst_in_delayslot ),
        .is_in_delayslot_i   (is_in_delayslot_idex_id),

        .ex_aluop_i          (ex_exmem_aluop    )
    );


    id_ex id_ex_inst(
        .clk                (clk                ),
        .rst                (rst                ),

        .stall              (stall              ),

        //from instruction decode module
        .id_aluop           (id_aluop           ),
        .id_alusel          (id_alusel          ),
        .id_reg1            (id_reg1            ),
        .id_reg2            (id_reg2            ),
        .id_wd              (id_wd              ),
        .id_wreg            (id_wreg            ),
        .id_is_in_delayslot (is_in_delayslot_id_idex),
        .id_link_address    (link_addr_o        ),
        .next_inst_in_delayslot_i(next_inst_in_delayslot),
        .id_inst            (id_idex_inst       ),

        //to excution module
        .ex_aluop           (ex_aluop           ),
        .ex_alusel          (ex_alusel          ),
        .ex_reg1            (ex_reg1            ),
        .ex_reg2            (ex_reg2            ),
        .ex_wd              (ex_wd              ),
        .ex_wreg            (ex_wreg            ),
        .is_in_delayslot_o  (is_in_delayslot_idex_id),
        .ex_is_in_delayslot (is_in_delayslot_idex_ex),
        .ex_link_address    (link_addr_idex_ex  ),
        .ex_inst            (idex_ex_inst       )

    );


    ex ex_inst(
        .rst                (rst                ),

        .aluop_i            (ex_aluop           ),
        .alusel_i           (ex_alusel          ),
        .reg1_i             (ex_reg1            ),
        .reg2_i             (ex_reg2            ),
        .wd_i               (ex_wd              ),
        .wreg_i             (ex_wreg            ),
        .link_address_i     (link_addr_idex_ex  ),
        .is_in_delayslot_i  (is_in_delayslot_idex_ex),
        .inst_i             (idex_ex_inst       ),

        .wd_o               (ex_mem_wd          ),
        .wreg_o             (ex_mem_wreg        ),
        .wdata_o            (ex_mem_wdata       ),

        .hi_i               (hilo_reg_ex_hi     ),
        .lo_i               (hilo_reg_ex_lo     ),

        .wb_hi_i            (mem_wb_hilo_reg_hi ),
        .wb_lo_i            (mem_wb_hilo_reg_lo ),
        .wb_whilo_i         (mem_wb_hilo_reg_whilo),

        .mem_hi_i           (mem_mem_wb_hi      ),
        .mem_lo_i           (mem_mem_wb_lo      ),
        .mem_whilo_i        (mem_mem_wb_whilo   ),

        .hi_o               (ex_mem_hi          ),
        .lo_o               (ex_mem_lo          ),
        .whilo_o            (ex_mem_whilo       ),
        .aluop_o            (ex_exmem_aluop     ),
        .mem_addr_o         (ex_exmem_mem_addr  ),
        .reg2_o             (ex_exmem_reg2      ),

        .stallreq           (stallreq_from_ex   ),

        .cnt_o              (cnt_ex_ex_mem      ),
        .hilo_temp_o        (hilo_temp_ex_ex_mem),

        .cnt_i              (cnt_ex_mem_ex      ),
        .hilo_temp_i        (hilo_temp_ex_mem_ex),


        .div_result_i       (result_div         ),
        .div_ready_i        (ready_div          ),
        .div_opdata1_o      (opdata1_div        ),
        .div_opdata2_o      (opdata2_div        ),
        .div_start_o        (start_div          ),
        .signed_div_o       (signed_div         )

    );


    ex_mem ex_mem_inst(
        .clk                (clk                ),
        .rst                (rst                ),

        .stall              (stall              ),

        .ex_wd              (ex_mem_wd          ),
        .ex_wreg            (ex_mem_wreg        ),
        .ex_wdata           (ex_mem_wdata       ),
        .ex_hi              (ex_mem_hi          ),
        .ex_lo              (ex_mem_lo          ),
        .ex_whilo           (ex_mem_whilo       ),
        .ex_aluop           (ex_exmem_aluop     ),
        .ex_mem_addr        (ex_exmem_mem_addr  ),
        .ex_reg2            (ex_exmem_reg2      ),

        .men_wd             (ex_men_mem_wd      ),
        .men_wreg           (ex_men_mem_wreg    ),
        .men_wdata          (ex_men_mem_wdata   ),
        .mem_hi             (ex_mem_mem_hi      ),
        .mem_lo             (ex_mem_mem_lo      ),
        .mem_whilo          (ex_mem_mem_whilo   ),

        .cnt_i              (cnt_ex_ex_mem      ),
        .hilo_i             (hilo_temp_ex_ex_mem),
        .cnt_o              (cnt_ex_mem_ex      ),
        .hilo_o             (hilo_temp_ex_mem_ex),
        .mem_aluop          (exmem_mem_aluop    ),
        .mem_mem_addr       (exmem_mem_mem_addr ),
        .mem_reg2           (exmem_mem_reg2     )
    );

    mem mem_inst(
            .rst            (rst                ),

            .wd_i           (ex_men_mem_wd      ),
            .wreg_i         (ex_men_mem_wreg    ),
            .wdata_i        (ex_men_mem_wdata   ),
            .hi_i           (ex_mem_mem_hi      ),
            .lo_i           (ex_mem_mem_lo      ),
            .whilo_i        (ex_mem_mem_whilo   ),
            .aluop_i        (exmem_mem_aluop    ),
            .mem_addr_i     (exmem_mem_mem_addr ),
            .reg2_i         (exmem_mem_reg2     ),



            .wd_o           (men_mem_wb_wd      ),
            .wreg_o         (men_mem_wb_wreg    ),
            .wdata_o        (men_mem_wb_wdata   ),
            .hi_o           (mem_mem_wb_hi      ),
            .lo_o           (mem_mem_wb_lo      ),
            .whilo_o        (mem_mem_wb_whilo   ),

            .mem_data_i     (ram_data_i         ),
            .mem_addr_o     (ram_addr_o         ),
            .mem_we_o       (ram_we_o           ),
            .mem_sel_o      (ram_sel_o          ),
            .mem_data_o     (ram_data_o         ),
            .mem_ce_o       (ram_ce_o           ),

            .LLbit_i         (LLbitreg_mem_LLbit_reg),
            .wb_LLbit_we_i   (memwb_mem_LLbit_we),
            .wb_LLbit_value_i(memwb_mem_LLbit_value),
            .LLbit_we_o      (mem_memwb_LLbit_we),
            .LLbit_value_o   (mem_memwb_LLbit_value)
        );

    mem_wb mem_wb_inst(
        .clk                (clk                ),
        .rst                (rst                ),

        .stall              (stall              ),

        .men_wd             (men_mem_wb_wd      ),
        .men_wreg           (men_mem_wb_wreg    ),
        .men_wdata          (men_mem_wb_wdata   ),
        .mem_hi             (mem_mem_wb_hi      ),
        .mem_lo             (mem_mem_wb_lo      ),
        .mem_whilo          (mem_mem_wb_whilo   ),
        .mem_LLbit_we       (mem_memwb_LLbit_we ),
        .mem_LLbit_value    (mem_memwb_LLbit_value),

        .wb_wd              (wb_regfile_wd      ),
        .wb_wreg            (wb_regfile_wreg    ),
        .wb_wdata           (wb_regfile_wdata   ),
        .wb_hi              (mem_wb_hilo_reg_hi ),
        .wb_lo              (mem_wb_hilo_reg_lo ),
        .wb_whilo           (mem_wb_hilo_reg_whilo),
        .wb_LLbit_we        (memwb_mem_LLbit_we),
        .wb_LLbit_value     (memwb_mem_LLbit_value)
    );

    regfile regfile_inst(
        .clk                (clk                ),
        .rst                (rst                ),

        //write port
        .we                 (wb_regfile_wreg    ),
        .waddr              (wb_regfile_wd      ),
        .wdata              (wb_regfile_wdata   ),

        //read port1
        .re1                (reg1_read_o        ),
        .raddr1             (reg1_addr_o        ),
        .rdata1             (reg1_data_i        ),

        //read port2
        .re2                (reg2_read_o        ),
        .raddr2             (reg2_addr_o        ),
        .rdata2             (reg2_data_i        )
    );

    hilo_reg hilo_reg_inst(
        .clk                (clk                ),
        .rst                (rst                ),

        .we                 (mem_wb_hilo_reg_whilo),
        .hi_i               (mem_wb_hilo_reg_hi ),
        .lo_i               (mem_wb_hilo_reg_lo ),

        .hi_o               (hilo_reg_ex_hi     ),
        .lo_o               (hilo_reg_ex_lo     )
    );

    ctrl ctrl_inst(
        .rst                (rst                ),
        .stallreq_from_id   (stallreq_from_id   ),
        .stallreq_from_ex   (stallreq_from_ex   ),
        .stall              (stall              )
    );

    div div_inst(
        .clk                (clk                ),
        .rst                (rst                ),
        .signed_div_i       (signed_div         ),
        .opdata1_i          (opdata1_div        ),
        .opdata2_i          (opdata2_div        ),
        .start_i            (start_div          ),
        .annul_i            (1'b0               ),

        .result_o           (result_div         ),
        .ready_o            (ready_div          )
    );

    LLbit_reg LLbit_reg_inst(
        .clk                (clk                ),
        .rst                (rst                ),
        .flush              (1'b0               ),
        .LLbit_i            (memwb_mem_LLbit_value),
        .we                 (memwb_mem_LLbit_we ),
        .LLbit_o            (LLbitreg_mem_LLbit_reg)
    );


endmodule

