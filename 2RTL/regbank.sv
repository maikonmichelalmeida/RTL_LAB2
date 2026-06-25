module regbank #(
    parameter int unsigned WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst,
    input  logic             wr_en,
    input  logic [WIDTH-1:0] din,
    output logic [WIDTH-1:0] dout
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            dout <= '0;
        end else if (wr_en) begin
            dout <= din;
        end
    end

endmodule
