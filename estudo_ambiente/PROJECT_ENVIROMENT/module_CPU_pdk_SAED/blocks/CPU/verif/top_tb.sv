`timescale 10ns/1ps
//`include "../RTL/top_cpu.sv"

module top_tb;

    parameter WIDTH=8;
 // DUT signals
    logic clk;
    logic rst;
    logic [6:0] cmdin;
    logic [WIDTH-1:0] din_1, din_2, din_3;
    logic [WIDTH-1:0] dout_low, dout_high;
    logic cpu_rdy;
    logic zero, error;

 initial begin
    clk = 1'b1;
    forever #1 clk = ~clk;
 end

 initial begin
    rst = 1;
    #2 rst = 0;
 end


    // DUT instance
top_cpu #(.WIDTH(8)) uut (
        .clk(clk),
        .rst(rst),
        .cmdin(cmdin),
        .din_1(din_1),
        .din_2(din_2),
        .din_3(din_3),
        .dout_low(dout_low),
        .dout_high(dout_high),
        .cpu_rdy(cpu_rdy),
        .p_error({zero,error})
    );

initial begin
    
    // Initialization
        rst = 1;
        din_1 = 8'd0;
        din_2 = 8'd0;
        din_3 = 8'd0;
        cmdin = 7'd0;
        #20;
        rst = 0;
        $display("[%0t] START Variables: din_1=%0d , din_2=%0d, dout_high=%0d ,dout_low=%0d, zero=%b, error=%b",
                 $time, din_1 , din_2, dout_high, dout_low, zero, error);

        din_1 = 8'd5;
        din_2 = 8'd5;
        din_3 = 8'd3;

        $display("[%0t] START Variables: din_1=%0d , din_2=%0d, dout_high=%0d ,dout_low=%0d, zero=%b, error=%b",
                 $time, din_1 , din_2, dout_high, dout_low, zero, error);
        //=============================
        // ADD instruction
        //=============================
        cmdin = 7'b0000000;       // adjust according to your map
        @(posedge cpu_rdy);
        $display("[%0t] ADD finished: din_1=%0d , din_2=%0d, dout_high=%0d ,dout_low=%0d, zero=%b, error=%b",
                 $time, din_1 , din_2, dout_high, dout_low, zero, error);
        //=============================
        // SUB instruction
        //=============================
        cmdin = 7'b0001001;       // adjust according to your map
        @(posedge cpu_rdy);
        $display("[%0t] SUB finished: din_1=%0d , din_2=%0d, dout_high=%0d ,dout_low=%0d, zero=%b, error=%b",
                 $time, din_1 , din_2, dout_high, dout_low, zero, error);
          //=============================
        // MUL instruction
        //=============================
        cmdin = 7'b0000010;       // adjust according to your map
        @(posedge cpu_rdy);
        $display("[%0t] MUL finished: din_1=%0d , din_2=%0d, dout_high=%0d ,dout_low=%0d, zero=%b, error=%b",
                 $time, din_1 , din_2, dout_high, dout_low, zero, error);
        //=============================
        // DIV instruction
        //=============================
        cmdin = 7'b0000011;       // adjust according to your map
        @(posedge cpu_rdy);
        $display("[%0t] DIV finished: din_1=%0d , din_2=%0d, dout_high=%0d ,dout_low=%0d, zero=%b, error=%b",
                 $time, din_1 , din_2, dout_high, dout_low, zero, error);
        //=============================
        // NOP instruction
        //=============================
        cmdin = 7'b0000111;       // adjust according to your map
        @(posedge cpu_rdy);
        $display("[%0t] NOP finished: din_1=%0d , din_2=%0d, dout_high=%0d ,dout_low=%0d, zero=%b, error=%b",
                 $time, din_1 , din_2, dout_high, dout_low, zero, error);
         //=============================
        // NOP instruction
        //=============================
        cmdin = 7'b0000111;       // adjust according to your map
        @(posedge cpu_rdy);
        $display("[%0t] NOP finished: din_1=%0d , din_2=%0d, dout_high=%0d ,dout_low=%0d, zero=%b, error=%b",
                 $time, din_1 , din_2, dout_high, dout_low, zero, error);
         //=============================
        // STORE instruction
        //=============================
        cmdin = 7'b0011110;       // adjust according to your map
        @(posedge cpu_rdy);
        $display("[%0t] STORE finished: din_1=%0d , din_2=%0d, dout_high=%0d ,dout_low=%0d, zero=%b, error=%b",
                 $time, din_1 , din_2, dout_high, dout_low, zero, error);
        //=============================
        // LOAD instruction
        //=============================
        cmdin = 7'b0000101;       // adjust according to your map
        @(posedge cpu_rdy);
        $display("[%0t] LOAD finished: din_1=%0d , din_2=%0d, dout_high=%0d ,dout_low=%0d, zero=%b, error=%b",
                 $time, din_1 , din_2, dout_high, dout_low, zero, error);
        //=============================
        // STORE instruction
        //=============================
        cmdin = 7'b0001110;       // adjust according to your map
        @(posedge cpu_rdy);
        $display("[%0t] STORE finished: din_1=%0d , din_2=%0d, dout_high=%0d ,dout_low=%0d, zero=%b, error=%b",
                 $time, din_1 , din_2, dout_high, dout_low, zero, error);
         //=============================
        // LOAD instruction
        //=============================
        cmdin = 7'b0000101;       // adjust according to your map
        @(posedge cpu_rdy);
        $display("[%0t] LOAD finished: din_1=%0d , din_2=%0d, dout_high=%0d ,dout_low=%0d, zero=%b, error=%b",
                 $time, din_1 , din_2, dout_high, dout_low, zero, error);
          //=============================
        // DIV instruction
        //=============================
        cmdin = 7'b0001011;       // adjust according to your map
        @(posedge cpu_rdy);
        $display("[%0t] DIV finished: din_1=%0d , din_2=%0d, dout_high=%0d ,dout_low=%0d, zero=%b, error=%b",
                 $time, din_1 , din_2, dout_high, dout_low, zero, error);
        //==================================================
        // START OF LOOP 1000x (STORE + LOAD)
        //==================================================
         
         for (integer i = 0; i < 10; i = i + 1) begin
            
            $display("[%0t] Starting iteration %0d of STORE/LOAD loop", $time, i);
         din_1 = $urandom_range(7, 0);
         din_3 = $urandom_range(7, 0);
        //=============================
        // STORE_I instruction
        //=============================
        cmdin = 7'b0010110;       // adjust according to your map
        @(posedge cpu_rdy);
        $display("[%0t] STORE_I finished: din_1=%0d , din_3=%0d, dout_high=%0d ,dout_low=%0d, zero=%b, error=%b",
                 $time, din_1 , din_3, dout_high, dout_low, zero, error);
         //=============================
        // NOP instruction
        //=============================
        cmdin = 7'b0000111;       // adjust according to your map
        @(posedge cpu_rdy);
        $display("[%0t] NOP finished: din_1=%0d , din_2=%0d, dout_high=%0d ,dout_low=%0d, zero=%b, error=%b",
                 $time, din_1 , din_2, dout_high, dout_low, zero, error);
        //=============================
        // ADD instruction
        //=============================
        cmdin = 7'b0000000;       // adjust according to your map
        @(posedge cpu_rdy);
        $display("[%0t] ADD finished: din_1=%0d , din_2=%0d, dout_high=%0d ,dout_low=%0d, zero=%b, error=%b",
                 $time, din_1 , din_2, dout_high, dout_low, zero, error);
        //=============================
        // LOAD instruction
        //=============================
        cmdin = 7'b0000101;       // adjust according to your map
        @(posedge cpu_rdy);
        $display("[%0t] LOAD finished: din_1=%0d , din_3=%0d, dout_high=%0d ,dout_low=%0d, zero=%b, error=%b",
                 $time, din_1 , din_3, dout_high, dout_low, zero, error);
      
      
       end // End of for loop
       
        #20;
        $display("==== END OF SIMULATION ====");
        $finish;
    
end


endmodule
