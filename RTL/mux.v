module mux4 #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] din1,
    input  wire [WIDTH-1:0] din2,
    input  wire [WIDTH-1:0] din3,
    input  wire [WIDTH-1:0] din4,
    input  wire [1:0]       select,
    output reg  [WIDTH-1:0] dout
);

always @(*) begin
    case (select)
        2'b00: dout = din1;
        2'b01: dout = din2;
        2'b10: dout = din3;
        2'b11: dout = din4;
        default: dout = {WIDTH{1'b0}};
    endcase
end

endmodule