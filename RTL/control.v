module control (
    input  wire       clk,
    input  wire       rst,
    input  wire [6:0] cmd_in,

    output reg        datain_reg_en,
    output reg        cpu_rdy
);

always @(*) begin
    // Versao inicial do controle:
    // ainda nao implementa FSM nem decodificacao.
    // Mantem o registrador de instrucao sempre habilitado.
    datain_reg_en = 1'b1;

    // Ainda nao ha execucao real de instrucao.
    // Portanto, a CPU nunca sinaliza "pronta" nesta versao inicial.
    cpu_rdy = 1'b0;
end

endmodule