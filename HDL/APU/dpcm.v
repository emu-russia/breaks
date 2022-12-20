
module DPCMChan(
	PHI1, n_ACLK, ACLK, 
	RES, DB, RnW, LOCK,
	W4010, W4011, W4012, W4013, W4015, n_R4015, 
	n_DMCAB, RUNDMC, DMCRDY, DMCINT,
	DMC_Addr, DMC_Out);

	input PHI1;
	input n_ACLK;
	input ACLK;

	input RES;
	inout [7:0] DB;	
	input RnW;
	input LOCK;

	input W4010;
	input W4011;
	input W4012;
	input W4013;
	input W4015;
	input n_R4015;

	output n_DMCAB;
	output RUNDMC;
	output DMCRDY;
	output DMCINT;

	output [15:0] DMC_Addr;
	output [6:0] DMC_Out;

	// TBD

	assign n_DMCAB = 1'b1;
	assign RUNDMC = 1'b0;
	assign DMCRDY = 1'b1;
	assign DMCINT = 1'b0;

endmodule // DPCMChan
