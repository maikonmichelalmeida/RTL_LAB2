module memory #(
    parameter WIDTH = 8
)(
    input  wire                 clk,
    input  wire                 memoryWrite,
    input  wire                 memoryRead,
    input  wire [2*WIDTH-1:0]   memoryWriteData,
    input  wire [7:0]           memoryAddress,
    output reg  [2*WIDTH-1:0]   memoryOutData
);

reg [2*WIDTH-1:0] mem [0:7];

always @(posedge clk) begin
    if (memoryWrite) begin
        mem[memoryAddress[2:0]] <= memoryWriteData;
    end
end

always @(*) begin
    if (memoryRead) begin
        memoryOutData = mem[memoryAddress[2:0]];
    end else begin
        memoryOutData = {2*WIDTH{1'b0}};
    end
end

endmodule