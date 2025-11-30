module PAMUX (
	PCLK,
	n_H2_D, BLNK, F_AT, DB_PAR, 
	AT_ADR_in, NT_ADR_in, PAT_ADR_in, CPU_DB, n_PA );

	input PCLK;

	input n_H2_D;
	input BLNK;
	input F_AT;
	input DB_PAR;

	input [13:0] AT_ADR_in;
	input [13:0] NT_ADR_in;
	input [13:0] PAT_ADR_in;
	inout [7:0] CPU_DB;

	output [13:0] n_PA;

endmodule // PAMUX