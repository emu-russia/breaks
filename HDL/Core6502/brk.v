`timescale 1ns/1ns

// The handling of all exceptions and BRK instruction is unified and is referred to as the “BRK sequence”. 

module BRKProcessing(
	PHI1, PHI2,
	BRK5, n_ready, RESP, n_NMIP, BR2, T0, n_IRQP, n_IOUT,
	BRK6E, BRK7, BRK5_RDY, DORES, n_DONMI, B_OUT);

	input PHI1;
	input PHI2;

	input BRK5;
	input n_ready;
	input RESP;
	input n_NMIP;
	input BR2;
	input T0;
	input n_IRQP;
	input n_IOUT;

	output BRK6E;
	output BRK7;
	output BRK5_RDY;
	output DORES;
	output n_DONMI;
	output B_OUT;

	// BRK sequence cycles 6-7

	wire BRK5_RDY;
	and (BRK5_RDY, BRK5, ~n_ready);
	dlatch brk5_latch (.d(BRK5_RDY), .en(PHI2), .q(brk5_latch_q) );
	wire brk5_latch_q;
	wire tmp2;
	nand (tmp2, n_ready, brk6_latch1_nq);
	wire brk6_latch1_d;
	and (brk6_latch1_d, ~brk5_latch_q, tmp2);
	dlatch brk6_latch1 (.d(brk6_latch1_d), .en(PHI1), .nq(brk6_latch1_nq) );
	wire brk6_latch1_nq;
	dlatch brk6_latch2 (.d(brk6_latch1_nq), .en(PHI2), .nq(brk6_latch2) );
	wire brk6_latch2_nq;
	nor (BRK6E, brk6_latch2_nq, n_ready);
	nor (BRK7, brk6_latch1_nq, BRK5_RDY);

	// Reset FF

	wire nDORES;
	nor (nDORES, res_latch1_q, res_latch2_q);
	dlatch res_latch1 (.d(RESP), .en(PHI2), .q(res_latch1_q) );
	wire res_latch1_q;
	wire res_latch2_d;
	nor (res_latch2_d, nDORES, BRK6E);
	dlatch res_latch2 (.d(res_latch2_d), .en(PHI1), .q(res_latch2_q) );
	wire res_latch2_q;
	not (DORES, nDORES);

	// NMI Edge Detect

	wire tmp1;
	nor (tmp1, ff2_latch_q, delay_latch2_q);
	wire ff2_latch_d;
	nor (ff2_latch_d, nmip_latch_q, tmp1);
	dlatch brk7_latch (.d(BRK7), .en(PHI2), .nq(brk7_latch_nq) );
	wire brk7_latch_nq;
	wire donmi_latch_d;
	nor (donmi_latch_d, brk7_latch_nq, n_NMIP, ff2_latch_d);
	dlatch donmi_latch (.d(donmi_latch_d), .en(PHI1), .q(donmi_latch_q) );
	wire donmi_latch_q;
	dlatch nmip_latch (.d(n_NMIP), .en(PHI1), .q(nmip_latch_q) );
	wire nmip_latch_q;
	dlatch ff2_latch (.d(ff2_latch_d), .en(PHI2), .q(ff2_latch_q) );
	wire ff2_latch_q;
	dlatch delay_latch1 (.d(n_DONMI), .en(PHI2), .nq(delay_latch1_nq) );
	wire delay_latch1_nq;
	dlatch delay_latch2 (.d(delay_latch1_nq), .en(PHI1), .q(delay_latch2_q) );
	wire delay_latch2_q;
	dlatch ff1_latch (.d(n_DONMI), .en(PHI2), .q(ff1_latch_q) );
	wire ff1_latch_q;
	dlatch brk6e_latch (.d(BRK6E), .en(PHI1), .q(brk6e_latch_q) );
	wire brk6e_latch_q;
	wire nmitmp1;
	nor (nmitmp1, ff1_latch_q, brk6e_latch_q);
	nor (n_DONMI, donmi_latch_q, nmitmp1);

	// Interrupt Check

	wire intr = ~( (BR2|T0) & (~((n_IRQP|~n_IOUT)&n_DONMI)) );

	wire b_latch2_d;
	nor (b_latch2_d, b_latch1_q, BRK6E);
	dlatch b_latch2 (.d(b_latch2_d), .en(PHI1), .q(b_latch2_q) );
	wire b_latch2_q;
	wire b_latch1_d;
	and (b_latch1_d, intr, ~b_latch2_q);
	dlatch b_latch1 (.d(b_latch1_d), .en(PHI2), .q(b_latch1_q) );
	wire b_latch1_q;

	nor (B_OUT, DORES, b_latch2_d);

endmodule // BRKProcessing

module IntVector(
	PHI2, BRK5_RDY, BRK7, DORES, n_DONMI,
	Z_ADL0, Z_ADL1, Z_ADL2);

	input PHI2;
	input BRK5_RDY;
	input BRK7;
	input DORES;
	input n_DONMI;

	output Z_ADL0;
	output Z_ADL1;
	output Z_ADL2;

	dlatch zadl0_latch (.d(~BRK5_RDY), .en(PHI2), .nq(Z_ADL0) );
	wire tmp1;
	nor (tmp1, BRK7, ~DORES);
	dlatch zadl1_latch (.d(~tmp1), .en(PHI2), .nq(Z_ADL1) );
	wire zadl2_latch_d;
	nor (zadl2_latch_d, BRK7, DORES, n_DONMI);
	dlatch zadl2_latch (.d(zadl2_latch_d), .en(PHI2), .nq(zadl2_latch_nq) );
	wire zadl2_latch_nq;
	not (Z_ADL2, zadl2_latch_nq);

endmodule // IntVector
