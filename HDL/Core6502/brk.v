
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

endmodule // IntVector
