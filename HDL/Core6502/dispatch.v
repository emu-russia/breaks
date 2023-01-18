
module Dispatch (
	PHI1, PHI2,
	BRK6E, BR2, RESP, ACR, DORES, PC_DB, RDY, B_OUT, BRFW, n_BRTAKEN, n_TWOCYCLE, n_IMPLIED, n_ADL_PCL, 
	X, 
	ACRL2, T6, T7, TRES2, STOR, Z_IR, FETCH, n_ready, WR, T1, n_T0, T0, n_T1X, n_IPC);

	input PHI1;
	input PHI2;

	input BRK6E;
	input BR2;
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

endmodule // Dispatch
