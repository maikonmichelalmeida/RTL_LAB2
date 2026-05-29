`timescale 1ns/1ps

module tb_mux;

parameter WIDTH = 8;

reg  [WIDTH-1:0] din1;
reg  [WIDTH-1:0] din2;
reg  [WIDTH-1:0] din3;
reg  [WIDTH-1:0] din4;
reg  [1:0]       select;

wire [WIDTH-1:0] dout;

integer i;
integer errors;
reg [WIDTH-1:0] expected;

mux4 #(
    .WIDTH(WIDTH)
) dut (
    .din1(din1),
    .din2(din2),
    .din3(din3),
    .din4(din4),
    .select(select),
    .dout(dout)
);

initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0, tb_mux);

    errors = 0;

    din1 = 8'hAB;
    din2 = 8'h11;
    din3 = 8'hEF;
    din4 = 8'hFF;

    for (i = 0; i < 4; i = i + 1) begin
        select = i;
        #10;

        case (select)
            2'b00: expected = din1;
            2'b01: expected = din2;
            2'b10: expected = din3;
            2'b11: expected = din4;
        endcase

        if (dout !== expected) begin
            $display("ERRO: select=%b | esperado=%h | obtido=%h",
                     select, expected, dout);
            errors = errors + 1;
        end else begin
            $display("OK:   select=%b | dout=%h",
                     select, dout);
        end
    end

    if (errors == 0)
        $display("TESTE CONCLUIDO: MUX FUNCIONANDO CORRETAMENTE.");
    else
        $display("TESTE FALHOU: %0d erro(s) encontrado(s).", errors);

    $finish;
end

endmodule