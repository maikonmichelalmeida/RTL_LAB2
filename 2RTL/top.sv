module top #(
    parameter int unsigned WIDTH = 8
) (
    input  logic               clk,
    input  logic               rst,
    input  logic [6:0]         cmd_in,
    input  logic [WIDTH-1:0]   din_1,
    input  logic [WIDTH-1:0]   din_2,
    input  logic [WIDTH-1:0]   din_3,
    output logic [2*WIDTH-1:0] output_data,
    output logic               cpu_rdy,
    output logic               zero,
    output logic               error
);

    logic [WIDTH-1:0] datain_reg;
    logic [WIDTH-1:0] datain_reg_din;
    logic             datain_reg_en;

    logic [WIDTH-1:0] dout_low;
    logic [WIDTH-1:0] dout_high;

    logic [1:0] in_select_a;
    logic [1:0] in_select_b;
    logic       aluin_reg_en;
    logic       invalid_data;
    logic [2:0] alu_op;
    logic       memoryWrite;
    logic       memoryRead;
    logic       aluout_reg_en;
    logic       selmux2;
    logic       p_error;

    logic [WIDTH-1:0] mux_a_out;
    logic [WIDTH-1:0] mux_b_out;
    logic [WIDTH-1:0] reg_a_out;
    logic [WIDTH-1:0] reg_b_out;

    logic [2*WIDTH-1:0] alu_out;
    logic               alu_zero;
    logic               alu_error;

    logic [2*WIDTH-1:0] memoryWriteData;
    logic [7:0]         memoryAddress;
    logic [2*WIDTH-1:0] memoryOutData;
    logic [2*WIDTH-1:0] dout_data;

    logic [1:0] flags_alu;
    logic [1:0] flags_reg_in;
    logic [1:0] flags_reg_out;

    assign datain_reg_din = {1'b0, cmd_in};
    assign output_data    = {dout_high, dout_low};
    assign memoryWriteData = {dout_high, dout_low};
    assign memoryAddress   = reg_a_out;
    assign dout_data       = selmux2 ? memoryOutData : alu_out;
    assign flags_reg_in    = {alu_zero, alu_error};
    assign flags_reg_out   = flags_alu;
    assign zero            = flags_alu[1];
    assign error           = flags_alu[0];
    assign p_error         = error;

    regbank #(
        .WIDTH(WIDTH)
    ) datain_register (
        .clk   (clk),
        .rst   (rst),
        .wr_en (datain_reg_en),
        .din   (datain_reg_din),
        .dout  (datain_reg)
    );

    control control_inst (
        .clk           (clk),
        .rst           (rst),
        .cmd_in        (datain_reg[6:0]),
        .p_error       (p_error),
        .datain_reg_en (datain_reg_en),
        .cpu_rdy       (cpu_rdy),
        .in_select_a   (in_select_a),
        .in_select_b   (in_select_b),
        .aluin_reg_en  (aluin_reg_en),
        .invalid_data  (invalid_data),
        .alu_op        (alu_op),
        .memoryWrite   (memoryWrite),
        .memoryRead    (memoryRead),
        .aluout_reg_en (aluout_reg_en),
        .selmux2       (selmux2)
    );

    mux4 #(
        .WIDTH(WIDTH)
    ) mux_a (
        .din1   (din_1),
        .din2   (din_2),
        .din3   (din_3),
        .din4   (dout_high),
        .select (in_select_a),
        .dout   (mux_a_out)
    );

    mux4 #(
        .WIDTH(WIDTH)
    ) mux_b (
        .din1   (din_1),
        .din2   (din_2),
        .din3   (din_3),
        .din4   (dout_low),
        .select (in_select_b),
        .dout   (mux_b_out)
    );

    regbank #(
        .WIDTH(WIDTH)
    ) reg_a (
        .clk   (clk),
        .rst   (rst),
        .wr_en (aluin_reg_en),
        .din   (mux_a_out),
        .dout  (reg_a_out)
    );

    regbank #(
        .WIDTH(WIDTH)
    ) reg_b (
        .clk   (clk),
        .rst   (rst),
        .wr_en (aluin_reg_en),
        .din   (mux_b_out),
        .dout  (reg_b_out)
    );

    alu #(
        .WIDTH(WIDTH)
    ) alu_inst (
        .in1          (reg_a_out),
        .in2          (reg_b_out),
        .op           (alu_op),
        .invalid_data (invalid_data),
        .out          (alu_out),
        .zero         (alu_zero),
        .error        (alu_error)
    );

    memory #(
        .WIDTH(WIDTH)
    ) memory_inst (
        .clk             (clk),
        .memoryWrite     (memoryWrite),
        .memoryRead      (memoryRead),
        .memoryWriteData (memoryWriteData),
        .memoryAddress   (memoryAddress),
        .memoryOutData   (memoryOutData)
    );

    regbank #(
        .WIDTH(WIDTH)
    ) reg_dout_high (
        .clk   (clk),
        .rst   (rst),
        .wr_en (aluout_reg_en),
        .din   (dout_data[2*WIDTH-1:WIDTH]),
        .dout  (dout_high)
    );

    regbank #(
        .WIDTH(WIDTH)
    ) reg_dout_low (
        .clk   (clk),
        .rst   (rst),
        .wr_en (aluout_reg_en),
        .din   (dout_data[WIDTH-1:0]),
        .dout  (dout_low)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            flags_alu <= '0;
        end else if (aluout_reg_en) begin
            flags_alu <= flags_reg_in;
        end
    end

endmodule
