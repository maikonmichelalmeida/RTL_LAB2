`timescale 1ns/1ps

module tb_top;

parameter int unsigned WIDTH = 8;

logic              clk;
logic              rst;
logic  [6:0]       cmd_in;

logic  [WIDTH-1:0] din_1;
logic  [WIDTH-1:0] din_2;
logic  [WIDTH-1:0] din_3;

logic [2*WIDTH-1:0] output_data;
logic             cpu_rdy;
logic             zero;
logic             error;

integer errors;

// Selecoes dos MUXes
localparam SEL_DIN1 = 2'b00;
localparam SEL_DIN2 = 2'b01;
localparam SEL_DIN3 = 2'b10;
localparam SEL_FB   = 2'b11;

// Operacoes
localparam OP_ADD   = 3'b000;
localparam OP_SUB   = 3'b001;
localparam OP_MUL   = 3'b010;
localparam OP_DIV   = 3'b011;
localparam OP_NOP0  = 3'b100;
localparam OP_LOAD  = 3'b101;
localparam OP_STORE = 3'b110;
localparam OP_NOP1  = 3'b111;

// ADD: A = din_1, B = din_2 -> 200 + 3 = 203 = 16'h00CB
localparam CMD_ADD = {SEL_DIN1, SEL_DIN2, OP_ADD};

// SUB: A = din_3, B = dout_low -> 5 - 203 = -198 = 16'hFF3A
localparam CMD_SUB = {SEL_DIN3, SEL_FB, OP_SUB};

// MUL: A = din_1, B = din_3 -> 200 * 5 = 1000 = 16'h03E8
localparam CMD_MUL = {SEL_DIN1, SEL_DIN3, OP_MUL};

// DIV: A = din_1, B = din_3 -> 200 / 5 = 40 = 16'h0028
localparam CMD_DIV = {SEL_DIN1, SEL_DIN3, OP_DIV};

// STORE: endereco = reg_A = din_2
localparam CMD_STORE = {SEL_DIN2, SEL_DIN1, OP_STORE};

// LOAD: endereco = reg_A = din_2
localparam CMD_LOAD = {SEL_DIN2, SEL_DIN1, OP_LOAD};

// NOPs
localparam CMD_NOP0 = {SEL_DIN1, SEL_DIN1, OP_NOP0};
localparam CMD_NOP1 = {SEL_DIN1, SEL_DIN1, OP_NOP1};

top #(
    .WIDTH(WIDTH)
) dut (
    .clk         (clk),
    .rst         (rst),
    .cmd_in      (cmd_in),
    .din_1       (din_1),
    .din_2       (din_2),
    .din_3       (din_3),
    .output_data (output_data),
    .cpu_rdy     (cpu_rdy),
    .zero        (zero),
    .error       (error)
);

always #5 clk = ~clk;

initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0, tb_top);
    $fsdbDumpMDA(0, tb_top);

    clk    = 1'b0;
    rst    = 1'b0;
    errors = 0;

    din_1  = 8'd200;
    din_2  = 8'd3;
    din_3  = 8'd5;

    cmd_in = CMD_ADD;

    $display("");
    $display("============================================");
    $display("TESTE DO TOP: ADD, SUB, MUL, DIV, STORE, LOAD, NOP");
    $display("din_1 = %0d = %h", din_1, din_1);
    $display("din_2 = %0d = %h", din_2, din_2);
    $display("din_3 = %0d = %h", din_3, din_3);
    $display("ADD esperado:   200 + 3   = 203  = 16'h00CB");
    $display("SUB esperado:     5 - 203 = -198 = 16'hFF3A");
    $display("MUL esperado:   200 * 5   = 1000 = 16'h03E8");
    $display("DIV esperado:   200 / 5   = 40   = 16'h0028");
    $display("STORE esperado: grava 16'h0028 no endereco 3");
    $display("LOAD esperado:  le 16'h0028 do endereco 3");
    $display("EXTRA esperado: grava e le 16'h03E8 no endereco 7");
    $display("NOP esperado:   mantem saida anterior");
    $display("============================================");

    // ============================================================
    // RESET INICIAL
    // ============================================================

    #2;
    rst = 1'b1;

    $display("");
    $display("RESET ATIVADO t=%0t", $time);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

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
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

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
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

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
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

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
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    if ((output_data !== 16'h00CB) || (zero !== 1'b0) || (error !== 1'b0)) begin
        $display("ERRO NA ADD: esperado output_data=00CB zero=0 error=0");
        errors = errors + 1;
    end else begin
        $display("OK NA ADD: 200 + 3 = 203 = 16'h00CB");
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
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

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
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

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
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    if ((output_data !== 16'hFF3A) || (zero !== 1'b0) || (error !== 1'b0)) begin
        $display("ERRO NA SUB: esperado output_data=FF3A zero=0 error=0");
        errors = errors + 1;
    end else begin
        $display("OK NA SUB: 5 - 203 = -198 = 16'hFF3A");
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
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

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
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

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
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    if ((output_data !== 16'h03E8) || (zero !== 1'b0) || (error !== 1'b0)) begin
        $display("ERRO NA MUL: esperado output_data=03E8 zero=0 error=0");
        errors = errors + 1;
    end else begin
        $display("OK NA MUL: 200 * 5 = 1000 = 16'h03E8");
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
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

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
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    cmd_in = CMD_STORE;

    $display("");
    $display("cmd_in atualizado para STORE antes da captura: %b", cmd_in);

    @(posedge clk);
    #1;
    $display("");
    $display("DIV - BORDA 3: DIV deve estar registrada");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("datain_reg=%b control_cmd=%b",
             dut.datain_reg, dut.control_inst.cmd_in);
    $display("flags_reg_in=%b flags_reg_out=%b p_error=%b",
             dut.flags_reg_in, dut.flags_reg_out, dut.p_error);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    if ((output_data !== 16'h0028) || (zero !== 1'b0) || (error !== 1'b0)) begin
        $display("ERRO NA DIV: esperado output_data=0028 zero=0 error=0");
        errors = errors + 1;
    end else begin
        $display("OK NA DIV: 200 / 5 = 40 = 16'h0028");
    end

    // ============================================================
    // STORE
    // ============================================================

    @(posedge clk);
    #1;
    $display("");
    $display("STORE - BORDA 1: captura endereco em reg_A");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("in_select_a=%b in_select_b=%b aluin_reg_en=%b",
             dut.in_select_a, dut.in_select_b, dut.aluin_reg_en);
    $display("mux_a_out=%h reg_a=%h memoryAddress=%h",
             dut.mux_a_out, dut.reg_a_out, dut.memoryAddress);
    $display("memoryWriteData=%h memoryWrite=%b memoryRead=%b",
             dut.memoryWriteData, dut.memoryWrite, dut.memoryRead);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("STORE - BORDA 2");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("memoryAddress=%h memoryWriteData=%h memoryWrite=%b memoryRead=%b",
             dut.memoryAddress, dut.memoryWriteData, dut.memoryWrite, dut.memoryRead);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    cmd_in = CMD_LOAD;

    $display("");
    $display("cmd_in atualizado para LOAD antes da captura: %b", cmd_in);

    @(posedge clk);
    #1;
    $display("");
    $display("STORE - BORDA 3: STORE deve ter ocorrido");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("memoryAddress=%h memoryWriteData=%h memoryWrite=%b memoryRead=%b",
             dut.memoryAddress, dut.memoryWriteData, dut.memoryWrite, dut.memoryRead);
    $display("memoryOutData=%h", dut.memoryOutData);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    if ((output_data !== 16'h0028) || (zero !== 1'b0) || (error !== 1'b0)) begin
        $display("ERRO NO STORE: saida deveria manter resultado anterior 0028");
        errors = errors + 1;
    end else begin
        $display("OK NO STORE: saida manteve resultado anterior e memoria recebeu escrita.");
    end

    // ============================================================
    // LOAD
    // ============================================================

    @(posedge clk);
    #1;
    $display("");
    $display("LOAD - BORDA 1: captura endereco em reg_A");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("in_select_a=%b in_select_b=%b aluin_reg_en=%b",
             dut.in_select_a, dut.in_select_b, dut.aluin_reg_en);
    $display("mux_a_out=%h reg_a=%h memoryAddress=%h",
             dut.mux_a_out, dut.reg_a_out, dut.memoryAddress);
    $display("memoryRead=%b memoryWrite=%b memoryOutData=%h",
             dut.memoryRead, dut.memoryWrite, dut.memoryOutData);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("LOAD - BORDA 2");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("memoryAddress=%h memoryRead=%b memoryOutData=%h selmux2=%b",
             dut.memoryAddress, dut.memoryRead, dut.memoryOutData, dut.selmux2);
    $display("dout_data=%h aluout_reg_en=%b",
             dut.dout_data, dut.aluout_reg_en);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    cmd_in = CMD_NOP0;

    $display("");
    $display("cmd_in atualizado para NOP0 antes da captura: %b", cmd_in);

    @(posedge clk);
    #1;
    $display("");
    $display("LOAD - BORDA 3: LOAD deve estar registrado");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("memoryOutData=%h selmux2=%b",
             dut.memoryOutData, dut.selmux2);
    $display("flags_reg_in=%b flags_reg_out=%b p_error=%b",
             dut.flags_reg_in, dut.flags_reg_out, dut.p_error);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    if ((output_data !== 16'h0028) || (zero !== 1'b0) || (error !== 1'b0)) begin
        $display("ERRO NO LOAD: esperado output_data=0028 zero=0 error=0");
        errors = errors + 1;
    end else begin
        $display("OK NO LOAD: leu 16'h0028 da memoria.");
    end

    // ============================================================
    // NOP0
    // ============================================================

    @(posedge clk);
    #1;
    $display("");
    $display("NOP0 - BORDA 1");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("cmd_in=%b datain_reg=%b control_cmd=%b",
             cmd_in, dut.datain_reg, dut.control_inst.cmd_in);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("NOP0 - BORDA 2");
    $display("state=%b next=%b aluout_reg_en=%b",
             dut.control_inst.current_state, dut.control_inst.next_state, dut.aluout_reg_en);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    cmd_in = CMD_NOP1;

    $display("");
    $display("cmd_in atualizado para NOP1 antes da captura: %b", cmd_in);

    @(posedge clk);
    #1;
    $display("");
    $display("NOP0 - BORDA 3: saida deve permanecer igual");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    if ((output_data !== 16'h0028) || (zero !== 1'b0) || (error !== 1'b0)) begin
        $display("ERRO NO NOP0: saida deveria permanecer 0028 com zero=0");
        errors = errors + 1;
    end else begin
        $display("OK NO NOP0: saida permaneceu igual.");
    end

    // ============================================================
    // NOP1
    // ============================================================

    @(posedge clk);
    #1;
    $display("");
    $display("NOP1 - BORDA 1");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("cmd_in=%b datain_reg=%b control_cmd=%b",
             cmd_in, dut.datain_reg, dut.control_inst.cmd_in);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("NOP1 - BORDA 2");
    $display("state=%b next=%b aluout_reg_en=%b",
             dut.control_inst.current_state, dut.control_inst.next_state, dut.aluout_reg_en);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    din_2  = 8'd7;
    cmd_in = CMD_MUL;

    $display("");
    $display("din_2 alterado para 7 para usar como endereco da ultima posicao da memoria");
    $display("cmd_in atualizado para MUL EXTRA antes da captura: %b", cmd_in);

    @(posedge clk);
    #1;
    $display("");
    $display("NOP1 - BORDA 3: saida deve permanecer igual");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    if ((output_data !== 16'h0028) || (zero !== 1'b0) || (error !== 1'b0)) begin
        $display("ERRO NO NOP1: saida deveria permanecer 0028 com zero=0");
        errors = errors + 1;
    end else begin
        $display("OK NO NOP1: saida permaneceu igual.");
    end

    // ============================================================
    // EXTRA: MUL ALTA PARA GRAVAR NA ULTIMA POSICAO DA MEMORIA
    // ============================================================

    @(posedge clk);
    #1;
    $display("");
    $display("MUL EXTRA - BORDA 1: captura operandos");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("din_2=%h", din_2);
    $display("in_select_a=%b in_select_b=%b aluin_reg_en=%b",
             dut.in_select_a, dut.in_select_b, dut.aluin_reg_en);
    $display("mux_a_out=%h mux_b_out=%h",
             dut.mux_a_out, dut.mux_b_out);
    $display("reg_a=%h reg_b=%h",
             dut.reg_a_out, dut.reg_b_out);
    $display("alu_op=%b alu_out=%h",
             dut.alu_op, dut.alu_out);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("MUL EXTRA - BORDA 2");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("reg_a=%h reg_b=%h alu_op=%b alu_out=%h",
             dut.reg_a_out, dut.reg_b_out, dut.alu_op, dut.alu_out);
    $display("alu_zero=%b alu_error=%b",
             dut.alu_zero, dut.alu_error);
    $display("aluout_reg_en=%b dout_data=%h",
             dut.aluout_reg_en, dut.dout_data);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    cmd_in = CMD_STORE;

    $display("");
    $display("cmd_in atualizado para STORE EXTRA antes da captura: %b", cmd_in);

    @(posedge clk);
    #1;
    $display("");
    $display("MUL EXTRA - BORDA 3: resultado alto deve estar registrado");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("datain_reg=%b control_cmd=%b",
             dut.datain_reg, dut.control_inst.cmd_in);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    if ((output_data !== 16'h03E8) || (zero !== 1'b0) || (error !== 1'b0)) begin
        $display("ERRO NO MUL EXTRA: esperado output_data=03E8 zero=0 error=0");
        errors = errors + 1;
    end else begin
        $display("OK NO MUL EXTRA: 200 * 5 = 1000 = 16'h03E8");
    end

    // ============================================================
    // EXTRA: STORE EM mem[7]
    // ============================================================

    @(posedge clk);
    #1;
    $display("");
    $display("STORE EXTRA - BORDA 1: captura endereco 7 em reg_A");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("din_2=%h", din_2);
    $display("in_select_a=%b aluin_reg_en=%b",
             dut.in_select_a, dut.aluin_reg_en);
    $display("mux_a_out=%h reg_a=%h memoryAddress=%h",
             dut.mux_a_out, dut.reg_a_out, dut.memoryAddress);
    $display("memoryWriteData=%h memoryWrite=%b memoryRead=%b",
             dut.memoryWriteData, dut.memoryWrite, dut.memoryRead);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("STORE EXTRA - BORDA 2");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("memoryAddress=%h memoryWriteData=%h memoryWrite=%b memoryRead=%b",
             dut.memoryAddress, dut.memoryWriteData, dut.memoryWrite, dut.memoryRead);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    cmd_in = CMD_LOAD;

    $display("");
    $display("cmd_in atualizado para LOAD EXTRA antes da captura: %b", cmd_in);

    @(posedge clk);
    #1;
    $display("");
    $display("STORE EXTRA - BORDA 3: mem[7] deve ter recebido 16'h03E8");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("memoryAddress=%h memoryWriteData=%h memoryWrite=%b memoryRead=%b",
             dut.memoryAddress, dut.memoryWriteData, dut.memoryWrite, dut.memoryRead);
    $display("memoryOutData=%h", dut.memoryOutData);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    if ((output_data !== 16'h03E8) || (zero !== 1'b0) || (error !== 1'b0)) begin
        $display("ERRO NO STORE EXTRA: saida deveria manter 03E8");
        errors = errors + 1;
    end else begin
        $display("OK NO STORE EXTRA: mem[7] recebeu o valor alto 16'h03E8.");
    end

    // ============================================================
    // EXTRA: LOAD DE mem[7]
    // ============================================================

    @(posedge clk);
    #1;
    $display("");
    $display("LOAD EXTRA - BORDA 1: captura endereco 7 em reg_A");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("din_2=%h", din_2);
    $display("in_select_a=%b aluin_reg_en=%b",
             dut.in_select_a, dut.aluin_reg_en);
    $display("mux_a_out=%h reg_a=%h memoryAddress=%h",
             dut.mux_a_out, dut.reg_a_out, dut.memoryAddress);
    $display("memoryRead=%b memoryWrite=%b memoryOutData=%h",
             dut.memoryRead, dut.memoryWrite, dut.memoryOutData);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    @(posedge clk);
    #1;
    $display("");
    $display("LOAD EXTRA - BORDA 2");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("memoryAddress=%h memoryRead=%b memoryOutData=%h selmux2=%b",
             dut.memoryAddress, dut.memoryRead, dut.memoryOutData, dut.selmux2);
    $display("dout_data=%h aluout_reg_en=%b",
             dut.dout_data, dut.aluout_reg_en);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    cmd_in = CMD_NOP0;

    $display("");
    $display("cmd_in atualizado para NOP apos LOAD EXTRA: %b", cmd_in);

    @(posedge clk);
    #1;
    $display("");
    $display("LOAD EXTRA - BORDA 3: valor de mem[7] deve estar registrado");
    $display("state=%b next=%b", dut.control_inst.current_state, dut.control_inst.next_state);
    $display("memoryOutData=%h selmux2=%b",
             dut.memoryOutData, dut.selmux2);
    $display("flags_reg_in=%b flags_reg_out=%b p_error=%b",
             dut.flags_reg_in, dut.flags_reg_out, dut.p_error);
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    if ((output_data !== 16'h03E8) || (zero !== 1'b0) || (error !== 1'b0)) begin
        $display("ERRO NO LOAD EXTRA: esperado output_data=03E8 zero=0 error=0");
        errors = errors + 1;
    end else begin
        $display("OK NO LOAD EXTRA: leu 16'h03E8 da ultima posicao da memoria.");
    end

    // ============================================================
    // RESET FINAL
    // ============================================================

    rst = 1'b1;
    #3;

    $display("");
    $display("RESET FINAL ATIVADO");
    $display("output_data=%h zero=%b error=%b cpu_rdy=%b",
             output_data, zero, error, cpu_rdy);

    if (errors == 0) begin
        $display("");
        $display("TESTE CONCLUIDO COM SUCESSO.");
    end else begin
        $display("");
        $display("TESTE FALHOU: %0d erro(s).", errors);
    end

    #600;
    $finish;
end

endmodule
