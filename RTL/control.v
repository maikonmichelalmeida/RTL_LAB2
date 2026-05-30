module control (
    input  wire       clk,
    input  wire       rst,
    input  wire [6:0] cmd_in,
    input  wire       p_error,

    output wire       datain_reg_en,
    output wire       cpu_rdy,

    output wire [1:0] in_select_a,
    output wire [1:0] in_select_b,
    output wire       aluin_reg_en,
    output wire       invalid_data,
    output wire [2:0] alu_op,
    output wire       memoryWrite,
    output wire       memoryRead,
    output wire       aluout_reg_en,
    output wire       selmux2
);

localparam ST_RESET        = 2'b00;
localparam ST_FETCH_DECODE = 2'b01;
localparam ST_EXECUTE      = 2'b10;
localparam ST_STORE        = 2'b11;

reg [1:0] current_state;
reg [1:0] next_state;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        current_state <= ST_RESET;
    end else begin
        current_state <= next_state;
    end
end

always @(*) begin
    case (current_state)
        ST_RESET: begin
            next_state = ST_FETCH_DECODE;
        end

        ST_FETCH_DECODE: begin
            next_state = ST_EXECUTE;
        end

        ST_EXECUTE: begin
            next_state = ST_STORE;
        end

        ST_STORE: begin
            next_state = ST_FETCH_DECODE;
        end

        default: begin
            next_state = ST_RESET;
        end
    endcase
end

assign datain_reg_en = 1'b1;
assign cpu_rdy       = 1'b0;

assign in_select_a   = 2'b00;
assign in_select_b   = 2'b00;
assign aluin_reg_en  = 1'b0;
assign invalid_data  = 1'b0;

assign alu_op        = cmd_in[2:0];

assign memoryWrite   = 1'b0;
assign memoryRead    = 1'b0;

// Temporario: ainda mantido em 1 para continuar permitindo
// o teste atual da ADD com registradores de saida.
assign aluout_reg_en = 1'b1;

assign selmux2       = 1'b0;

endmodule