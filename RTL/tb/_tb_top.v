`timescale 1ns/1ps

module tb_top;

parameter WIDTH = 8;

reg              clk;
reg              rst;
reg  [6:0]       cmd_in;

reg  [WIDTH-1:0] din_1;
reg  [WIDTH-1:0] din_2;
reg  [WIDTH-1:0] din_3;

wire [WIDTH-1:0] dout_low;
wire [WIDTH-1:0] dout_high;
wire             cpu_rdy;
wire             zero;
wire             error;

integer errors;

top #(
    .WIDTH(WIDTH)
) dut (
    clk,
    rst,
    cmd_in,
    din_1,
    din_2,
    din_3,
    dout_low,
    dout_high,
    cpu_rdy,
    zero,
    error
);

always #5 clk = ~clk;

initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0, tb_top);
    $fsdbDumpMDA(0, tb_top);

    clk    = 1'b0;
    rst    = 1'b0;
    errors = 0;

    din_1  = 8'd10;
    din_2  = 8'd3;
    din_3  = 8'd7;

    // ADD: mux A = din_1, mux B = din_2, opcode = ADD
    // cmd_in[6:5] = 00 -> din_1
    // cmd_in[4:3] = 01 -> din_2
    // cmd_in[2:0] = 000 -> ADD
    cmd_in = 7'b0001000;

    $display("");
    $display("============================================");
    $display("INICIO DO TESTE SIMPLES DO TOP");
    $display("Objetivo: executar ADD 10 + 3 = 13");
    $display("cmd_in = %b", cmd_in);
    $display("din_1  = %d", din_1);
    $display("din_2  = %d", din_2);
    $display("din_3  = %d", din_3);
    $display("============================================");

    #2;
    rst = 1'b1;
    $display("");
    $display("RESET ATIVADO em t=%0t", $time);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    #8;
    rst = 1'b0;
    $display("");
    $display("RESET DESATIVADO em t=%0t", $time);

    @(posedge clk);
    #1;
    $display("");
    $display("APOS 1a BORDA");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("datain_reg=%b control_cmd=%b", dut.datain_reg, dut.control_inst.cmd_in);
    $display("in_select_a=%b in_select_b=%b", dut.in_select_a, dut.in_select_b);
    $display("mux_a_out=%h mux_b_out=%h", dut.mux_a_out, dut.mux_b_out);
    $display("reg_a_out=%h reg_b_out=%h", dut.reg_a_out, dut.reg_b_out);
    $display("alu_op=%b alu_out=%h alu_zero=%b alu_error=%b",
             dut.alu_op, dut.alu_out, dut.alu_zero, dut.alu_error);
    $display("aluin_reg_en=%b aluout_reg_en=%b", dut.aluin_reg_en, dut.aluout_reg_en);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("APOS 2a BORDA");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("datain_reg=%b control_cmd=%b", dut.datain_reg, dut.control_inst.cmd_in);
    $display("in_select_a=%b in_select_b=%b", dut.in_select_a, dut.in_select_b);
    $display("mux_a_out=%h mux_b_out=%h", dut.mux_a_out, dut.mux_b_out);
    $display("reg_a_out=%h reg_b_out=%h", dut.reg_a_out, dut.reg_b_out);
    $display("alu_op=%b alu_out=%h alu_zero=%b alu_error=%b",
             dut.alu_op, dut.alu_out, dut.alu_zero, dut.alu_error);
    $display("aluin_reg_en=%b aluout_reg_en=%b", dut.aluin_reg_en, dut.aluout_reg_en);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("APOS 3a BORDA");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("datain_reg=%b control_cmd=%b", dut.datain_reg, dut.control_inst.cmd_in);
    $display("in_select_a=%b in_select_b=%b", dut.in_select_a, dut.in_select_b);
    $display("mux_a_out=%h mux_b_out=%h", dut.mux_a_out, dut.mux_b_out);
    $display("reg_a_out=%h reg_b_out=%h", dut.reg_a_out, dut.reg_b_out);
    $display("alu_op=%b alu_out=%h alu_zero=%b alu_error=%b",
             dut.alu_op, dut.alu_out, dut.alu_zero, dut.alu_error);
    $display("aluin_reg_en=%b aluout_reg_en=%b", dut.aluin_reg_en, dut.aluout_reg_en);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("APOS 4a BORDA");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("datain_reg=%b control_cmd=%b", dut.datain_reg, dut.control_inst.cmd_in);
    $display("in_select_a=%b in_select_b=%b", dut.in_select_a, dut.in_select_b);
    $display("mux_a_out=%h mux_b_out=%h", dut.mux_a_out, dut.mux_b_out);
    $display("reg_a_out=%h reg_b_out=%h", dut.reg_a_out, dut.reg_b_out);
    $display("alu_op=%b alu_out=%h alu_zero=%b alu_error=%b",
             dut.alu_op, dut.alu_out, dut.alu_zero, dut.alu_error);
    $display("aluin_reg_en=%b aluout_reg_en=%b", dut.aluin_reg_en, dut.aluout_reg_en);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("APOS 5a BORDA");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("datain_reg=%b control_cmd=%b", dut.datain_reg, dut.control_inst.cmd_in);
    $display("in_select_a=%b in_select_b=%b", dut.in_select_a, dut.in_select_b);
    $display("mux_a_out=%h mux_b_out=%h", dut.mux_a_out, dut.mux_b_out);
    $display("reg_a_out=%h reg_b_out=%h", dut.reg_a_out, dut.reg_b_out);
    $display("alu_op=%b alu_out=%h alu_zero=%b alu_error=%b",
             dut.alu_op, dut.alu_out, dut.alu_zero, dut.alu_error);
    $display("aluin_reg_en=%b aluout_reg_en=%b", dut.aluin_reg_en, dut.aluout_reg_en);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    $display("");
    $display("CHECAGEM FINAL DA ADD");
    $display("Esperado: dout_high=00 dout_low=0d zero=0 error=0");
    $display("Obtido:   dout_high=%h dout_low=%h zero=%b error=%b",
             dout_high, dout_low, zero, error);

    if ((dout_high !== 8'h00) ||
        (dout_low  !== 8'h0D) ||
        (zero      !== 1'b0)  ||
        (error     !== 1'b0)) begin

        $display("ERRO: ADD ainda nao chegou corretamente na saida.");
        errors = errors + 1;
    end else begin
        $display("OK: ADD executada corretamente.");
    end

    rst = 1'b1;
    #2;
    $display("");
    $display("RESET FINAL ATIVADO");
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    if (errors == 0) begin
        $display("");
        $display("TESTE CONCLUIDO COM SUCESSO.");
    end else begin
        $display("");
        $display("TESTE FALHOU: %0d erro(s).", errors);
    end

    $finish;
end

endmodule