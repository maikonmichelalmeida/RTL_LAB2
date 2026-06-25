//============================================================
// MUX 4x1 Parametrizável (SystemVerilog)
// Seleciona uma entre quatro entradas de dados.
//============================================================
module mux4 #(
    parameter int WIDTH = 32
)(
    input  logic [WIDTH-1:0] in0,   // entrada 0
    input  logic [WIDTH-1:0] in1,   // entrada 1
    input  logic [WIDTH-1:0] in2,   // entrada 2
    input  logic [WIDTH-1:0] in3,   // entrada 3
    input  logic [1:0]            sel,   // seletor de 2 bits
    output logic [WIDTH-1:0] out    // saída
);

    always_comb begin
        unique case (sel)
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            2'b11: out = in3;
            default: out = '0;
        endcase
    end

endmodule

//============================================================
// MUX 2x1 Parametrizável (SystemVerilog)
// Seleciona uma entre duas entradas de dados.
//============================================================
module mux2 #(
    parameter int WIDTH = 32
)(
    input  logic [WIDTH-1:0] in0,   // entrada 0
    input  logic [WIDTH-1:0] in1,   // entrada 1
    input  logic                  sel,   // seletor (0 = in0, 1 = in1)
    output logic [WIDTH-1:0] out    // saída
);

    always_comb begin
        unique case (sel)
            1'b0: out = in0;
            1'b1: out = in1;
            default: out = '0;
        endcase
    end

endmodule


//============================================================
// REGISTRADOR PARAMETRIZÁVEL COM ENABLE
//============================================================
// - Largura ajustável via parâmetro WIDTH
// - Reset síncrono ou assíncrono configurável via parâmetro
// - Usa tipos 'logic' e bloco 'always_ff' (boa prática em SV)
//============================================================
module reg_stage #(
    parameter int WIDTH = 32,
    parameter bit ASYNC_RESET = 1    // 1 = reset assíncrono, 0 = reset síncrono
)(
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  en,                 // enable de escrita
    input  logic [WIDTH-1:0] d,                  // entrada de dados
    output logic [WIDTH-1:0] q                   // saída registrada
);

    generate
        if (ASYNC_RESET) begin : gen_async
            always_ff @(posedge clk or posedge rst) begin
                if (rst)
                    q <= '0;
                else if (en)
                    q <= d;
            end
        end else begin : gen_sync
            always_ff @(posedge clk) begin
                if (rst)
                    q <= '0;
                else if (en)
                    q <= d;
            end
        end
    endgenerate

endmodule

//============================================================
// ALU PARAMETRIZADA COM ZERO, EQUAL E INVALID_DATA
//============================================================
module alu #(
    parameter int WIDTH = 32
)(
    input  logic [WIDTH-1:0] a,        // operando A
    input  logic [WIDTH-1:0] b,        // operando B
    input  logic [2:0]            opcode,   // 3-bit opcode
    input  logic                  invalid_input, // sinal externo de invalid data
    output logic [2*WIDTH-1:0] y,        // resultado
    output logic                  zero,     // y == 0
    output logic                  error // operação inválida
);

    always_comb begin
        // padrão
        y = '0;
        zero = 1'b0;
        error = 1'b0;
    if(!invalid_input) begin
        case (opcode)
            3'b000: y = a + b;          // Add
            3'b001: y = a - b;          // Sub
            3'b010: y = a * b;          // Mul
            3'b011: begin               // Div
                if (b != 0)
                    y = a / b;
                else
                    error= 1'b1; // divisão por zero
            end
            default: error = 1'b1; // código de opcode inválido
        endcase
        
        if (y == 2*WIDTH-1'b0) begin
             zero = 1'b1;
        end
    end 
    
    //else begin
    //if (opcode == 3'b110) begin
    //            y = b;   end  end
    end

endmodule

//============================================================
// CONTROL UNIT - FSM 3 ciclos (SystemVerilog)
//============================================================
module control (
    input  logic        clk,
    input  logic        rst,
    input  logic [6:0]  cmd_in,
    input  logic        p_error,
    output logic        aluin_reg_en,
    output logic        datain_reg_en,
    output logic        aluout_reg_en,

    output logic        memoryWrite,
    output logic        memoryRead,
    output logic        selmux2,
    output logic        cpu_rdy,
    
    output logic        nvalid_data,
    output logic [1:0]  in_select_a,
    output logic [1:0]  in_select_b,
    output logic [2:0]  opcode
);

    //============================================================
    // FSM States
    //============================================================
    typedef enum logic [1:0] {IDLE=2'd0, STAGE1=2'd1, STAGE2=2'd2, STAGE3=2'd3} state_t;
    state_t state, next_state;

    //============================================================
    // Decodificação cmd_in
    //============================================================
    // Vamos assumir:
    // cmd_in[2:0] -> opcode interno 3 bits
    // cmd_in[6:5] -> sel a
    // cmd_in[4:3] -> sel b
    wire [2:0] opcode3 = cmd_in[2:0];
    wire [1:0] selA    = cmd_in[6:5];
    wire [1:0] selB    = cmd_in[4:3];

    //============================================================
    // FSM State Register RST
    //============================================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    //============================================================
    // FSM Next State & Outputs
    //============================================================
    always_comb begin


        // default values
        aluin_reg_en   = 1'b1;
        datain_reg_en  = 1'b1;
        memoryWrite    = 1'b0;
        memoryRead     = 1'b0;
        selmux2        = 1'b0;
        cpu_rdy        = 1'b0;
        aluout_reg_en  = 1'b0;
        nvalid_data    = 1'b0;
        in_select_a    = selA;
        in_select_b    = selB;
        opcode         = opcode3; // 3-bit opcode (extend com 0 MSB)
        next_state     = IDLE;

        case(state)
            IDLE: begin
                //RSET
                datain_reg_en = 1'b1;
                aluin_reg_en  = 1'b0;
                aluout_reg_en = 1'b0;
                next_state = STAGE1;
            end

            STAGE1: begin
                //FETCH
                nvalid_data   = 1'b1;
                //datain_reg_en = 1'b0;
                in_select_a    = selA;
                in_select_b    = selB;
                aluin_reg_en  = 1'b1;
                aluout_reg_en = 1'b0;
                next_state = STAGE2;
            end

            STAGE2: begin
                
                case (opcode3)

                    //=====================================
                    // Instruções NOP
                    //=====================================
                    3'b100, 3'b111: begin
                        nvalid_data   = 1'b1;
                        aluout_reg_en = 1'b0;
                        aluin_reg_en  = 1'b0;
                        next_state    = STAGE3;
                    end

                    //=====================================
                    // STORE (opcode = 3'b110)
                    //=====================================
                    3'b110: begin
                        nvalid_data    = 1'b1;
                        memoryWrite    = 1'b0; // ATIVAR NO NEXT STATE
                        memoryRead     = 1'b0;
                        selmux2        = 1'b0;
                        aluin_reg_en   = 1'b0;
                        aluout_reg_en  = 1'b0;
                        //case (selB)
                        //    2'b11: aluout_reg_en = 1'b0;
                        //    default: aluout_reg_en = 1'b1;
                        //endcase
                        next_state     = STAGE3;
                        
                    end

                    //=====================================
                    // LOAD (opcode = 3'b101)
                    //=====================================
                    3'b101: begin
                        nvalid_data    = 1'b1;
                        memoryWrite    = 1'b0;
                        memoryRead     = 1'b1;
                        aluout_reg_en  = 1'b1;
                        aluin_reg_en   = 1'b0;
                        selmux2        = 1'b1;
                        next_state     = STAGE3;
                    end

                    //=====================================
                    // DEFAULT → operações normais (ADD, SUB, MUL, DIV)
                    //=====================================
                    default: begin
                        nvalid_data    = 1'b0;
                        opcode         = opcode3;
                        aluout_reg_en  = 1'b1;
                        aluin_reg_en   = 1'b0;
                        datain_reg_en = 1'b0;
                        selmux2        = 1'b0;
                        next_state     = STAGE3;
                    end

            endcase 
        end

        STAGE3: begin
                //STORE
                if (opcode3 == 3'b110) begin
                        nvalid_data = 1'b1;
                        memoryWrite    = 1'b1;
                        memoryRead     = 1'b0;
                        selmux2        = 1'b0;
                        aluout_reg_en = 1'b0;
                        //case (selB)
                        //    2'b10: aluout_reg_en = 1'b0;
                        //    default: aluout_reg_en = 1'b1;
                        //endcase
                        next_state = STAGE1;  
                end
                //NOT_ALU
                if (opcode3 == 3'b111 || opcode3 == 3'b101 || opcode3 == 3'b100) begin
                        nvalid_data = 1'b1;
                end
                cpu_rdy = '1;
                next_state  = STAGE1;
                
        end

            default: next_state = IDLE;
        endcase

        // Se houver erro externo
        if (p_error) begin
            nvalid_data = 1'b1;
            next_state  = STAGE1;
        end
end



endmodule
