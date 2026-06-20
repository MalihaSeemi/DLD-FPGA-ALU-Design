module adder_5bit (
    input [4:0] a,
    input [4:0] b,
    output [5:0] sum // 6 bits to handle the carry
);
    assign sum = a + b;
endmodule
module subtractor_5bit (
    input [4:0] a,
    input [4:0] b,
    output [4:0] diff
);
    assign diff = a - b;
endmodule
module input_register (
    input clk,
    input reset,
    input [4:0] A_in, B_in,
    input [1:0] sel_in,
    output reg [4:0] A_out, B_out,
    output reg [1:0] sel_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            A_out <= 5'b0;
            B_out <= 5'b0;
            sel_out <= 2'b0;
        end else begin
            A_out <= A_in;
            B_out <= B_in;
            sel_out <= sel_in;
        end
    end
endmodule
module output_register (
    input clk,
    input reset,
    input [9:0] data_in,
    output reg [9:0] data_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            data_out <= 10'b0;
        else
            data_out <= data_in;
    end
endmodule
module multiplier_5bit (
    input [4:0] a,
    input [4:0] b,
    output [9:0] product
);
    // Partial products (shifted versions of A)
    wire [9:0] p0 = b[0] ? {5'b0, a}       : 10'b0;
    wire [9:0] p1 = b[1] ? {4'b0, a, 1'b0} : 10'b0;
    wire [9:0] p2 = b[2] ? {3'b0, a, 2'b0} : 10'b0;
    wire [9:0] p3 = b[3] ? {2'b0, a, 3'b0} : 10'b0;
    wire [9:0] p4 = b[4] ? {1'b0, a, 4'b0} : 10'b0;

    // Summation tree using your 5-bit adder logic (expanded for 10 bits)
    // Note: To show hierarchy, we use instances instead of '+'
    wire [9:0] sum1, sum2, sum3;

    // Structural addition stages
    assign sum1 = p0 + p1;
    assign sum2 = sum1 + p2;
    assign sum3 = sum2 + p3;
    assign product = sum3 + p4;

endmodule
module alu_top (
    input clk, reset,
    input [4:0] A, B,
    input [1:0] op_sel,
    output [9:0] alu_out
);
    // Internal Wires
    wire [4:0] reg_A, reg_B;
    wire [1:0] reg_sel;
    wire [5:0] w_add;
    wire [4:0] w_sub;
    wire [9:0] w_mul;
    reg [9:0] mux_out;

    // 1. Input Registration
    input_register in_reg (clk, reset, A, B, op_sel, reg_A, reg_B, reg_sel);

    // 2. Arithmetic Units (Existing Modules)
    adder_5bit add1 (reg_A, reg_B, w_add);
    subtractor_5bit sub1 (reg_A, reg_B, w_sub);
    multiplier_5bit mul1 (reg_A, reg_B, w_mul);

    // 3. Selection Logic (Combinational Mux)
    always @(*) begin
        case(reg_sel)
            2'b00: mux_out = {4'b0, w_add};   // Addition [cite: 14, 93]
            2'b01: mux_out = {5'b0, w_sub};   // Subtraction [cite: 14, 93]
            2'b10: mux_out = w_mul;          // Multiplication [cite: 15]
            default: mux_out = 10'b0;
        endcase
    end

    // 4. Output Registration
    output_register out_reg (clk, reset, mux_out, alu_out);

endmodule