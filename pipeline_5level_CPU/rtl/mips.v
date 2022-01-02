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
	output wire memwriteM,  
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM
    );
	
	wire memtoregW,alusrcE,regdstE,rd_31E,regwriteM,zeroM,regwriteW,memtoregE,flushE,branchD,regwriteE;
	wire memtoregM,jumpD;
	wire[2:0] alucontrolE;
	wire[31:0] instrD;

	controller c(
    .instrD(instrD),
    .zeroM(zeroM),
	.flushE(flushE),
	.clk(clk),
	.rst(rst), 
    .alusrcE(alusrcE),
	.memwriteM(memwriteM),
	.memtoregW(memtoregW),
	.regwriteM(regwriteM),
	.regdstE(regdstE),
	.rd_31E(rd_31E),
	.regwriteW(regwriteW),
	.branchD(branchD),
	.regwriteE(regwriteE),
	.memtoregM(memtoregM),
	.memtoregE(memtoregE),
    .alucontrolE(alucontrolE),
	.jumpD(jumpD)
    //pcsrcM,
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
		.rd_31E(rd_31E),
		.regwriteM(regwriteM),
		.regwriteW(regwriteW),
		.alucontrolE(alucontrolE),
		.instr(instr),
		.readdataM(readdataM),
		.branchD(branchD),
		.memtoregE(memtoregE),
		.regwriteE(regwriteE),
		.memtoregM(memtoregM),
		.flushE(flushE),
		.jumpD(jumpD),
		.instrD(instrD)
		);


endmodule
