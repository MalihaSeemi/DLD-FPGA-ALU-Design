`timescale 1ns / 1ps

module alu_tb;
    reg clk, reset;
    reg [4:0] A, B;
    reg [1:0] op_sel;
    wire [9:0] alu_out;

    // Instantiate Top Module
    alu_top uut (
        .clk(clk), .reset(reset),
        .A(A), .B(B), .op_sel(op_sel),
        .alu_out(alu_out)
    );

    // Clock Generation (100MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0; reset = 1; A = 0; B = 0; op_sel = 0;
        #15 reset = 0; // Release reset after a cycle [cite: 231, 245]

        // --- Test Case 1: Addition (5 + 3) ---
        @(posedge clk);
        A = 5; B = 3; op_sel = 2'b00;
        repeat(2) @(posedge clk); // Wait 2 cycles for Registered I/O 
        $display("Add: %d + %d = %d", A, B, alu_out);

        // --- Test Case 2: Subtraction (10 - 4) ---
        @(posedge clk);
        A = 10; B = 4; op_sel = 2'b01;
        repeat(2) @(posedge clk);
        $display("Sub: %d - %d = %d", A, B, alu_out);

        // --- Test Case 3: Multiplication (31 * 31) ---
        @(posedge clk);
        A = 31; B = 31; op_sel = 2'b10;
        repeat(2) @(posedge clk);
        $display("Mul: %d * %d = %d", A, B, alu_out);

        #20 $stop;
    end
endmodule