
module ALU_Control(
	PHI1, PHI2,
	BRFW, n_ready, BRK6E, STKOP, PGX,
	X,
	T0, T1, T6, T7,
	n_DOUT, n_COUT,
	INC_SB, SR, AND,
	NDB_ADD, DB_ADD, Z_ADD, SB_ADD, ADL_ADD, ADD_SB06, ADD_SB7, ADD_ADL, ANDS, EORS, ORS, SRS, SUMS, n_ACIN, n_DAA, n_DSA);

	input PHI1;
	input PHI2;

	input BRFW;
	input n_ready;
	input BRK6E;
	input STKOP;
	input PGX;
	
	input [129:0] X;
	
	input T0;
	input T1;
	input T6;
	input T7;
	
	input n_DOUT;
	input n_COUT;

	output INC_SB;
	output SR;
	output AND;

	output NDB_ADD;
	output DB_ADD;
	output Z_ADD;
	output SB_ADD;
	output ADL_ADD;
	output ADD_SB06;
	output ADD_SB7;
	output ADD_ADL;
	output ANDS;
	output EORS;
	output ORS;
	output SRS;
	output SUMS;
	output n_ACIN;
	output n_DAA;
	output n_DSA;

	// Implementation

	wire SBC0;
	wire BRX;
	wire CSET;
	wire OR;
	wire NOADL;	
	wire sb_add; 		// internal #SB/ADD
	wire n_ndb_add; 	// internal #NDB/ADD
	wire n_adl_add; 	// internal #ADL/ADD
	wire EOR;
	wire D_OUT;
	wire nADDSB06;
	wire nADDSB7;

	assign SBC0 = X[51];
	or (BRX, X[49], X[50], ~(~X[93]|BRFW));
	assign CSET = ~((~((~(n_COUT|(~(T0|T6))))&(X[52]|X[53])))&~X[54]);
	or (OR, X[32], n_ready);
	or (AND, X[69], X[70]);
	or (SR, X[75], (X[76]&T6));
	nor (NOADL, X[84], X[85], X[86], X[87], X[88], X[89], X[26]);
	or (INC_SB, X[39], X[40], X[41], X[42], X[43], (X[44]&T6));
	nor (sb_add, X[30], X[31], X[45], X[48], INC_SB, X[47], BRK6E, n_ready);
	nand (n_ndb_add, (BRX|X[56]|SBC0), ~n_ready);
	nor (n_adl_add, (X[33]&~X[34]), X[35], X[36], X[37], X[38], X[39], n_ready);
	assign EOR = X[29];
	assign D_OUT = ~n_DOUT;
	nor (nADDSB06, STKOP, X[56], PGX, T1, T7);

	// Carry in

	wire acin_latch1_q;
	wire acin_latch2_q;
	wire acin_latch3_q;
	wire acin_latch4_q;
	wire acin_latch5_nq;

	dlatch acin_latch1 (.d(~(n_adl_add|~X[47])), .en(PHI2), .q(acin_latch1_q));
	dlatch acin_latch2 (.d(INC_SB), .en(PHI2), .q(acin_latch2_q));
	dlatch acin_latch3 (.d(BRX), .en(PHI2), .q(acin_latch3_q));
	dlatch acin_latch4 (.d(CSET), .en(PHI2), .q(acin_latch4_q));
	dlatch acin_latch5 (.d(~(acin_latch1_q|acin_latch2_q|acin_latch3_q|acin_latch4_q)), .en(PHI1), .nq(acin_latch5_nq));

	assign n_ACIN = ~acin_latch5_nq;

	// ->ADD

	wire ndbadd_latch_q;
	wire dbadd_latch_q;
	wire zadd_latch_q;
	wire sbadd_latch_q;
	wire adladd_latch_q;

	dlatch ndbadd_latch (.d(n_ndb_add), .en(PHI2), .q(ndbadd_latch_q));
	dlatch dbadd_latch (.d(~(n_ndb_add&n_adl_add)), .en(PHI2), .q(dbadd_latch_q));
	dlatch zadd_latch (.d(sb_add), .en(PHI2), .q(zadd_latch_q));
	dlatch sbadd_latch (.d(~sb_add), .en(PHI2), .q(sbadd_latch_q));
	dlatch adladd_latch (.d(n_adl_add), .en(PHI2), .q(adladd_latch_q));

	nor (NDB_ADD, ndbadd_latch_q, PHI2);
	nor (DB_ADD, dbadd_latch_q, PHI2);
	nor (Z_ADD, zadd_latch_q, PHI2);
	nor (SB_ADD, sbadd_latch_q, PHI2);
	nor (ADL_ADD, adladd_latch_q, PHI2);

	// ALU ops

	wire ands_latch1_nq;
	wire eors_latch1_nq;
	wire ors_latch1_nq;
	wire srs_latch1_nq;
	wire sums_latch1_nq;

	dlatch ands_latch1 (.d(AND), .en(PHI2), .nq(ands_latch1_nq));
	dlatch ands_latch2 (.d(ands_latch1_nq), .en(PHI1), .nq(ANDS));
	dlatch eors_latch1 (.d(EOR), .en(PHI2), .nq(eors_latch1_nq));
	dlatch eors_latch2 (.d(eors_latch1_nq), .en(PHI1), .nq(EORS));
	dlatch ors_latch1 (.d(OR), .en(PHI2), .nq(ors_latch1_nq));
	dlatch ors_latch2 (.d(ors_latch1_nq), .en(PHI1), .nq(ORS));
	dlatch srs_latch1 (.d(SR), .en(PHI2), .nq(srs_latch1_nq));
	dlatch srs_latch2 (.d(srs_latch1_nq), .en(PHI1), .nq(SRS));
	dlatch sums_latch1 (.d(~(AND|EOR|OR|SR)), .en(PHI2), .nq(sums_latch1_nq));
	dlatch sums_latch2 (.d(sums_latch1_nq), .en(PHI1), .nq(SUMS));

	// BCD

	wire DAATemp;
	wire DSATemp;
	wire daa_latch1_nq;
	wire dsa_latch1_nq;

	assign DAATemp = ~(~(~(X[52]&D_OUT)|SBC0));
	nand (DSATemp, D_OUT, SBC0);

	dlatch daa_latch1 (.d(DAATemp), .en(PHI2), .nq(daa_latch1_nq));
	dlatch daa_latch2 (.d(daa_latch1_nq), .en(PHI1), .nq(n_DAA));
	dlatch dsa_latch1 (.d(DSATemp), .en(PHI2), .nq(dsa_latch1_nq));
	dlatch dsa_latch2 (.d(dsa_latch1_nq), .en(PHI1), .nq(n_DSA));

	// ADD->

	dlatch addsb7_latch (.d(~(nADDSB06|nADDSB7)), .en(PHI2), .q(ADD_SB7)); 		// care!
	dlatch addsb06_latch (.d(nADDSB06), .en(PHI2), .nq(ADD_SB06));
	dlatch addadl_latch (.d(~(~(NOADL|PGX))), .en(PHI2), .nq(ADD_ADL));

	// https://www.youtube.com/watch?v=Uk_QC1eU0Fg

	ROR_Unit ror (.PHI1(PHI1), .PHI2(PHI2), .n_COUT(n_COUT), .n_ready(n_ready), .SR(SR), .n_ROR(~X[27]), .nADDSB7(nADDSB7) );

endmodule // ALU_Control

module ROR_Unit (PHI1, PHI2, n_COUT, n_ready, SR, n_ROR, nADDSB7);

	input PHI1;
	input PHI2;
	input n_COUT;
	input n_ready;
	input SR;
	input n_ROR;
	output nADDSB7;

	wire cout_latch_nq;
	wire nready_latch_q;
	wire mux_latch1_q;
	wire ff_latch1_nq;
	wire ff_latch2_q;
	wire sr_latch1_nq;
	wire sr_latch2_q;

	wire mux_latch_in;
	nor (mux_latch_in, nready_latch_q, ~SR);

	wire ff1_d;
	assign ff1_d = ~(mux_latch1_q ? cout_latch_nq : ff_latch2_q);

	dlatch cout_latch (.d(~n_COUT), .en(PHI2), .nq(cout_latch_nq));
	dlatch nready_latch (.d(n_ready), .en(PHI1), .q(nready_latch_q));
	dlatch mux_latch1 (.d(mux_latch_in), .en(PHI2), .q(mux_latch1_q));
	dlatch ff_latch1 (.d(ff1_d), .en(PHI1), .nq(ff_latch1_nq));
	dlatch ff_latch2 (.d(ff_latch1_nq), .en(PHI2), .q(ff_latch2_q));
	dlatch sr_latch1 (.d(SR), .en(PHI2), .nq(sr_latch1_nq));
	dlatch sr_latch2 (.d(sr_latch1_nq), .en(PHI1), .q(sr_latch2_q));

	nor (nADDSB7, ff_latch1_nq, sr_latch2_q, n_ROR);

endmodule // ROR_Unit
