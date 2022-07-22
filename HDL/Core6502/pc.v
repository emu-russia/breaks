
module PC(
	PHI2,
	n_IPC,
	ADL_PCL, PCL_PCL, PCL_ADL, PCL_DB, ADH_PCH, PCH_PCH, PCH_ADH, PCH_DB,
	ADL, ADH, DB);

	input PHI2;

	input n_IPC;

	input ADL_PCL;
	input PCL_PCL;
	input PCL_ADL;
	input PCL_DB;
	input ADH_PCH;
	input PCH_PCH;
	input PCH_ADH;
	input PCH_DB;

	inout [7:0] ADL;
	inout [7:0] ADH;
	inout [7:0] DB;

endmodule // PC
