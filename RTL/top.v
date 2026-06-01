module top #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst,
    input  wire [6:0]       cmd_in,

    input  wire [WIDTH-1:0] din_1,
    input  wire [WIDTH-1:0] din_2,
    input  wire [WIDTH-1:0] din_3,

    output wire [2*WIDTH-1:0] output_data,
    output wire             cpu_rdy,
    output wire             zero,
    output wire             error
);

wire [WIDTH-1:0] datain_reg;
wire [WIDTH-1:0] datain_reg_din;
wire             datain_reg_en;

wire [WIDTH-1:0] dout_low;
wire [WIDTH-1:0] dout_high;

// cmd_in tem 7 bits; o regbank existente tem WIDTH=8.
// Usamos datain_reg[6:0] para cmd_in e fixamos datain_reg[7] em 0.
assign datain_reg_din = {1'b0, cmd_in};

wire [1:0] in_select_a;
wire [1:0] in_select_b;
wire       aluin_reg_en;
wire       invalid_data;
wire [2:0] alu_op;
wire       memoryWrite;
wire       memoryRead;
wire       aluout_reg_en;
wire       selmux2;
wire       p_error;

wire [WIDTH-1:0] mux_a_out;
wire [WIDTH-1:0] mux_b_out;

wire [WIDTH-1:0] reg_a_out;
wire [WIDTH-1:0] reg_b_out;

wire [2*WIDTH-1:0] alu_out;
wire               alu_zero;
wire               alu_error;

wire [2*WIDTH-1:0] memoryWriteData;
wire [7:0]         memoryAddress;
wire [2*WIDTH-1:0] memoryOutData;

wire [2*WIDTH-1:0] dout_data;

reg [1:0] flags_alu;

// Apenas sinais auxiliares para visualizacao no testbench.
wire [1:0] flags_reg_in;
wire [1:0] flags_reg_out;

// Saida externa consolidada.
assign output_data = {dout_high, dout_low};

// STORE grava o resultado atualmente registrado nas saidas.
// dout_high ocupa a parte mais significativa; dout_low a menos significativa.
assign memoryWriteData = {dout_high, dout_low};

assign memoryAddress = reg_a_out;

assign dout_data = (selmux2) ? memoryOutData : alu_out;

assign flags_reg_in  = {alu_zero, alu_error};
assign flags_reg_out = flags_alu;

assign zero  = flags_alu[1];
assign error = flags_alu[0];

assign p_error = error;

regbank #(
    .WIDTH(WIDTH)
) datain_register (
    clk,
    rst,
    datain_reg_en,
    datain_reg_din,
    datain_reg
);

control control_inst (
    clk,
    rst,
    datain_reg[6:0],
    p_error,
    datain_reg_en,
    cpu_rdy,
    in_select_a,
    in_select_b,
    aluin_reg_en,
    invalid_data,
    alu_op,
    memoryWrite,
    memoryRead,
    aluout_reg_en,
    selmux2
);

mux4 #(
    .WIDTH(WIDTH)
) mux_a (
    din_1,
    din_2,
    din_3,
    dout_high,
    in_select_a,
    mux_a_out
);

mux4 #(
    .WIDTH(WIDTH)
) mux_b (
    din_1,
    din_2,
    din_3,
    dout_low,
    in_select_b,
    mux_b_out
);

regbank #(
    .WIDTH(WIDTH)
) reg_A (
    clk,
    rst,
    aluin_reg_en,
    mux_a_out,
    reg_a_out
);

regbank #(
    .WIDTH(WIDTH)
) reg_B (
    clk,
    rst,
    aluin_reg_en,
    mux_b_out,
    reg_b_out
);

alu #(
    .WIDTH(WIDTH)
) alu_inst (
    reg_a_out,
    reg_b_out,
    alu_op,
    invalid_data,
    alu_out,
    alu_zero,
    alu_error
);

memory #(
    .WIDTH(WIDTH)
) memory_inst (
    clk,
    memoryWrite,
    memoryRead,
    memoryWriteData,
    memoryAddress,
    memoryOutData
);

regbank #(
    .WIDTH(WIDTH)
) reg_dout_high (
    clk,
    rst,
    aluout_reg_en,
    dout_data[2*WIDTH-1:WIDTH],
    dout_high
);

regbank #(
    .WIDTH(WIDTH)
) reg_dout_low (
    clk,
    rst,
    aluout_reg_en,
    dout_data[WIDTH-1:0],
    dout_low
);

always @(posedge clk or posedge rst) begin : reg2bits
    if (rst) begin
        flags_alu <= 2'b00;
    end else if (aluout_reg_en) begin
        flags_alu <= {alu_zero, alu_error};
    end
end

endmodule