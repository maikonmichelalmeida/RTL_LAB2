`timescale 1ns/1ps

module tb_regbank;

parameter WIDTH = 8;

reg                  clk;
reg                  rst;
reg                  wr_en;
reg  [WIDTH-1:0]     din;
wire [WIDTH-1:0]     dout;

integer errors;

regbank #(
    .WIDTH(WIDTH)
) dut (
    .clk   (clk),
    .rst   (rst),
    .wr_en (wr_en),
    .din   (din),
    .dout  (dout)
);

always #5 clk = ~clk;

task check_output;
    input [WIDTH-1:0] expected;
    begin
        if (dout !== expected) begin
            $display("ERRO: tempo=%0t | esperado=%h | obtido=%h",
                     $time, expected, dout);
            errors = errors + 1;
        end else begin
            $display("OK:   tempo=%0t | dout=%h",
                     $time, dout);
        end
    end
endtask

initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0, tb_regbank);

    clk    = 1'b0;
    rst    = 1'b0;
    wr_en  = 1'b0;
    din    = 8'h00;
    errors = 0;

    // Teste 1: reset assincrono
    #2;
    rst = 1'b1;
    #1;
    check_output(8'h00);

    rst = 1'b0;

    // Teste 2: escrita habilitada na borda positiva
    din   = 8'hAB;
    wr_en = 1'b1;
    @(posedge clk);
    #1;
    check_output(8'hAB);

    // Teste 3: sem enable, deve manter o valor anterior
    din   = 8'hCD;
    wr_en = 1'b0;
    @(posedge clk);
    #1;
    check_output(8'hAB);

    // Teste 4: nova escrita habilitada
    din   = 8'hEF;
    wr_en = 1'b1;
    @(posedge clk);
    #1;
    check_output(8'hEF);

    // Teste 5: reset deve zerar sem aguardar clock
    #1;
    rst = 1'b1;
    #1;
    check_output(8'h00);

    rst = 1'b0;
    wr_en = 1'b0;

    if (errors == 0)
        $display("TESTE CONCLUIDO: REGBANK FUNCIONANDO CORRETAMENTE.");
    else
        $display("TESTE FALHOU: %0d erro(s) encontrado(s).", errors);

    #5;
    $finish;
end

endmodule