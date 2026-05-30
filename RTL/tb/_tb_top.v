`timescale 1ns/1ps

module tb_top;

parameter WIDTH = 8;

reg              clk;
reg              rst;
reg  [6:0]       cmd_in;

reg  [WIDTH-1:0] din_1;
reg  [WIDTH-1:0] din_2;
reg  [WIDTH-1:0] din_3;

wire             cpu_rdy;

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
    cpu_rdy
);

always #5 clk = ~clk;

task check_datain_reg;
    input [WIDTH-1:0] expected;
    begin
        #1;
        if (dut.datain_reg !== expected) begin
            $display("ERRO: tempo=%0t | esperado datain_reg=%b | obtido=%b",
                     $time, expected, dut.datain_reg);
            errors = errors + 1;
        end else begin
            $display("OK:   tempo=%0t | datain_reg=%b",
                     $time, dut.datain_reg);
        end
    end
endtask

task check_control_cmd;
    input [6:0] expected;
    begin
        #1;
        if (dut.control_inst.cmd_in !== expected) begin
            $display("ERRO: tempo=%0t | esperado control.cmd_in=%b | obtido=%b",
                     $time, expected, dut.control_inst.cmd_in);
            errors = errors + 1;
        end else begin
            $display("OK:   tempo=%0t | control.cmd_in=%b",
                     $time, dut.control_inst.cmd_in);
        end
    end
endtask

task check_cpu_rdy;
    input expected;
    begin
        #1;
        if (cpu_rdy !== expected) begin
            $display("ERRO: tempo=%0t | esperado cpu_rdy=%b | obtido=%b",
                     $time, expected, cpu_rdy);
            errors = errors + 1;
        end else begin
            $display("OK:   tempo=%0t | cpu_rdy=%b",
                     $time, cpu_rdy);
        end
    end
endtask

initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0, tb_top);

    clk    = 1'b0;
    rst    = 1'b0;
    cmd_in = 7'b0000000;

    // Constantes externas para testes futuros.
    // Nesta primeira versao elas entram no top, mas ainda nao sao usadas.
    din_1  = 8'd10;
    din_2  = 8'd3;
    din_3  = 8'd7;

    errors = 0;

    // Reset inicial.
    #2;
    rst = 1'b1;
    #2;

    check_datain_reg(8'b00000000);
    check_control_cmd(7'b0000000);
    check_cpu_rdy(1'b0);

    rst = 1'b0;

    // Instrucao futura: ADD din_1 + din_2
    // cmd_in[6:5] = 00
    // cmd_in[4:3] = 01
    // cmd_in[2:0] = 000
    cmd_in = 7'b0001000;

    @(posedge clk);
    check_datain_reg(8'b00001000);
    check_control_cmd(7'b0001000);
    check_cpu_rdy(1'b0);

    // Outra instrucao ficticia apenas para testar captura.
    cmd_in = 7'b0110010;

    @(posedge clk);
    check_datain_reg(8'b00110010);
    check_control_cmd(7'b0110010);
    check_cpu_rdy(1'b0);

    // Outra instrucao ficticia.
    cmd_in = 7'b1011011;

    @(posedge clk);
    check_datain_reg(8'b01011011);
    check_control_cmd(7'b1011011);
    check_cpu_rdy(1'b0);

    if (errors == 0)
        $display("TESTE CONCLUIDO: ESQUELETO TOP + CONTROL FUNCIONANDO.");
    else
        $display("TESTE FALHOU: %0d erro(s) encontrado(s).", errors);

    $finish;
end

endmodule