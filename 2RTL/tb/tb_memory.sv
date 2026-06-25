`timescale 1ns/1ps

module tb_memory;

parameter int unsigned WIDTH = 8;

logic                  clk;
logic                  memoryWrite;
logic                  memoryRead;
logic  [2*WIDTH-1:0]   memoryWriteData;
logic  [7:0]           memoryAddress;

logic [2*WIDTH-1:0]   memoryOutData;

integer errors;
integer i;

memory #(
    .WIDTH(WIDTH)
) dut (
    .clk             (clk),
    .memoryWrite     (memoryWrite),
    .memoryRead      (memoryRead),
    .memoryWriteData (memoryWriteData),
    .memoryAddress   (memoryAddress),
    .memoryOutData   (memoryOutData)
);

always #5 clk = ~clk;

task automatic check_output(
    input logic [2*WIDTH-1:0] expected
);
    begin
        #1;
        if (memoryOutData !== expected) begin
            $display("ERRO: tempo=%0t | addr=%0d | esperado=%h | obtido=%h",
                     $time, memoryAddress, expected, memoryOutData);
            errors = errors + 1;
        end else begin
            $display("OK:   tempo=%0t | addr=%0d | memoryOutData=%h",
                     $time, memoryAddress, memoryOutData);
        end
    end
endtask

task automatic write_word(
    input logic [7:0]         addr,
    input logic [2*WIDTH-1:0] data
);
    begin
        @(negedge clk);
        memoryAddress   = addr;
        memoryWriteData = data;
        memoryWrite     = 1'b1;
        memoryRead      = 1'b0;

        @(posedge clk);
        #1;
        memoryWrite = 1'b0;
    end
endtask

task automatic read_and_check(
    input logic [7:0]         addr,
    input logic [2*WIDTH-1:0] expected
);
    begin
        memoryAddress = addr;
        memoryRead    = 1'b1;
        check_output(expected);
    end
endtask

initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0, tb_memory);
    $fsdbDumpMDA(0, dut);

    clk             = 1'b0;
    memoryWrite     = 1'b0;
    memoryRead      = 1'b0;
    memoryWriteData = {2*WIDTH{1'b0}};
    memoryAddress   = 8'd0;
    errors          = 0;

    // Teste 1: leitura desabilitada deve produzir saida zero.
    #2;
    check_output(16'h0000);

    // Teste 2: escrever valores diferentes nas 8 posicoes.
    for (i = 0; i < 8; i = i + 1) begin
        write_word(i, 16'h1000 + i);
    end

    // Teste 3: ler todas as posicoes.
    // A troca de endereco e observada sem esperar clock:
    // isso valida a leitura assincrona.
    for (i = 0; i < 8; i = i + 1) begin
        read_and_check(i, 16'h1000 + i);
    end

    // Teste 4: confirmar escrita sincrona.
    // A posicao 3 contem inicialmente 16'h1003.
    memoryRead    = 1'b1;
    memoryAddress = 8'd3;
    check_output(16'h1003);

    @(negedge clk);
    memoryAddress   = 8'd3;
    memoryWriteData = 16'hABCD;
    memoryWrite     = 1'b1;
    memoryRead      = 1'b1;

    // Antes da proxima borda positiva, o valor antigo permanece.
    #1;
    check_output(16'h1003);

    // Depois da borda positiva, o novo valor deve aparecer.
    @(posedge clk);
    #1;
    memoryWrite = 1'b0;
    check_output(16'hABCD);

    // Teste 5: com memoryWrite = 0, uma borda de clock nao altera a memoria.
    @(negedge clk);
    memoryAddress   = 8'd3;
    memoryWriteData = 16'hFFFF;
    memoryWrite     = 1'b0;
    memoryRead      = 1'b1;

    @(posedge clk);
    #1;
    check_output(16'hABCD);

    // Teste 6: desabilitar leitura zera a saida.
    memoryRead = 1'b0;
    check_output(16'h0000);

    if (errors == 0)
        $display("TESTE CONCLUIDO: MEMORY FUNCIONANDO CORRETAMENTE.");
    else
        $display("TESTE FALHOU: %0d erro(s) encontrado(s).", errors);

    $finish;
end

endmodule
