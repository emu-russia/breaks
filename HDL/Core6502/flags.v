
module Flags(
	PHI1, PHI2,
	P_DB, DB_P, DBZ_Z, DB_N, IR5_C, DB_C, ACR_C, IR5_D, DB_V, Z_V,
	ACR, AVR, B_OUT, n_IR5, BRK6E, Dec112, SO_frompad, 
	DB,
	n_ZOUT, n_NOUT, n_COUT, n_DOUT, n_IOUT, n_VOUT);

	input PHI1;
	input PHI2;

	input P_DB;
	input DB_P;
	input DBZ_Z;
	input DB_N;
	input IR5_C;
	input DB_C;
	input ACR_C;
	input IR5_D;
	input DB_V;
	input Z_V;

	input ACR;
	input AVR;
	input B_OUT;
	input n_IR5;
	input BRK6E;
	input Dec112;
	input SO_frompad;

	inout [7:0] DB;

	output n_ZOUT;
	output n_NOUT;
	output n_COUT;
	output n_DOUT;
	output n_IOUT;
	output n_VOUT;

endmodule // Flags
