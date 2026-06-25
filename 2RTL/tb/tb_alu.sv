`timescale 1ns/1ps

module tb_alu;

parameter int unsigned WIDTH = 8;

localparam OP_ADD = 3'b000;
localparam OP_SUB = 3'b001;
localparam OP_MUL = 3'b010;
localparam OP_DIV = 3'b011;

logic  [WIDTH-1:0]     in1;
logic  [WIDTH-1:0]     in2;
logic  [2:0]           op;
logic                  invalid_data;

logic [2*WIDTH-1:0]   out;
logic                 zero;
logic                 error;

integer errors;

alu #(
    .WIDTH(WIDTH)
) dut (
    .in1          (in1),
    .in2          (in2),
    .op           (op),
    .invalid_data (invalid_data),
    .out          (out),
    .zero         (zero),
    .error        (error)
);

task automatic apply_and_check(
    input logic [WIDTH-1:0]   test_in1,
    input logic [WIDTH-1:0]   test_in2,
    input logic [2:0]         test_op,
    input logic               test_invalid,
    input logic [2*WIDTH-1:0] expected_out,
    input logic               expected_zero,
    input logic               expected_error
);
    begin
        in1          = test_in1;
        in2          = test_in2;
        op           = test_op;
        invalid_data = test_invalid;

        #10;

        if ((out !== expected_out) ||
            (zero !== expected_zero) ||
            (error !== expected_error)) begin

            $display("ERRO: op=%b in1=%h in2=%h invalid=%b | out=%h zero=%b error=%b | esperado out=%h zero=%b error=%b",
                     op, in1, in2, invalid_data,
                     out, zero, error,
                     expected_out, expected_zero, expected_error);

            errors = errors + 1;
        end else begin
            $display("OK:   op=%b in1=%h in2=%h invalid=%b | out=%h zero=%b error=%b",
                     op, in1, in2, invalid_data,
                     out, zero, error);
        end
    end
endtask

initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0, tb_alu);

    in1          = {WIDTH{1'b0}};
    in2          = {WIDTH{1'b0}};
    op           = 4'b0000;
    invalid_data = 1'b0;
    errors       = 0;

    // Teste 1: soma - 10 + 5 = 15
    apply_and_check(
        8'd10, 8'd5, OP_ADD, 1'b0,
        16'h000F, 1'b0, 1'b0
    );

    // Teste 2: subtracao positiva - 10 - 3 = 7
    apply_and_check(
        8'd10, 8'd3, OP_SUB, 1'b0,
        16'h0007, 1'b0, 1'b0
    );

    // Teste 3: subtracao negativa - 3 - 10 = -7 = FFF9
    apply_and_check(
        8'd3, 8'd10, OP_SUB, 1'b0,
        16'hFFF9, 1'b0, 1'b0
    );

    // Teste 4: multiplicacao - 12 * 10 = 120
    apply_and_check(
        8'd12, 8'd10, OP_MUL, 1'b0,
        16'h0078, 1'b0, 1'b0
    );

    // Teste 5: divisao - 100 / 4 = 25
    apply_and_check(
        8'd100, 8'd4, OP_DIV, 1'b0,
        16'h0019, 1'b0, 1'b0
    );

    // Teste 6: resultado zero - 7 - 7 = 0
    apply_and_check(
        8'd7, 8'd7, OP_SUB, 1'b0,
        16'h0000, 1'b1, 1'b0
    );

    // Teste 7: divisao por zero
    apply_and_check(
        8'd100, 8'd0, OP_DIV, 1'b0,
        16'hFFFF, 1'b0, 1'b1
    );

    // Teste 8: dado invalido
    apply_and_check(
        8'd10, 8'd5, OP_ADD, 1'b1,
        16'hFFFF, 1'b0, 1'b1
    );

    if (errors == 0)
        $display("TESTE CONCLUIDO: ALU FUNCIONANDO CORRETAMENTE.");
    else
        $display("TESTE FALHOU: %0d erro(s) encontrado(s).", errors);

    $finish;
end

endmodule
