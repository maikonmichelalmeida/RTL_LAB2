module alu #(
    parameter int unsigned WIDTH = 8
) (
    input  logic [WIDTH-1:0]   in1,
    input  logic [WIDTH-1:0]   in2,
    input  logic [2:0]         op,
    input  logic               invalid_data,
    output logic [2*WIDTH-1:0] out,
    output logic               zero,
    output logic               error
);

    localparam logic [2:0] OP_ADD = 3'b000;
    localparam logic [2:0] OP_SUB = 3'b001;
    localparam logic [2:0] OP_MUL = 3'b010;
    localparam logic [2:0] OP_DIV = 3'b011;

    always_comb begin
        out   = '0;
        zero  = 1'b0;
        error = 1'b0;

        if (invalid_data) begin
            out   = '1;
            error = 1'b1;
        end else begin
            case (op)
                OP_ADD: out = {{WIDTH{1'b0}}, in1} + {{WIDTH{1'b0}}, in2};
                OP_SUB: out = {{WIDTH{1'b0}}, in1} - {{WIDTH{1'b0}}, in2};
                OP_MUL: out = in1 * in2;
                OP_DIV: begin
                    if (in2 == '0) begin
                        out   = '1;
                        error = 1'b1;
                    end else begin
                        out = {{WIDTH{1'b0}}, in1} / {{WIDTH{1'b0}}, in2};
                    end
                end
                default: out = '0;
            endcase

            if (!error) begin
                zero = (out == '0);
            end
        end
    end

endmodule
