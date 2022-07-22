
module Flags_Control(
	PHI2,
	X,
	T6, ZTST, n_ready, SR,
	P_DB, IR5_I, IR5_C, IR5_D, Z_V, ACR_C, DBZ_Z, DB_N, DB_P, DB_C, DB_V);

	input PHI2;

	input [129:0] X;

	input T6;
	input ZTST;
	input n_ready;
	input SR;

	output P_DB;
	output IR5_I;
	output IR5_C;
	output IR5_D;
	output Z_V;
	output ACR_C;
	output DBZ_Z;
	output DB_N;
	output DB_P;
	output DB_C;
	output DB_V;

endmodule // Flags_Control
