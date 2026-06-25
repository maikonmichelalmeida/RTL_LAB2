module register_mem #(
 parameter WIDTH = 8
 ) (
 input clk, memoryWrite, memoryRead,
 input [2*WIDTH-1:0] memoryWriteData,
 input [7:0] memoryAddress,
 output logic[2*WIDTH-1:0] memoryOutData
);

// Define o array de registradores (memória)
    // 2^WIDTH endereços, cada um com 2*WIDTH bits de largura
logic [2*WIDTH-1:0] register_memories [7:0]; // Array de registradores com 256 entradas

    // Lógica de escrita na memória (registrador)
    always_ff @(posedge clk) begin
        if (memoryWrite) begin
            // Escreve dados no endereço especificado
            register_memories[memoryAddress] <= memoryWriteData;
        end
        
    end

   assign memoryOutData = memoryRead ? register_memories[memoryAddress]: '0;

endmodule