module openmips(
        input                   clk         ,
        input                   rst         ,

        input   [`InstBus]      rom_data_i  ,
        output  [`InstAddrBus]  rom_addr_o  ,
        output                  rom_ce_o

    );

//************definitions******************//
//connection between pc_reg and if_id
wire [`InstAddrBus]     if_pc;
wire                    ce;

//connection between if_id and id

wire [`InstBus]         id_inst;

//connection between id and id_ex
wire       [`AluOpBus]             id_aluop    ;
wire       [`AluSelBus]            id_alusel   ;
wire       [`RegBus]               id_reg1     ;
wire       [`RegBus]               id_reg2     ;
wire       [`RegAddrBus]           id_wd       ;
wire                               id_wreg     ;

//connection between id_ex and ex
wire       [`AluOpBus]             ex_aluop    ;
wire       [`AluSelBus]            ex_alusel   ;
wire       [`RegBus]               ex_reg1     ;
wire       [`RegBus]               ex_reg2     ;
wire       [`RegAddrBus]           ex_wd       ;
wire                               ex_wreg     ;

//connection between ex and ex_mem
wire [`RegAddrBus]        ex_mem_wd        ;
wire                      ex_mem_wreg      ;
wire [`RegBus]            ex_mem_wdata     ;

//connection between ex_mem and mem
wire [`RegAddrBus]         ex_men_mem_wd      ;
wire                       ex_men_mem_wreg    ;
wire  [`RegBus]            ex_men_mem_wdata   ;

//connection between mem and mem_wb
wire [`RegAddrBus]         men_mem_wb_wd      ;
wire                       men_mem_wb_wreg    ;
wire  [`RegBus]            men_mem_wb_wdata   ;

//connection between mem_wb and regfile
wire [`RegAddrBus]    wb_regfile_wd     ;
wire                  wb_regfile_wreg   ;
wire [`RegBus]        wb_regfile_wdata  ;

//connection between id and regfile

wire      [`RegBus]               reg1_data_i ;
wire      [`RegBus]               reg2_data_i ;

wire                              reg1_read_o ;
wire                              reg2_read_o ;
wire      [`RegAddrBus]           reg1_addr_o ;
wire      [`RegAddrBus]           reg2_addr_o ;


//************inst of modules*************//
//inst of pc_reg
pc_reg pc_reg_inst(
        .clk    (clk)   ,
        .rst    (rst)   ,
        .pc     (if_pc)    ,
        .ce     (rom_ce_o)

    );

//inst of if_id
if_id if_id_inst(
        .clk     (clk),
        .rst     (rst),
        .if_pc   (if_pc),
        .if_inst (rom_data_i),
        .id_pc   (rom_addr_o),
        .id_inst (id_inst)


    );

//inst of id
id id_inst0(
    .rst         (rst),

    //from if_id
    .pc_i       (rom_addr_o),
    .inst_i     (id_inst),

    //from regfile
    .reg1_data_i ,
    .reg2_data_i ,

    //output to regfile
    .reg1_read_o ,
    .reg2_read_o ,
    .reg1_addr_o ,
    .reg2_addr_o ,

    //to ex
    .aluop_o    (id_aluop),
    .alusel_o   (id_alusel),
    .reg1_o     (id_reg1),
    .reg2_o     (id_reg2),
    .wd_o       (id_wd),
    .wreg_o     (id_wreg)
    );

id_ex id_ex_inst(
    .clk        (clk),
    .rst        (rst),

    //from instruction decode module
    .id_aluop    (id_aluop),
    .id_alusel   (id_alusel),
    .id_reg1     (id_reg1),
    .id_reg2     (id_reg2),
    .id_wd       (id_wd),
    .id_wreg     (id_wreg),

    //to excution module
    .ex_aluop    (ex_aluop ),
    .ex_alusel   (ex_alusel),
    .ex_reg1     (ex_reg1  ),
    .ex_reg2     (ex_reg2  ),
    .ex_wd       (ex_wd    ),
    .ex_wreg     (ex_wreg  )

    );


ex ex_inst(
    .rst                (rst      ),

    .aluop_i            (ex_aluop ),
    .alusel_i           (ex_alusel),
    .reg1_i             (ex_reg1  ),
    .reg2_i             (ex_reg2  ),
    .wd_i               (ex_wd    ),
    .wreg_i             (ex_wreg  ),

    .wd_o               (ex_mem_wd    )    ,
    .wreg_o             (ex_mem_wreg  )    ,
    .wdata_o            (ex_mem_wdata )

);

ex_mem ex_mem_inst(
    .clk            (clk)     ,
    .rst            (rst)       ,

    .ex_wd          (ex_mem_wd    ),
    .ex_wreg        (ex_mem_wreg  ),
    .ex_wdata       (ex_mem_wdata ),

    .men_wd         (ex_men_mem_wd   ),
    .men_wreg       (ex_men_mem_wreg ),
    .men_wdata      (ex_men_mem_wdata)
);

mem mem_inst(
        .rst    (rst             ),

        .wd_i   (ex_men_mem_wd   ),
        .wreg_i (ex_men_mem_wreg ),
        .wdata_i(ex_men_mem_wdata),

        .wd_o   (men_mem_wb_wd),
        .wreg_o (men_mem_wb_wreg),
        .wdata_o(men_mem_wb_wdata)
    );

mem_wb mem_wb_inst(
    .clk         (clk),
    .rst         (rst),

    .men_wd      (men_mem_wb_wd),
    .men_wreg    (men_mem_wb_wreg),
    .men_wdata   (men_mem_wb_wdata),

    .wb_wd       (wb_regfile_wd   ),
    .wb_wreg     (wb_regfile_wreg ),
    .wb_wdata    (wb_regfile_wdata)

    );

regfile regfile_inst(
    .clk     (clk),
    .rst     (rst),

    //write port
    .we      (wb_regfile_wreg),
    .waddr   (wb_regfile_wd),
    .wdata   (wb_regfile_wdata),

    //read port1
    .re1     (reg1_read_o),
    .raddr1  (reg1_addr_o),
    .rdata1  (reg1_data_i),

    //read port2
    .re2     (reg2_read_o),
    .raddr2  (reg2_addr_o),
    .rdata2  (reg2_data_i)
    );


endmodule