module control (
    input  logic       clk,
    input  logic       rst,
    input  logic [6:0] cmd_in,
    input  logic       p_error,
    output logic       datain_reg_en,
    output logic       cpu_rdy,
    output logic [1:0] in_select_a,
    output logic [1:0] in_select_b,
    output logic       aluin_reg_en,
    output logic       invalid_data,
    output logic [2:0] alu_op,
    output logic       memoryWrite,
    output logic       memoryRead,
    output logic       aluout_reg_en,
    output logic       selmux2
);

    typedef enum logic [1:0] {
        ST_RESET,
        ST_FETCH_DECODE,
        ST_EXECUTE,
        ST_STORE
    } state_t;

    localparam logic [2:0] OP_ADD   = 3'b000;
    localparam logic [2:0] OP_SUB   = 3'b001;
    localparam logic [2:0] OP_MUL   = 3'b010;
    localparam logic [2:0] OP_DIV   = 3'b011;
    localparam logic [2:0] OP_NOP_0 = 3'b100;
    localparam logic [2:0] OP_LOAD  = 3'b101;
    localparam logic [2:0] OP_STORE = 3'b110;
    localparam logic [2:0] OP_NOP_1 = 3'b111;

    state_t current_state;
    state_t next_state;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= ST_RESET;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        case (current_state)
            ST_RESET:        next_state = ST_FETCH_DECODE;
            ST_FETCH_DECODE: next_state = ST_EXECUTE;
            ST_EXECUTE:      next_state = ST_STORE;
            ST_STORE:        next_state = ST_FETCH_DECODE;
            default:         next_state = ST_RESET;
        endcase
    end

    always_comb begin
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
                    end

                    OP_LOAD: begin
                        memoryRead    = 1'b1;
                        aluout_reg_en = 1'b1;
                        selmux2       = 1'b1;
                    end

                    OP_STORE: begin
                        memoryWrite = 1'b1;
                    end

                    OP_NOP_0,
                    OP_NOP_1: begin
                        aluout_reg_en = 1'b0;
                    end

                    default: begin
                        aluout_reg_en = 1'b0;
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
