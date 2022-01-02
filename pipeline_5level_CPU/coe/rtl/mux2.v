`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/03 20:38:35
// Design Name: 
// Module Name: mux2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux2
#(parameter WIDTH = 31)
(
    input [WIDTH-1:0] A,  //1的话就choose前面一个
    input [WIDTH-1:0] B,
    input choose,
    output[WIDTH-1:0] C
    );
    assign C = (choose==1) ? A:B;
endmodule
