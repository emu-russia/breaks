
module ScrollRegs(
	n_W0, n_W5_1, n_W5_2, n_W6_1, n_W6_2, n_DBE, RC, CPU_DB,
	FH, FV, NTH, NTV, TV, TH, W6_2_Ena);

	input n_W0;
	input n_W5_1;
	input n_W5_2;
	input n_W6_1;
	input n_W6_2;
	input n_DBE;
	input RC;
	inout [7:0] CPU_DB;

	output [2:0] FH;
	output [2:0] FV;
	output NTH;
	output NTV;
	output [4:0] TV;
	output [4:0] TH;
	output W6_2_Ena;

endmodule // ScrollRegs
