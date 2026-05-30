module alu #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0]     in1,
    input  wire [WIDTH-1:0]     in2,
    input  wire [2:0]           op,
    input  wire                 invalid_data,

    output reg  [2*WIDTH-1:0]   out,
    output reg                  zero,
    output reg                  error
);

localparam OP_ADD = 3'b000;
localparam OP_SUB = 3'b001;
localparam OP_MUL = 3'b010;
localparam OP_DIV = 3'b011;

always @(*) begin
    out   = {2*WIDTH{1'b0}};
    zero  = 1'b0;
    error = 1'b0;

    if (invalid_data) begin
        out   = {2*WIDTH{1'b1}};
        error = 1'b1;
    end else begin
        case (op)
            OP_ADD: begin
                out = {{WIDTH{1'b0}}, in1} + {{WIDTH{1'b0}}, in2};
            end

            OP_SUB: begin
                out = {{WIDTH{1'b0}}, in1} - {{WIDTH{1'b0}}, in2};
            end

            OP_MUL: begin
                out = in1 * in2;
            end

            OP_DIV: begin
                if (in2 == {WIDTH{1'b0}}) begin
                    out   = {2*WIDTH{1'b1}};
                    error = 1'b1;
                end else begin
                    out = {{WIDTH{1'b0}}, in1} / {{WIDTH{1'b0}}, in2};
                end
            end

            default: begin
                out = {2*WIDTH{1'b0}};
            end
        endcase

        if (!error) begin
            zero = (out == {2*WIDTH{1'b0}});
        end
    end
end

endmodule