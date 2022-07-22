
module DataBusBit(
	PHI1, PHI2,
	ADL, ADH, DB, DB_Ext,
	DL_ADL, DL_ADH, DL_DB,
	RD);

	input PHI1;
	input PHI2;

	inout ADL;
	inout ADH;
	inout DB;
	inout DB_Ext;

	input DL_ADL;
	input DL_ADH;
	input DL_DB;
	input RD;

endmodule // DataBusBit

module WRLatch(PHI1, PHI2, WR, RD);

	input PHI1;
	input PHI2;
	input WR;
	output RD;

endmodule // WRLatch
