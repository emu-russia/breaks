
module PC_Control(
	PHI1, PHI2,
	n_ready, T0, T1, 
	X,
	PCL_DB, PCH_DB, PC_DB, PCL_ADL, PCH_ADH, PCL_PCL, ADL_PCL, n_ADL_PCL, DL_PCH, ADH_PCH, PCH_PCH, n_PCH_PCH);

	input PHI1;
	input PHI2;

	input n_ready;
	input T0;
	input T1;

	input [129:0] X;

	output PCL_DB;
	output PCH_DB;
	output PC_DB;
	output PCL_ADL;
	output PCH_ADH;
	output PCL_PCL;
	output ADL_PCL;
	output n_ADL_PCL;
	output DL_PCH;
	output ADH_PCH;
	output PCH_PCH;
	output n_PCH_PCH;

endmodule // PC_Control
