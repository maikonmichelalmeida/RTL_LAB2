module regbank #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             wr_en,
    input  wire [WIDTH-1:0] din,
    output reg  [WIDTH-1:0] dout
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        dout <= {WIDTH{1'b0}};
    end else if (wr_en) begin
        dout <= din;
    end
end

endmodule