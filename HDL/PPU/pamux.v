module PAMUX (
	PCLK,
	n_H2_D, BLNK, F_AT, DB_PAR, 
	FAT_in, PAR_in, PAD_in, CPU_DB, n_PA );

	input PCLK;

	input n_H2_D;
	input BLNK;
	input F_AT;
	input DB_PAR;

	input [13:0] FAT_in;
	input [13:0] PAR_in;
	input [13:0] PAD_in;
	inout [7:0] CPU_DB;

	output [13:0] n_PA;

endmodule // PAMUX