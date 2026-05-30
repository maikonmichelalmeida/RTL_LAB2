module control (
    input  wire       clk,
    input  wire       rst,
    input  wire [6:0] cmd_in,
    input  wire       p_error,

    output wire       datain_reg_en,
    output wire       cpu_rdy,

    output wire [1:0] in_select_a,
    output wire [1:0] in_select_b,
    output wire       aluin_reg_en,
    output wire       invalid_data,
    output wire [2:0] alu_op,
    output wire       memoryWrite,
    output wire       memoryRead,
    output wire       aluout_reg_en,
    output wire       selmux2
);

assign datain_reg_en = 1'b1;
assign cpu_rdy       = 1'b0;

assign in_select_a   = 2'b00;
assign in_select_b   = 2'b00;
assign aluin_reg_en  = 1'b0;
assign invalid_data  = 1'b0;

assign alu_op        = cmd_in[2:0];

assign memoryWrite   = 1'b0;
assign memoryRead    = 1'b0;

// Temporario: habilitado para permitir registrar o resultado da primeira ADD.
assign aluout_reg_en = 1'b1;

assign selmux2       = 1'b0;

endmodule