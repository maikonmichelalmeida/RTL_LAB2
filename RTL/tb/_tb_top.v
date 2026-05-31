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

// Selecoes dos MUXes
localparam SEL_DIN1 = 2'b00;
localparam SEL_DIN2 = 2'b01;
localparam SEL_DIN3 = 2'b10;
localparam SEL_FB   = 2'b11;

// Operacoes
localparam OP_ADD = 3'b000;
localparam OP_SUB = 3'b001;
localparam OP_MUL = 3'b010;
localparam OP_DIV = 3'b011;

// ADD: A = din_1, B = din_2 -> 14 + 17 = 31 = 16'h001F
localparam CMD_ADD = {SEL_DIN1, SEL_DIN2, OP_ADD};

// SUB: A = din_3, B = dout_low -> 8 - 31 = -23 = 16'hFFE9
localparam CMD_SUB = {SEL_DIN3, SEL_FB, OP_SUB};

// MUL: A = din_2, B = din_3 -> 17 * 8 = 136 = 16'h0088
localparam CMD_MUL = {SEL_DIN2, SEL_DIN3, OP_MUL};

// DIV: A = din_2, B = din_3 -> 17 / 8 = 2 = 16'h0002
localparam CMD_DIV = {SEL_DIN2, SEL_DIN3, OP_DIV};

// DIV ZERO: A = din_2, B = din_3.
// Antes dessa instrucao, din_3 sera alterado para zero.
localparam CMD_DIV_ZERO = {SEL_DIN2, SEL_DIN3, OP_DIV};

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

    din_1  = 8'd14;
    din_2  = 8'd17;
    din_3  = 8'd8;

    cmd_in = CMD_ADD;

    $display("");
    $display("============================================");
    $display("TESTE DO TOP: ADD, SUB, MUL, DIV E DIV ZERO");
    $display("din_1 = %0d", din_1);
    $display("din_2 = %0d", din_2);
    $display("din_3 = %0d", din_3);
    $display("ADD esperado:      14 + 17 = 31  = 16'h001F");
    $display("SUB esperado:       8 - 31 = -23 = 16'hFFE9");
    $display("MUL esperado:      17 * 8  = 136 = 16'h0088");
    $display("DIV esperado:      17 / 8  = 2   = 16'h0002");
    $display("DIV ZERO esperado: 17 / 0  -> 16'hFFFF, error=1");
    $display("============================================");

    // ============================================================
    // RESET INICIAL
    // ============================================================

    #2;
    rst = 1'b1;

    $display("");
    $display("RESET ATIVADO t=%0t", $time);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    #8;
    rst = 1'b0;

    $display("");
    $display("RESET DESATIVADO t=%0t", $time);

    // ============================================================
    // ADD
    // ============================================================

    @(posedge clk);
    #1;
    $display("");
    $display("ADD - BORDA 1");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("cmd_in=%b datain_reg=%b control_cmd=%b",
             cmd_in, dut.datain_reg, dut.control_inst.cmd_in);
    $display("reg_a=%h reg_b=%h alu_out=%h",
             dut.reg_a_out, dut.reg_b_out, dut.alu_out);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("ADD - BORDA 2");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("in_select_a=%b in_select_b=%b aluin_reg_en=%b",
             dut.in_select_a, dut.in_select_b, dut.aluin_reg_en);
    $display("mux_a_out=%h mux_b_out=%h",
             dut.mux_a_out, dut.mux_b_out);
    $display("reg_a=%h reg_b=%h alu_out=%h",
             dut.reg_a_out, dut.reg_b_out, dut.alu_out);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("ADD - BORDA 3");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("reg_a=%h reg_b=%h alu_op=%b alu_out=%h",
             dut.reg_a_out, dut.reg_b_out, dut.alu_op, dut.alu_out);
    $display("alu_zero=%b alu_error=%b",
             dut.alu_zero, dut.alu_error);
    $display("flags_reg_in=%b flags_reg_out=%b",
             dut.flags_reg_in, dut.flags_reg_out);
    $display("aluout_reg_en=%b dout_data=%h",
             dut.aluout_reg_en, dut.dout_data);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    cmd_in = CMD_SUB;

    $display("");
    $display("cmd_in atualizado para SUB antes da captura: %b", cmd_in);

    @(posedge clk);
    #1;
    $display("");
    $display("ADD - BORDA 4: ADD deve estar registrada");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("datain_reg=%b control_cmd=%b",
             dut.datain_reg, dut.control_inst.cmd_in);
    $display("flags_reg_in=%b flags_reg_out=%b p_error=%b",
             dut.flags_reg_in, dut.flags_reg_out, dut.p_error);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    if ((dout_high !== 8'h00) || (dout_low !== 8'h1F) ||
        (zero !== 1'b0) || (error !== 1'b0)) begin
        $display("ERRO NA ADD: esperado dout_high=00 dout_low=1F zero=0 error=0");
        errors = errors + 1;
    end else begin
        $display("OK NA ADD: 14 + 17 = 31");
    end

    // ============================================================
    // SUB
    // ============================================================

    @(posedge clk);
    #1;
    $display("");
    $display("SUB - BORDA 1: captura operandos");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("in_select_a=%b in_select_b=%b aluin_reg_en=%b",
             dut.in_select_a, dut.in_select_b, dut.aluin_reg_en);
    $display("mux_a_out=%h mux_b_out=%h",
             dut.mux_a_out, dut.mux_b_out);
    $display("reg_a=%h reg_b=%h",
             dut.reg_a_out, dut.reg_b_out);
    $display("alu_op=%b alu_out=%h",
             dut.alu_op, dut.alu_out);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("SUB - BORDA 2");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("reg_a=%h reg_b=%h alu_op=%b alu_out=%h",
             dut.reg_a_out, dut.reg_b_out, dut.alu_op, dut.alu_out);
    $display("alu_zero=%b alu_error=%b",
             dut.alu_zero, dut.alu_error);
    $display("flags_reg_in=%b flags_reg_out=%b",
             dut.flags_reg_in, dut.flags_reg_out);
    $display("aluout_reg_en=%b dout_data=%h",
             dut.aluout_reg_en, dut.dout_data);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    cmd_in = CMD_MUL;

    $display("");
    $display("cmd_in atualizado para MUL antes da captura: %b", cmd_in);

    @(posedge clk);
    #1;
    $display("");
    $display("SUB - BORDA 3: SUB deve estar registrada");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("datain_reg=%b control_cmd=%b",
             dut.datain_reg, dut.control_inst.cmd_in);
    $display("flags_reg_in=%b flags_reg_out=%b p_error=%b",
             dut.flags_reg_in, dut.flags_reg_out, dut.p_error);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    if ((dout_high !== 8'hFF) || (dout_low !== 8'hE9) ||
        (zero !== 1'b0) || (error !== 1'b0)) begin
        $display("ERRO NA SUB: esperado dout_high=FF dout_low=E9 zero=0 error=0");
        errors = errors + 1;
    end else begin
        $display("OK NA SUB: 8 - 31 = -23 = 16'hFFE9");
    end

    // ============================================================
    // MUL
    // ============================================================

    @(posedge clk);
    #1;
    $display("");
    $display("MUL - BORDA 1: captura operandos");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("in_select_a=%b in_select_b=%b aluin_reg_en=%b",
             dut.in_select_a, dut.in_select_b, dut.aluin_reg_en);
    $display("mux_a_out=%h mux_b_out=%h",
             dut.mux_a_out, dut.mux_b_out);
    $display("reg_a=%h reg_b=%h",
             dut.reg_a_out, dut.reg_b_out);
    $display("alu_op=%b alu_out=%h",
             dut.alu_op, dut.alu_out);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("MUL - BORDA 2");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("reg_a=%h reg_b=%h alu_op=%b alu_out=%h",
             dut.reg_a_out, dut.reg_b_out, dut.alu_op, dut.alu_out);
    $display("alu_zero=%b alu_error=%b",
             dut.alu_zero, dut.alu_error);
    $display("flags_reg_in=%b flags_reg_out=%b",
             dut.flags_reg_in, dut.flags_reg_out);
    $display("aluout_reg_en=%b dout_data=%h",
             dut.aluout_reg_en, dut.dout_data);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    cmd_in = CMD_DIV;

    $display("");
    $display("cmd_in atualizado para DIV antes da captura: %b", cmd_in);

    @(posedge clk);
    #1;
    $display("");
    $display("MUL - BORDA 3: MUL deve estar registrada");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("datain_reg=%b control_cmd=%b",
             dut.datain_reg, dut.control_inst.cmd_in);
    $display("flags_reg_in=%b flags_reg_out=%b p_error=%b",
             dut.flags_reg_in, dut.flags_reg_out, dut.p_error);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    if ((dout_high !== 8'h00) || (dout_low !== 8'h88) ||
        (zero !== 1'b0) || (error !== 1'b0)) begin
        $display("ERRO NA MUL: esperado dout_high=00 dout_low=88 zero=0 error=0");
        errors = errors + 1;
    end else begin
        $display("OK NA MUL: 17 * 8 = 136");
    end

    // ============================================================
    // DIV
    // ============================================================

    @(posedge clk);
    #1;
    $display("");
    $display("DIV - BORDA 1: captura operandos");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("in_select_a=%b in_select_b=%b aluin_reg_en=%b",
             dut.in_select_a, dut.in_select_b, dut.aluin_reg_en);
    $display("mux_a_out=%h mux_b_out=%h",
             dut.mux_a_out, dut.mux_b_out);
    $display("reg_a=%h reg_b=%h",
             dut.reg_a_out, dut.reg_b_out);
    $display("alu_op=%b alu_out=%h",
             dut.alu_op, dut.alu_out);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("DIV - BORDA 2");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("reg_a=%h reg_b=%h alu_op=%b alu_out=%h",
             dut.reg_a_out, dut.reg_b_out, dut.alu_op, dut.alu_out);
    $display("alu_zero=%b alu_error=%b",
             dut.alu_zero, dut.alu_error);
    $display("flags_reg_in=%b flags_reg_out=%b",
             dut.flags_reg_in, dut.flags_reg_out);
    $display("aluout_reg_en=%b dout_data=%h",
             dut.aluout_reg_en, dut.dout_data);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    din_3  = 8'd0;
    cmd_in = CMD_DIV_ZERO;

    $display("");
    $display("din_3 alterado para 0");
    $display("cmd_in atualizado para DIV ZERO antes da captura: %b", cmd_in);

    @(posedge clk);
    #1;
    $display("");
    $display("DIV - BORDA 3: DIV deve estar registrada");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("datain_reg=%b control_cmd=%b",
             dut.datain_reg, dut.control_inst.cmd_in);
    $display("flags_reg_in=%b flags_reg_out=%b p_error=%b",
             dut.flags_reg_in, dut.flags_reg_out, dut.p_error);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    if ((dout_high !== 8'h00) || (dout_low !== 8'h02) ||
        (zero !== 1'b0) || (error !== 1'b0)) begin
        $display("ERRO NA DIV: esperado dout_high=00 dout_low=02 zero=0 error=0");
        errors = errors + 1;
    end else begin
        $display("OK NA DIV: 17 / 8 = 2");
    end

    // ============================================================
    // DIV POR ZERO
    // ============================================================

    @(posedge clk);
    #1;
    $display("");
    $display("DIV ZERO - BORDA 1: captura operandos");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("in_select_a=%b in_select_b=%b aluin_reg_en=%b",
             dut.in_select_a, dut.in_select_b, dut.aluin_reg_en);
    $display("mux_a_out=%h mux_b_out=%h",
             dut.mux_a_out, dut.mux_b_out);
    $display("reg_a=%h reg_b=%h",
             dut.reg_a_out, dut.reg_b_out);
    $display("alu_op=%b alu_out=%h",
             dut.alu_op, dut.alu_out);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("DIV ZERO - BORDA 2");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("reg_a=%h reg_b=%h alu_op=%b alu_out=%h",
             dut.reg_a_out, dut.reg_b_out, dut.alu_op, dut.alu_out);
    $display("alu_zero=%b alu_error=%b",
             dut.alu_zero, dut.alu_error);
    $display("flags_reg_in=%b flags_reg_out=%b",
             dut.flags_reg_in, dut.flags_reg_out);
    $display("aluout_reg_en=%b dout_data=%h",
             dut.aluout_reg_en, dut.dout_data);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("DIV ZERO - BORDA 3: erro deve estar registrado");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("datain_reg=%b control_cmd=%b",
             dut.datain_reg, dut.control_inst.cmd_in);
    $display("reg_a=%h reg_b=%h alu_out=%h",
             dut.reg_a_out, dut.reg_b_out, dut.alu_out);
    $display("flags_reg_in=%b flags_reg_out=%b p_error=%b",
             dut.flags_reg_in, dut.flags_reg_out, dut.p_error);
    $display("dout_high=%h dout_low=%h zero=%b error=%b cpu_rdy=%b",
             dout_high, dout_low, zero, error, cpu_rdy);

    if ((dout_high !== 8'hFF) || (dout_low !== 8'hFF) ||
        (zero !== 1'b0) || (error !== 1'b1)) begin
        $display("ERRO NA DIV ZERO: esperado dout_high=FF dout_low=FF zero=0 error=1");
        errors = errors + 1;
    end else begin
        $display("OK NA DIV ZERO: 17 / 0 gerou FFFF e error=1");
    end

    // ============================================================
    // RESET FINAL
    // ============================================================

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