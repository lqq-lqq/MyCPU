`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
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


module mips(
	input wire clk,rst,
	output wire[31:0] pc,
	input wire[31:0] instr,
	output wire memwriteW,  
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataW
    );
	
	wire memtoregW,alusrcE,regdstE,regwriteM,pcsrcM,zeroM,regwriteW;
	wire[2:0] alucontrolE;

	controller c(
		.instr(instr),
		.zeroM(zeroM),
		.alusrcE(alusrcE),
		.memwriteW(memwriteW),
		.memtoregW(memtoregW),
		.regwriteM(regwriteM),
		.regdstE(regdstE),
		.pcsrcM(pcsrcM),
		.regwriteW(regwriteW),
		.branchD(branchD),
		.alucontrolE(alucontrolE)
    );
	
	datapath dp(
		.clk(clk),
		.rst(rst),
		.writedataM(writedataM),
		.aluoutM(aluoutM),
		.pc(pc),
		.zeroM(zeroM),
		.alusrcE(alusrcE),
		.memtoregW(memtoregW),
		.regdstE(regdstE),
		.pcsrcM(pcsrcM),
		.regwriteM(regwriteM),
		.regwriteW(regwirteW),
		.alucontrolE(alucontrolE),
		.instr(instr),
		.readdataW(readdataW),
		.branchD(branchD),
		);

endmodule
