`timescale 1ns/1ps

module tb_mux;

parameter WIDTH = 8;

reg  [WIDTH-1:0] din1;
reg  [WIDTH-1:0] din2;
reg  [WIDTH-1:0] din3;
reg  [WIDTH-1:0] din4;
reg  [1:0]       select;

wire [WIDTH-1:0] dout;

integer errors;

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

task check_output;
    input [1:0] sel_value;
    input [WIDTH-1:0] expected_value;
    begin
        select = sel_value;
        #10;

        if (dout !== expected_value) begin
            $display("ERRO: select=%b | esperado=%h | obtido=%h",
                     select, expected_value, dout);
            errors = errors + 1;
        end else begin
            $display("OK:   select=%b | dout=%h", select, dout);
        end
    end
endtask

initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0, tb_mux);

    errors = 0;

    din1 = 8'hAA;
    din2 = 8'hBB;
    din3 = 8'hCC;
    din4 = 8'hDD;

    check_output(2'b00, 8'hAA);
    check_output(2'b01, 8'hBB);
    check_output(2'b10, 8'hCC);
    check_output(2'b11, 8'hDD);

    if (errors == 0)
        $display("TESTE CONCLUIDO: MUX FUNCIONANDO CORRETAMENTE.");
    else
        $display("TESTE FALHOU: %0d erro(s) encontrado(s).", errors);

    $finish;
end

endmodule