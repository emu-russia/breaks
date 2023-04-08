
module Dispatch (
	PHI1, PHI2,
	BRK6E, RESP, ACR, DORES, PC_DB, RDY, B_OUT, BRFW, n_BRTAKEN, n_TWOCYCLE, n_IMPLIED, n_ADL_PCL, 
	X, 
	ACRL2, T6, T7, TRES2, STOR, Z_IR, FETCH, n_ready, WR, T1, n_T0, T0, n_T1X, n_IPC);

	input PHI1;
	input PHI2;

	input BRK6E;
	input RESP;
	input ACR;
	input DORES;
	input PC_DB;
	input RDY;
	input B_OUT;
	input BRFW;
	input n_BRTAKEN;
	input n_TWOCYCLE;
	input n_IMPLIED;
	input n_ADL_PCL;

	input [129:0] X;

	output ACRL2;
	output T6;
	output T7;
	output TRES2;
	output STOR;
	output Z_IR;
	output FETCH;
	output n_ready;
	output WR;
	output T1;
	output n_T0;
	output T0;
	output n_T1X;
	output n_IPC;

	// Implementation

	wire n_STORE;
	wire n_SHIFT;
	wire n_MemOP;
	wire STOR;
	wire REST;
	wire BR2;
	wire BR3;
	wire NotReadyPhi1;
	wire ACRL1;
	wire ENDS;
	wire n_TRESX;

	assign n_STORE = ~X[97];
	assign n_SHIFT = ~(X[106]|X[107]);
	assign n_MemOP = ~(X[111]|X[122]|X[123]|X[124]|X[125]);
	assign STOR = ~(n_MemOP|n_STORE);
	assign REST = ~(n_SHIFT&n_STORE);
	assign BR2 = X[80];
	assign BR3 = X[93];

	ReadyRW ready_rw (
		.PHI1(PHI1), 
		.PHI2(PHI2), 
		.RDY(RDY), 
		.STOR(STOR), 
		.PC_DB(PC_DB), 
		.D98(X[98]), 
		.D100(X[100]), 
		.T6(T6), 
		.T7(T7), 
		.DORES(DORES), 
		.n_ready(n_ready), 
		.NotReadyPhi1(NotReadyPhi1), 
		.WR(WR) );

	ACRLatch acrl (
		.PHI1(PHI1), 
		.PHI2(PHI2), 
		.ACR(ACR), 
		.NotReadyPhi1(NotReadyPhi1), 
		.ACLR1(ACLR1), 
		.ACRL2(ACRL2) );

	RMWCycle rmw (
		.PHI1(PHI1), 
		.PHI2(PHI2), 
		.n_ready(n_ready), 
		.n_SHIFT(n_SHIFT), 
		.n_MemOP(n_MemOP), 
		.T6(T6), 
		.T7(T7) );

	ShortCycle short (
		.PHI1(PHI1), 
		.PHI2(PHI2), 
		.n_ready(n_ready), 
		.RESP(RESP), 
		.BR3(BR3), 
		.NotReadyPhi1(NotReadyPhi1), 
		.BRFW(BRFW), 
		.ACR(ACR), 
		.ENDS(ENDS), 
		.n_TWOCYCLE(n_TWOCYCLE), 
		.n_TRESX(n_TRESX),
		.T0(T0), 
		.T1(T1), 
		.n_T0(n_T0), 
		.n_T1X(n_T1X) );

	CompletionUnit comp_unit (
		.PHI1(PHI1), 
		.PHI2(PHI2), 
		.n_ready(n_ready), 
		.ACRL1(ACRL1), 
		.REST(REST), 
		.BRK6E(BRK6E), 
		.RESP(RESP), 
		.n_SHIFT(n_SHIFT), 
		.n_MemOP(n_MemOP), 
		.X(X), 
		.T0(T0), 
		.T1(T1), 
		.n_BRTAKEN(n_BRTAKEN), 
		.BR2(BR2), 
		.BR3(BR3), 
		.TRES2(TRES2), 
		.n_TRESX(n_TRESX), 
		.ENDS(ENDS) );

	IncrementPC incpc (
		.PHI1(PHI1), 
		.PHI2(PHI2), 
		.B_OUT(B_OUT), 
		.NotReadyPhi1(NotReadyPhi1), 
		.BRFW(BRFW), 
		.ACR(ACR), 
		.n_ready(n_ready), 
		.n_BRTAKEN(n_BRTAKEN), 
		.n_ADL_PCL(n_ADL_PCL), 
		.n_IMPLIED(n_IMPLIED), 
		.BR2(BR2),
		.BR3(BR3), 
		.n_IPC(n_IPC) );

	FetchUnit fetch_unit (
		.PHI2(PHI2), 
		.B_OUT(B_OUT), 
		.T1(T1), 
		.n_ready(n_ready), 
		.Z_IR(Z_IR), 
		.FETCH(FETCH) );

endmodule // Dispatch

module ReadyRW (PHI1, PHI2, RDY, STOR, PC_DB, D98, D100, T6, T7, DORES, n_ready, NotReadyPhi1, WR);

	input PHI1;
	input PHI2;
	input RDY;
	input STOR;
	input PC_DB;
	input D98;
	input D100;
	input T6;
	input T7;
	input DORES;
	output n_ready;
	output NotReadyPhi1;
	output WR;

endmodule // ReadyRW

module ACRLatch (PHI1, PHI2, ACR, NotReadyPhi1, ACLR1, ACRL2);

	input PHI1;
	input PHI2;
	input ACR;
	input NotReadyPhi1;
	output ACLR1;
	output ACRL2;

endmodule // ACRLatch

module RMWCycle (PHI1, PHI2, n_ready, n_SHIFT, n_MemOP, T6, T7);

	input PHI1;
	input PHI2;
	input n_ready;
	input n_SHIFT;
	input n_MemOP;
	output T6;
	output T7;

endmodule // RMWCycle

module ShortCycle (PHI1, PHI2, n_ready, RESP, BR3, NotReadyPhi1, BRFW, ACR, ENDS, n_TWOCYCLE, n_TRESX, T0, T1, n_T0, n_T1X);

	input PHI1;
	input PHI2;
	input n_ready;
	input RESP;
	input BR3;
	input NotReadyPhi1;
	input BRFW;
	input ACR;
	input ENDS;
	input n_TWOCYCLE;
	input n_TRESX;
	output T0;
	output T1;
	output n_T0;
	output n_T1X;

endmodule // ShortCycle

module CompletionUnit (PHI1, PHI2, n_ready, ACRL1, REST, BRK6E, RESP, n_SHIFT, n_MemOP, X, T0, T1, n_BRTAKEN, BR2, BR3, TRES2, n_TRESX, ENDS);

	input PHI1;
	input PHI2;
	input n_ready;
	input ACRL1;
	input REST;
	input BRK6E;
	input RESP;
	input n_SHIFT;
	input n_MemOP;
	input [129:0] X;
	input T0;
	input T1;
	input n_BRTAKEN;
	input BR2;
	input BR3;
	output TRES2;
	output n_TRESX;
	output ENDS;

endmodule // CompletionUnit

module IncrementPC (PHI1, PHI2, B_OUT, NotReadyPhi1, BRFW, ACR, n_ready, n_BRTAKEN, n_ADL_PCL, n_IMPLIED, BR2, BR3, n_IPC);

	input PHI1;
	input PHI2;
	input B_OUT;
	input NotReadyPhi1;
	input BRFW;
	input ACR;
	input n_ready;
	input n_BRTAKEN;
	input n_ADL_PCL;
	input n_IMPLIED;
	input BR2;
	input BR3;
	output n_IPC;

endmodule // IncrementPC

module FetchUnit (PHI2, B_OUT, T1, n_ready, Z_IR, FETCH);

	input PHI2;
	input B_OUT;
	input T1;
	input n_ready;
	output Z_IR;
	output FETCH;

endmodule // FetchUnit
