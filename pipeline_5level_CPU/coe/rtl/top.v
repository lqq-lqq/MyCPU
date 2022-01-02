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
	output wire memwrite
    );

	wire[31:0] pc,instr,readdataW;
	
	mips m(
	clk,
	rst,
	pc,
	instr,
	memwriteW,  
	dataadr,
	writedataM,
	readdataW
    );


	inst_ram imem (
		.clka(clk),    // input wire clka
		.ena(1'b1),      // input wire ena
		.wea(4'b0),      // input wire [3 : 0] wea 4bits!!!!!!!!!!!!!!!!!!!!
		.addra(pc[9:2]),  // input wire [7 : 0] addra
		.dina(32'b0),    // input wire [31 : 0] dina
		.douta(instr)  // output wire [31 : 0] douta
	);	
	data_ram dmem(
		.clka(~clk),   
		.ena(1'b1),
		.wea({4{memwriteW}}), // input wire [3 : 0] wea 4bits !!!!!!!!!!111111
		.addra(dataadr[7:0]),
		.dina(writedataM),
		.douta(readdataW)
		);

endmodule
