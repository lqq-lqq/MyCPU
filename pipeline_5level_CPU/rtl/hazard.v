module hazard(
    input regwriteM,regwriteW,memtoregE,
    input branchD,regwriteE,memtoregM,
    input[4:0] writeregE,
    input[4:0] rsD,rtD,rsE,rtE,writeregM,writeregW,
    input jumpD,
    output[1:0] forwardAE,forwardBE,
    output stallF,stallD,flushE,
    output forwardAD,forwardBD
);
wire lwstall,branchstallD;
assign forwardAE = ((rsE!=5'b0) & (rsE==writeregM) & regwriteM)? 10: 
                   ((rsE!=5'b0) & (rsE==writeregW) & regwriteW)? 01: 00;

assign forwardBE = ((rtE!=5'b0) & (rtE==writeregM) & regwriteM)? 10:
                   ((rtE!=5'b0) & (rtE==writeregW) & regwriteW)? 01: 00;

assign forwardAD = (rsD!=5'b0) & (rsD==writeregM) & regwriteM;
assign forwardBD = (rtD!=5'b0) & (rtD==writeregM) & regwriteM;

assign lwstall = (rsD==rtE | rtD==rtE) & memtoregE;

assign branchstallD = branchD & 
                     (regwriteE & 
                     (writeregE==rsD | writeregE==rtD) |
                     memtoregM & 
                     (writeregM==rsD | writeregM==rtD));
assign stallF = lwstall | branchstallD;
assign stallD = lwstall | branchstallD;
assign flushE = stallD;


endmodule