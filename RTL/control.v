module control (
    input  wire       clk,
    input  wire       rst,
    input  wire [6:0] cmd_in,
    input  wire       p_error,

    output reg        datain_reg_en,
    output reg        cpu_rdy,

    output reg  [1:0] in_select_a,
    output reg  [1:0] in_select_b,
    output reg        aluin_reg_en,
    output reg        invalid_data,
    output reg  [2:0] alu_op,
    output reg        memoryWrite,
    output reg        memoryRead,
    output reg        aluout_reg_en,
    output reg        selmux2
);

localparam ST_RESET        = 2'b00;
localparam ST_FETCH_DECODE = 2'b01;
localparam ST_EXECUTE      = 2'b10;
localparam ST_STORE        = 2'b11;

localparam OP_ADD   = 3'b000;
localparam OP_SUB   = 3'b001;
localparam OP_MUL   = 3'b010;
localparam OP_DIV   = 3'b011;
localparam OP_NOP_0 = 3'b100;
localparam OP_LOAD  = 3'b101;
localparam OP_STORE = 3'b110;
localparam OP_NOP_1 = 3'b111;

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

always @(*) begin
    datain_reg_en = 1'b0;
    cpu_rdy       = 1'b0;

    in_select_a   = cmd_in[6:5];
    in_select_b   = cmd_in[4:3];
    aluin_reg_en  = 1'b0;

    invalid_data  = 1'b0;
    alu_op        = cmd_in[2:0];

    memoryWrite   = 1'b0;
    memoryRead    = 1'b0;

    aluout_reg_en = 1'b0;
    selmux2       = 1'b0;

    if (p_error && ((cmd_in[6:5] == 2'b11) || (cmd_in[4:3] == 2'b11))) begin
        invalid_data = 1'b1;
    end

    case (current_state)
        ST_RESET: begin
            datain_reg_en = 1'b1;
        end

        ST_FETCH_DECODE: begin
            aluin_reg_en = 1'b1;
        end

        ST_EXECUTE: begin
            if (cmd_in[2:0] == OP_LOAD) begin
                memoryRead = 1'b1;
            end
        end

        ST_STORE: begin
            cpu_rdy       = 1'b1;
            datain_reg_en = 1'b1;

            case (cmd_in[2:0])
                OP_ADD,
                OP_SUB,
                OP_MUL,
                OP_DIV: begin
                    aluout_reg_en = 1'b1;
                    selmux2       = 1'b0;
                end

                OP_LOAD: begin
                    memoryRead    = 1'b1;
                    aluout_reg_en = 1'b1;
                    selmux2       = 1'b1;
                end

                OP_STORE: begin
                    memoryWrite   = 1'b1;
                    aluout_reg_en = 1'b0;
                    selmux2       = 1'b0;
                end

                OP_NOP_0,
                OP_NOP_1: begin
                    aluout_reg_en = 1'b0;
                    selmux2       = 1'b0;
                end

                default: begin
                    aluout_reg_en = 1'b0;
                    selmux2       = 1'b0;
                end
            endcase
        end

        default: begin
            datain_reg_en = 1'b0;
            cpu_rdy       = 1'b0;
        end
    endcase
end

endmodule