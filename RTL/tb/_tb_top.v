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

task check_result_add;
    begin
        #1;

        if ((dout_high !== 8'h00) ||
            (dout_low  !== 8'h0D) ||
            (zero      !== 1'b0)  ||
            (error     !== 1'b0)) begin

            $display("ERRO: tempo=%0t | dout_high=%h dout_low=%h zero=%b error=%b",
                     $time, dout_high, dout_low, zero, error);

            errors = errors + 1;
        end else begin
            $display("OK:   tempo=%0t | dout_high=%h dout_low=%h zero=%b error=%b",
                     $time, dout_high, dout_low, zero, error);
        end
    end
endtask

initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0, tb_top);
    $fsdbDumpMDA(0, tb_top);

    clk    = 1'b0;
    rst    = 1'b0;

    // cmd_in[6:5] = 00
    // cmd_in[4:3] = 01
    // cmd_in[2:0] = 000 -> ADD
    cmd_in = 7'b0001000;

    din_1  = 8'd10;
    din_2  = 8'd3;
    din_3  = 8'd7;

    errors = 0;

    #2;
    rst = 1'b1;
    #8;
    rst = 1'b0;

    @(posedge clk);
    check_result_add;

    @(posedge clk);
    check_result_add;

    if (errors == 0)
        $display("TESTE CONCLUIDO: PRIMEIRA ADD PASSANDO PELA ALU E REGISTRADORES DE SAIDA.");
    else
        $display("TESTE FALHOU: %0d erro(s) encontrado(s).", errors);

    $finish;
end

endmodule