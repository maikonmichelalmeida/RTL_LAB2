module top #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst,
    input  wire [6:0]       cmd_in,

    input  wire [WIDTH-1:0] din_1,
    input  wire [WIDTH-1:0] din_2,
    input  wire [WIDTH-1:0] din_3,

    output wire             cpu_rdy
);

wire [WIDTH-1:0] datain_reg;
wire [WIDTH-1:0] datain_reg_din;
wire             datain_reg_en;

// cmd_in tem 7 bits. O regbank existente tem WIDTH=8.
// Por isso, cmd_in fica em datain_reg[6:0] e datain_reg[7] recebe 0.
assign datain_reg_din = {1'b0, cmd_in};

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
    datain_reg_en,
    cpu_rdy
);

endmodule