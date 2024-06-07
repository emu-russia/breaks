
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

	dlatch transp_latch (.d(DB_Ext), .en(1'b1), .nq(transp_latch_nq) );
	wire transp_latch_nq;
	dlatch dir_latch (.d(transp_latch_nq), .en(PHI2), .nq(dir_latch_nq) );
	wire dir_latch_nq;

	wire dir_val;
	assign dir_val = PHI1 ? dir_latch_nq : 1'bz;
	assign ADL = DL_ADL ? dir_val : 1'bz;
	assign ADH = DL_ADH ? dir_val : 1'bz;
	assign DB = DL_DB ? dir_val : 1'bz;

	dlatch int_db_latch (.d(DB), .en(1'b1), .nq(int_db_latch_nq) );
	wire int_db_latch_nq;
	dlatch dor_latch (.d(int_db_latch_nq), .en(PHI1), .nq(dor_latch_nq) );
	wire dor_latch_nq;
	bufif0 (DB_Ext, dor_latch_nq, RD);

endmodule // DataBusBit

module WRLatch(PHI1, PHI2, WR, RD);

	input PHI1;
	input PHI2;
	input WR;
	output RD;

	dlatch wr_latch (.d(WR), .en(PHI1), .nq(wr_latch_nq) );
	wire wr_latch_nq;
	wire tmp1;
	nor (tmp1, ~PHI2, wr_latch_nq);
	not (RD, tmp1);

endmodule // WRLatch
