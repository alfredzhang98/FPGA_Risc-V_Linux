module div(
    input               clk,
    input               rst,
    input               signed_div_i,
    input   [31:0]      opdata1_i,
    input   [31:0]      opdata2_i,
    input               start_i,
    input               annul_i,

    output reg [63:0]   result_o,
    output reg          ready_o
);

    wire [32:0]         div_temp      ;
    reg [5:0]           cnt           ;
    reg [63:0]          dividend      ;
    reg [31:0]          divisor       ;
    reg [31:0]          temp_op1      ;
    wire [31:0]         temp_op1_load ;
    wire                divisor_temp  ;
    reg [31:0]          temp_op2      ;

    assign div_temp = {1'b0,dividend[63:31]} - {1'b0,divisor};

    //Definitions of FSM
    parameter   DivFree   = 2'b00,
                DivByZero = 2'b01,
                DivOn     = 2'b10,
                DivEnd    = 2'b11;

    reg [1:0] st_cr,st_nx;

    //Logic of FSM
    always @(posedge clk) begin
        if (rst) begin
            st_cr <= DivFree;
        end
        else begin
            st_cr <= st_nx;
        end
    end

    always@(*) begin
        if(rst) begin
            st_nx = DivFree;
        end
        else begin
            case(st_cr)
                DivFree:begin
                    if(start_i == 1'b1 && annul_i == 1'b0 && opdata2_i == 32'b0) begin
                        st_nx = DivByZero;
                    end
                    else if(start_i == 1'b1 && annul_i == 1'b0 && opdata2_i != 32'b0) begin
                        st_nx = DivOn;
                    end
                    else begin
                        st_nx = DivFree;
                    end
                end
                DivByZero: begin
                    st_nx = DivEnd;
                end
                DivOn: begin
                    if(annul_i == 1'b1) begin
                        st_nx = DivFree;
                    end
                    else if(cnt == 6'd31) begin
                        st_nx = DivEnd;
                    end
                    else begin
                        st_nx = DivOn;
                    end
                end
                DivEnd: begin
                        st_nx = DivFree;
                end
                default: begin
                    st_nx = DivFree;
                end
            endcase
        end
    end

    //Logic of temp_op1 and temp_op2
    always@(*) begin
        if(rst) begin
            temp_op1 = 32'b0;
            temp_op2 = 32'b0;
        end
        else if(st_cr == DivFree && start_i == 1'b1) begin
            if(signed_div_i) begin
                temp_op1 = opdata1_i[31] == 1'b1 ? (~opdata1_i + 1) : opdata1_i;
                temp_op2 = opdata2_i[31] == 1'b1 ? (~opdata2_i + 1) : opdata2_i;
            end
            else begin
                temp_op1 = opdata1_i;
                temp_op2 = opdata2_i;
            end
        end
        else begin
            temp_op1 = 32'b0;
            temp_op2 = 32'b0;
        end
    end
    assign temp_op1_load = {31'b0,temp_op1[31]} > temp_op2 ? {31'b0,temp_op1[31]} - temp_op2 : {31'b0,temp_op1[31]};
    assign divisor_temp = {31'b0,temp_op1[31]} > temp_op2 ? 1'b1:1'b0;

    always@(posedge clk) begin
        if(rst) begin
            dividend <= 64'b0;
            divisor <= 32'b0;
        end
        else begin
            case(st_cr)
                DivFree: begin
                    if(start_i) begin
                        dividend <= {temp_op1_load,temp_op1[30:0],divisor_temp};
                        divisor <= temp_op2;
                    end
                end
                DivByZero: begin
                    dividend <= 64'b0;
                end
                DivOn: begin
                    if(div_temp[31] == 1'b1) begin
                        dividend <= {dividend[62:0],1'b0};
                    end
                    else begin
                        dividend <= {div_temp,dividend[30:0],1'b1};
                    end

                end
            endcase
        end
    end

    always@(*) begin
        if(rst)
            result_o[31:0] = 32'b0;
        else if(signed_div_i && (opdata2_i[31] ^ opdata1_i[31] == 1'b1)) begin
            result_o[31:0] = ~dividend[31:0]+1'b1;
        end
        else begin
            result_o[31:0] = dividend[31:0];
        end
    end

    always@(*) begin
        if(rst)
            result_o[63:32] = 32'b0;
        else if(signed_div_i && (opdata1_i[31] == 1'b1)) begin
            result_o[63:32] = ~dividend[63:32]+1'b1;
        end
        else begin
            result_o[63:32] = dividend[63:32];
        end
    end

    always@(*) begin
        if(rst)
            ready_o = 1'b0;
        else if(st_cr == DivEnd)
            ready_o = 1'b1;
        else begin
            ready_o = 1'b0;
        end
    end


    always@(posedge clk) begin
        if(rst) begin
            cnt <= 6'b0;
        end
        else if(st_cr == DivOn || (st_cr == DivFree && start_i == 1'b1)) begin
            cnt <= cnt + 1'b1;
        end
        else begin
            cnt <= 6'd0;
        end
    end



endmodule

