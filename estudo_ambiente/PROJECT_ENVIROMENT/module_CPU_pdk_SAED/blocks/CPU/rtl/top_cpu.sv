
//`include "/projects/Academy/jm_bedin_space/RTL_VCS/CPU.sv"
//`include "/projects/Academy/jm_bedin_space/RTL_VCS/Memory.sv"

module top_cpu #(
    parameter WIDTH = 8
) (
    input  logic              clk,
    input  logic              rst,
    input  logic [6:0]        cmdin,
    input  logic [WIDTH-1:0]  din_1,
    input  logic [WIDTH-1:0]  din_2,
    input  logic [WIDTH-1:0]  din_3,
    output logic [WIDTH-1:0]  dout_low,
    output logic [WIDTH-1:0]  dout_high,
    output logic              cpu_rdy,
    output logic  [1:0]       p_error
);

    //============================================================
    // Sinais internos
    //============================================================
    logic [WIDTH-1:0] reg_in_a, reg_in_b;
    logic [WIDTH-1:0] alu_in_a, alu_in_b;
    logic [2*WIDTH-1:0] alu_out;
    logic [2*WIDTH-1:0] mux2_out;

    logic [1:0]       in_select_a, in_select_b;
    logic [2:0]       opcode;

    logic aluin_reg_en, cmd_reg_en, aluout_reg_en;
    logic memoryWrite, memoryRead, selmux2;
    logic nvalid_data;
    logic invalid_data;

    //logic [WIDTH-1:0] memoryAddress;
    logic [2*WIDTH-1:0] memoryWriteData, memoryOutData;

    logic [6:0] cmd_in_control;

    //============================================================
    // MUXes de entrada
    //============================================================
    mux4 #(WIDTH) mux_a (
        .in0(din_1),
        .in1(din_2),
        .in2(din_3),
        .in3(dout_high), // feedback
        .sel(in_select_a),
        .out(reg_in_a)
    );
    //assign memoryAddress = reg_in_a;

    mux4 #(WIDTH) mux_b (
        .in0(din_1),
        .in1(din_2),
        .in2(din_3),
        .in3(dout_low), // feedback
        .sel(in_select_b),
        .out(reg_in_b)
    );

    //============================================================
    // Registradores de entrada
    //============================================================
    reg_stage #(WIDTH) reg_a (
        .clk(clk), .rst(rst), .en(aluin_reg_en),
        .d(reg_in_a), .q(alu_in_a)
    );

    reg_stage #(WIDTH) reg_b (
        .clk(clk), .rst(rst), .en(aluin_reg_en),
        .d(reg_in_b), .q(alu_in_b)
    );

    reg_stage #(7) reg_cmd_in (
        .clk(clk), .rst(rst), .en(cmd_reg_en),
        .d(cmdin), .q(cmd_in_control)
    );

    //============================================================
    // ALU
    //============================================================
    alu #(WIDTH) core_alu (
        .a(alu_in_a),
        .b(alu_in_b),
        .opcode(opcode),
        .invalid_input(nvalid_data),
        .y(alu_out),
        .zero(zero),
        .error(error)
    );

    //============================================================
    // Unidade de Controle
    //============================================================
    control cu (
        .clk(clk),
        .rst(rst),
        .cmd_in(cmd_in_control),
        .p_error(p_error[0]),
        .aluin_reg_en(aluin_reg_en),
        .datain_reg_en(cmd_reg_en),
        .memoryWrite(memoryWrite),
        .memoryRead(memoryRead),
        .selmux2(selmux2),
        .cpu_rdy(cpu_rdy),
        .aluout_reg_en(aluout_reg_en),
        .nvalid_data(nvalid_data),
        .in_select_a(in_select_a),
        .in_select_b(in_select_b),
        .opcode(opcode)
    );

    //============================================================
    // MUX 2x1 de saída
    //============================================================
    mux2 #(2*WIDTH) mux2_inst (
        .in0(alu_out),
        .in1(memoryOutData), 
        .sel(selmux2),
        .out(mux2_out)
    );

    //============================================================
    // Registrador de saída
    //============================================================
    reg_stage #(2*WIDTH) reg_out (
        .clk(clk),
        .rst(rst),
        .en(aluout_reg_en),
        .d(mux2_out),
        .q({dout_high, dout_low})
    );

    reg_stage #(2) reg_valid_reg (
        .clk(clk),
        .rst(rst),
        .en(aluout_reg_en),
        .d({zero,error}), 
        .q(p_error)
    );

    //============================================================
    // Memória de registradores
    //============================================================
    register_mem #(
        .WIDTH(WIDTH)
    ) reg_memory_inst (
        .clk(clk),
        .memoryWrite(memoryWrite),
        .memoryRead(memoryRead),
        .memoryWriteData({dout_high, dout_low}),
        .memoryAddress(alu_in_a),
        .memoryOutData(memoryOutData)
    );

endmodule
