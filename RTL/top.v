module top #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst,

    // Instrucao externa da CPU.
    // cmd_in[6:5] -> futura selecao do MUX A
    // cmd_in[4:3] -> futura selecao do MUX B
    // cmd_in[2:0] -> futuro opcode da instrucao
    input  wire [6:0]       cmd_in,

    // Barramentos externos de dados.
    // Ainda nao sao usados nesta primeira versao do esqueleto.
    input  wire [WIDTH-1:0] din_1,
    input  wire [WIDTH-1:0] din_2,
    input  wire [WIDTH-1:0] din_3,

    output wire             cpu_rdy
);

// Registrador interno de instrucao/dados de controle.
// Usamos um registrador de 8 bits por padronizacao com WIDTH=8,
// mas cmd_in possui apenas 7 bits.
// Portanto:
// datain_reg[6:0] recebe cmd_in[6:0]
// datain_reg[7]   fica preenchido com 0
wire [WIDTH-1:0] datain_reg;
wire             datain_reg_en;

wire [WIDTH-1:0] datain_reg_in;

assign datain_reg_in = {1'b0, cmd_in};

// Registrador de entrada da instrucao.
// Nesta etapa ele apenas captura cmd_in nos 7 bits menos significativos.
regbank #(
    .WIDTH(WIDTH)
) datain_register (
    clk,
    rst,
    datain_reg_en,
    datain_reg_in,
    datain_reg
);

// O controle recebe somente os 7 bits menos significativos,
// que correspondem exatamente ao formato de cmd_in.
control control_inst (
    clk,
    rst,
    datain_reg[6:0],
    datain_reg_en,
    cpu_rdy
);

endmodule