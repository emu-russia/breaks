
module Flags_Control (
	PHI2, X,
	T7, ZTST, n_ready, SR,
	P_DB, IR5_I, IR5_C, IR5_D, Z_V, ACR_C, DBZ_Z, DB_N, DB_P, DB_C, DB_V);

	input PHI2;

	input [129:0] X;

	input T7;
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

	wire dbz_latch_q;
	wire dbn_latch_q;
	wire pin_latch_q;
	wire bit_latch_q;

	wire nARITH;
	assign nARITH = ~((X[107] & T7) | X[112] | X[116] | X[117] | X[118] | X[119]);

	dlatch pdb_latch (.d(~(X[98]|X[99])), .en(PHI2), .nq(P_DB));
	dlatch iri_latch (.d(~X[108]), .en(PHI2), .nq(IR5_I));
	dlatch irc_latch (.d(~X[110]), .en(PHI2), .nq(IR5_C));
	dlatch ird_latch (.d(~X[120]), .en(PHI2), .nq(IR5_D));
	dlatch zv_latch (.d(~X[127]), .en(PHI2), .nq(Z_V));
	dlatch acrc_latch (.d(nARITH), .en(PHI2), .nq(ACR_C));
	dlatch dbz_latch (.d(~(ACR_C|ZTST|X[109])), .en(PHI2), .q(dbz_latch_q), .nq(DBZ_Z));
	dlatch dbn_latch (.d(X[109]), .en(PHI2), .q(dbn_latch_q));
	dlatch dbc_latch (.d(~(SR|DB_P)), .en(PHI2), .nq(DB_C));
	dlatch pin_latch (.d(~(X[114]|X[115])), .en(PHI2), .q(pin_latch_q));
	dlatch bit_latch (.d(~X[113]), .en(PHI2), .q(bit_latch_q));

	assign DB_N = ~((dbz_latch_q&pin_latch_q) | dbn_latch_q);
	assign DB_P = ~(pin_latch_q | n_ready);
	assign DB_V = ~(pin_latch_q & bit_latch_q);

endmodule // Flags_Control
