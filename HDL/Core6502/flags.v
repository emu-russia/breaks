`timescale 1ns/1ns

module Flags(
	PHI1, PHI2,
	P_DB, DB_P, DBZ_Z, DB_N, IR5_C, DB_C, ACR_C, IR5_D, IR5_I, DB_V, Z_V,
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
	input IR5_I;
	input DB_V;
	input Z_V;

	input ACR;
	input AVR;
	input B_OUT; 				// From the BRK sequencer
	input n_IR5;
	input BRK6E;
	input Dec112; 				// AVR/V
	input SO_frompad; 		// Directly from the pad

	inout [7:0] DB;

	output n_ZOUT;
	output n_NOUT;
	output n_COUT;
	output n_DOUT;
	output n_IOUT;
	output n_VOUT;

	wire DBZ;
	nor (DBZ, DB[0], DB[1], DB[2], DB[3], DB[4], DB[5], DB[6], DB[7]);

	// Z Flag

	wire z_latch1_d;
	assign z_latch1_d = ~( (~DB[1] & DB_P) | (~DBZ & DBZ_Z) | (~(DB_P|DBZ_Z) & z_latch2_q) );  	// 222-aoi
	dlatch z_latch1 (.d(z_latch1_d), .en(PHI1), .nq(n_ZOUT) );
	dlatch z_latch2 (.d(n_ZOUT), .en(PHI2), .q(z_latch2_q) );
	wire z_latch2_q;

	// N Flag

	wire n_latch1_d;
	assign n_latch1_d = ~( (~DB[7] & DB_N) | (~DB_N & n_latch2_q) ); 		// 22-aoi
	dlatch n_latch1 (.d(n_latch1_d), .en(PHI1), .nq(n_NOUT) );
	dlatch n_latch2 (.d(n_NOUT), .en(PHI2), .q(n_latch2_q) );
	wire n_latch2_q;

	// C Flag

	wire c_latch1_d;
	assign c_latch1_d = ~( (n_IR5 & IR5_C) | (~ACR & ACR_C) | (~DB[0] & DB_C) | (~(DB_C|IR5_C|ACR_C) & c_latch2_q) ); 		// 2222-aoi
	dlatch c_latch1 (.d(c_latch1_d), .en(PHI1), .nq(n_COUT) );
	dlatch c_latch2 (.d(n_COUT), .en(PHI2), .q(c_latch2_q) );
	wire c_latch2_q;

	// D Flag

	wire d_latch1_d;
	assign d_latch1_d = ~( (IR5_D & n_IR5) | (~DB[3] & DB_P) | (~(IR5_D|DB_P) & d_latch2_q) ); 		// 222-aoi
	dlatch d_latch1 (.d(d_latch1_d), .en(PHI1), .nq(n_DOUT) );
	dlatch d_latch2 (.d(n_DOUT), .en(PHI2), .q(d_latch2_q) );
	wire d_latch2_q;

	// I Flag

	wire i_latch1_nq;
	wire i_latch1_d;
	assign i_latch1_d = ~( (n_IR5 & IR5_I) | (~DB[2] & DB_P) | (~(DB_P|IR5_I) & i_latch2_q) ); 		// 222-aoi
	dlatch i_latch1 (.d(i_latch1_d), .en(PHI1), .nq(i_latch1_nq));
	assign n_IOUT = i_latch1_nq & ~BRK6E;
	dlatch i_latch2 (.d(n_IOUT), .en(PHI2), .q(i_latch2_q) );
	wire i_latch2_q;

	// V Flag

	wire AVR_V;
	assign AVR_V = Dec112;
	dlatch avr_latch (.d(AVR_V), .en(PHI2), .q(avr_latch_q) );
	wire avr_latch_q;
	wire v_latch1_d;
	assign v_latch1_d = ~( (~AVR & avr_latch_q) | (~DB[6] & DB_V) | ( ~(DB_V|avr_latch_q|One_V) & v_latch2_q) | Z_V ); 	// 2221-aoi
	dlatch v_latch1 (.d(v_latch1_d), .en(PHI1), .nq(n_VOUT) );
	dlatch v_latch2 (.d(n_VOUT), .en(PHI2), .q(v_latch2_q) );
	wire v_latch2_q;

	// 1/V
	// SO Pad falling edge detector is integrated right there

	wire One_V;
	dlatch so_latch1 (.d(~SO_frompad), .en(PHI1), .nq(so_latch1_nq) );
	wire so_latch1_nq;
	dlatch so_latch2 (.d(so_latch1_nq), .en(PHI2), .nq(so_latch2_nq) );
	wire so_latch2_nq;
	dlatch so_latch3 (.d(so_latch2_nq), .en(PHI1), .q(so_latch3_q) );
	wire so_latch3_q;
	wire vset_latch_d;
	nor (vset_latch_d, so_latch3_q, so_latch1_nq);
	dlatch vset_latch (.d(vset_latch_d), .en(PHI2), .q(One_V) );

	// Flags Out

	assign DB[0] = P_DB ? ~n_COUT : 1'bz;
	assign DB[1] = P_DB ? ~n_ZOUT : 1'bz;
	assign DB[2] = P_DB ? ~n_IOUT : 1'bz;
	assign DB[3] = P_DB ? ~n_DOUT : 1'bz;
	assign DB[4] = P_DB ? B_OUT : 1'bz; 		// From the BRK sequencer
	assign DB[5] = 1'bz;
	assign DB[6] = P_DB ? ~n_VOUT : 1'bz;
	assign DB[7] = P_DB ? ~n_NOUT : 1'bz;

endmodule // Flags
