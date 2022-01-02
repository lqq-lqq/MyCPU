`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 13:50:53
// Design Name: 
// Module Name: top
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


module top(
	input wire clk,rst,
	output wire[31:0] writedataM,dataadr,
	output wire memwriteM
    );

	wire[31:0] pc,instr,readdataM;
	
	mips m(
	clk,
	rst,
	pc,
	instr,
	memwriteM,  
	dataadr,
	writedataM,
	readdataM
    );


	inst_ram imem (
		.clka(~clk),    // input wire clka
		.ena(1'b1),      // input wire ena
		.wea(4'b0),      // input wire [3 : 0] wea 4bits!!!!!!!!!!!!!!!!!!!!
		.addra(pc[9:2]),  // input wire [7 : 0] addra
		.dina(32'b0),    // input wire [31 : 0] dina
		.douta(instr)  // output wire [31 : 0] douta
	);	
	data_ram dmem(
		.clka(~clk),   
		.ena(1'b1),
		.wea({4{memwriteM}}), // input wire [3 : 0] wea 4bits !!!!!!!!!!111111
		.addra(dataadr[7:0]),
		.dina(writedataM),
		.douta(readdataM)   //这里读出来的只能是M，因为几个信号都是M的，不能读出W的，要去datapath里面转换！！！！！！！！！！！
		);

endmodule
