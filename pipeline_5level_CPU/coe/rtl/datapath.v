`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/03 21:48:30
// Design Name: 
// Module Name: datapath
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

//好像没有jump的实现？？？
//好像在regfile前少了一些多选器？？？
//全程rsD,rtD都是用的instrD[25:21],instrD[20:16]
module datapath(
    input clk,rst,
    output[31:0] writedataM,
    output[31:0] aluoutM,
    output[31:0] pc,
    output zeroM,
    input alusrcE,memtoregW,regdstE,regwriteM,regwriteW,branchD,
    input [2:0] alucontrolE,
    input[31:0] instr,
    input [31:0] readdataW
    );


wire [31:0] pc_branch_plus4;
wire[31:0] pc_branchM;
output[1:0] forwardAE,forwardBE,lwstall,stallD,stallF,flushE;
output forwardAD,forwardBD;


// Fetch - Decode------------------------------------
//mux for pc_branch or pc_plus4

mux2 #(32) mux4
(
    .A(pc_branchM),  //1的话就choose前面一个
    .B(pc_plus4),
    .choose(pcsrcD), //1: branch
    .C(pc_branch_plus4)
    );
//pc change
pc pc1(
    .clk(clk),
    .rst(rst),
    .en(~stallF),
    .pc_new(pc_branch_plus4),
    .pc(pc)
    );
//pc_plus4
adder adder_1(
	.a(pc),
    .b(32'b100),
	.y(pc_plus4)
    );

//pc
//wire[31:0] pc_next;
wire [31:0] pc_plus4;

//floprs
//instr: instr in fetch stage
wire [31:0] instrD; //instr in decode stage
wire [31:0] pc_plus4D;
flopenrc  #(32) rF(clk,rst,~stallD,1'b0,instr,instrD);
flopenrc  #(32) rF(clk,rst,~stallD,1'b0,pc_plus4,pc_plus4D);

// //pc_jump
// wire [31:0] pc_jump;
// assign pc_jump = {pc_plus4[31:28],instr[25:0],2'b00};  

// mux2 #(32) mux5
// (
//     .A(pc_jump),  //1的话就choose前面一个
//     .B(pc_branch_plus4),
//     .choose(jump), //1: pc_jump
//     .C(pc_next)
//     );



//Decode - Execute------------------------------------
//regfile 是在里面
wire [31:0] srcAE;
wire [31:0] srcBE;
wire pcsrcD,equalD;
wire[31:0] x,y;
assign pcsrcD = equalD & branchD;
mux2 #(32) mm1
(
    .A(aluoutM),  //1
    .B(readdata1D),//0
    .choose(forwardAD), 
    .C(x)
);
mux2 #(32) mm2
(
    .A(aluoutM),  //1
    .B(readdata2D),//0
    .choose(forwardBD), 
    .C(y)
);
assign equalD = (x==y)?1:0;

regfile rf(
	.clk(clk),
	.we3(regwriteW), //1:can write  0:can't
	.ra1(instrD[25:21]),
    .ra2(instrD[20:16]),
    .wa3(writeregW),
	.wd3(resultW),  //????reslutD ？？？难道又用流水线一级一级地传上去？
	.rd1(readdata1D),
    .rd2(writedataE)
    );
//sign-extend
wire [31:0] signimmD;
signext sign_1(
    .a(instrD[15:0]),
    .y(signimmD)
    );


wire [4:0] rtE,rdE,rsE;
wire [31:0] signimmE,pc_plus4E,readdata1D,readdata2D,writedataE,readdata1E,readdata2E;
flopenrc  #(5) r3(clk,rst,1'b1,flushE,instrD[15:11],rdE);
flopenrc  #(5) r4(clk,rst,1'b1,flushE,instrD[20:16],rtE);
flopenrc  #(5) r10(clk,rst,1'b1,flushE,instrD[25:21],rsE);
flopenrc  #(32) r5(clk,rst,1'b1,flushE,signimmD,signimmE);
flopenrc  #(32) r6(clk,rst,1'b1,flushE,pc_plus4D,pc_plus4E);
flopenrc  #(32) r7(clk,rst,1'b1,flushE,readdata1D,readdata1E);
flopenrc  #(32) r8(clk,rst,1'b1,flushE,readdata2D,readdata2E);



//Execute - Memory-----------------------------------
//pc_branch
wire [31:0] pc_branchE;
wire[31:0] target_offset;
wire [4:0] writeregE;
sl2 sl2_1(
    .a(signimmE),
    .y(target_offset)
    );
adder adder_2(
	.a(target_offset),
    .b(pc_plus4E),
	.y(pc_branchE)
);
//mux for the reg rt and rd  
mux2 #(5) mux1
(
    .A(rdE),  //1的话就choose前面一个
    .B(rtE),
    .choose(regdstE), //1:rd   ！！！！！！！！！！！！
    .C(writeregE)
    );
//alu_assign
//mux for srcB rd2-signimm 
mux2 #(32) mux2
(
    .A(signimmE),  //1的话就choose前面一个
    .B(writedataE),
    .choose(alusrcE), //1:signimm
    .C(srcBE)
    );

mux3 #(32) m31
(   .d0(readdata1E),//00:readdata1
    .d1(resultW),//01
    .d2(aluoutM),//10
    .s(forwardAE),
    .y(srcAE)
);

mux3 #(32) m32
(   .d0(readdata2E),//00:readdata2
    .d1(resultW),//01
    .d2(aluoutM),//10
    .s(forwardBE),
    .y(srcBE)
);
alu alu1(
    .A(srcAE),
    .B(srcBE),
    .result(aluoutE),
    .op(alucontrolE),
    .zero(zeroE) 
    );
wire [31:0] aluoutE;
wire [4:0] writeregM;
wire zeroE;
flopenrc  #(32) r9(clk,rst,1'b1,1'b0,writedataE,writedataM);
flopenrc  #(32) r10(clk,rst,1'b1,1'b0,aluoutE,aluoutM);
flopenrc  #(32) r11(clk,rst,1'b1,1'b0,pc_branchE,pc_branchM);
flopenrc  #(5) r14(clk,rst,1'b1,1'b0,writeregE,writeregM);
flopenrc  #(1) r12(clk,rst,1'b1,1'b0,zeroE,zeroM);

//Memory - Writeback----------------------------------
wire[31:0] aluoutW;
wire[4:0] writeregW;
flopenrc  #(32) r13(clk,rst,1'b1,1'b0,aluoutM,aluoutW);
flopenrc  #(5) r15(clk,rst,1'b1,1'b0,writeregM,writeregW);

//Writeback ------------------------------------------
wire [31:0] resultW;
//mux for alu or the readata from the data memory
mux2 #(32) mux3
(
    .A(readdataW),  //1的话就choose前面一个
    .B(aluoutW),
    .choose(memtoregW), //1: from memory
    .C(resultW)
    );

//控制冒险

hazard h( 
    .regwriteM(regwriteM),
    .regwirteW(regwriteW),
    .memtoregE(memtoregE),
    .branchD(branchD),
    .regwirteE(regwriteE),
    .memtoregM(memtoregM),
    .rsD(instrD[25:21]),
    .rtD(instrD[20:16]),
    .rsE(rsE),
    .rtE(rtE),
    .writeregM(writeregM),
    .writeregW(writeregW),
    .forwardAE(forwardAE),
    .forwardBE(forwardBE),
    .stallF(stallF),
    .stallD(stallD),
    .flushE(flushE),
    .forwardAD(forwardAD),
    .forwardBD(forwardBD),
    .writeregE(writeregE)
);
endmodule
