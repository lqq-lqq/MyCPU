`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/06 19:09:55
// Design Name: 
// Module Name: alu
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

// 要重写！！！！！！！！！！！！！！！
module alu(
    input [31:0] A,
    input [31:0] B,
    output [31:0] result,
    output zero,
    input [2:0] op
    );
    
    // alucontrol 生成！！！！！！！aludec的生成与原来的alu对应不一样！！！！
    
    assign result = (op==3'b000) ?(A & B): //这是最简单的写法
                    (op==3'b001) ?(A | B):
                    (op==3'b010) ?(A + B): //?????????卧槽卧槽卧槽
                    (op==3'b011) ?(A ^ B): //011异或
                    (op==3'b110) ?(A - B):
                    (op==3'b111) ?(A < B):
                    32'b0;

    assign zero = ((A-B)==0)?1:0;

endmodule
