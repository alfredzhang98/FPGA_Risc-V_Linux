module regfile(
    input                       clk     ,
    input                       rst     ,

    //write port
    input                       we      ,
    input       [`RegAddrBus]   waddr   ,
    input       [`RegBus]       wdata   ,

    //read port1
    input                       re1     ,
    input       [`RegAddrBus]   raddr1  ,
    output reg  [`RegBus]       rdata1  ,

    //read port2
    input                       re2     ,
    input       [`RegAddrBus]   raddr2  ,
    output reg  [`RegBus]       rdata2
    );

//*************definitions*****************************//
reg [`RegBus] regs [0:`RegNum-1];


//************logic of write regs*********************//
always @(posedge clk) begin
    if (rst == `RstDisable) begin
        if(we)
            regs[waddr] <= wdata;
    end
end

//**************logic of read port1********************//
always@(*) begin
    if(rst == `RstEnalbe)
        rdata1 = `ZeroWord;
    else if(raddr1 == `RegNumLog2'h0)
        rdata1 = `ZeroWord;
    else if(we && waddr == raddr1 && re1)
        rdata1 = wdata;
    else if(re1)
        rdata1 = regs[raddr1];
    else
        rdata1 = `ZeroWord;
end


//**************logic of read port2********************//
always@(*) begin
    if(rst == `RstEnalbe)
        rdata2 = `ZeroWord;
    else if(raddr2 == `RegNumLog2'h0)
        rdata2 = `ZeroWord;
    else if(we && waddr == raddr2 && re2)
        rdata2 = wdata;
    else if(re2)
        rdata2 = regs[raddr1];
    else
        rdata2 = `ZeroWord;
end



endmodule