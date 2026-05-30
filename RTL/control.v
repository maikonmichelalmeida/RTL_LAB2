module control (
    input  wire       clk,
    input  wire       rst,
    input  wire [6:0] cmd_in,

    output wire       datain_reg_en,
    output wire       cpu_rdy
);

assign datain_reg_en = 1'b1;
assign cpu_rdy       = 1'b0;

endmodule