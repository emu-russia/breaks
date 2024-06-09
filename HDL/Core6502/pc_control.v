`timescale 1ns/1ns

module PC_Control (
	PHI1, PHI2,
	n_ready, T0, T1, BR0,
	X,
	PCL_DB, PCH_DB, PC_DB, PCL_ADL, PCH_ADH, PCL_PCL, ADL_PCL, n_ADL_PCL, DL_PCH, ADH_PCH, PCH_PCH, n_PCH_PCH);

	input PHI1;
	input PHI2;

	input n_ready;
	input T0;
	input T1;
	input BR0;

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

	wire BR2;
	wire BR3;
	wire n_PCH_DB;
	wire n_PCL_DB;
	wire ABS_2;
	wire JB;
	wire n_PCL_ADL;
	wire n_ADL_PCL;
	wire n_ADH_PCH;
	wire n_T0;
	wire t1;
	wire t2;
	wire t3;
	wire nready_latch_q;
	wire pch_db_latch1_q;
	wire pcl_db_latch1_nq;
	wire pcl_pcl_latch_q;
	wire adl_pcl_latch_q;
	wire adh_pch_latch_q;
	wire pch_pch_latch_q;
	wire pcl_db_latch1_d;
	wire pch_adh_latch_d;

	assign BR2 = X[80];
	assign BR3 = X[93];
	not (n_T0, T0);
	nor (t1, JB, nready_latch_q);
	nor (t2, t1, n_T0);
	nor (n_PCH_DB, X[77], X[78]);
	nor (JB, X[94], X[95], X[96]);
	assign ABS_2 = X[83] & ~X[129];
	nor (n_PCL_ADL, T1, X[56], ABS_2, t2, BR2);
	nor (n_ADL_PCL, ~n_PCL_ADL, X[84], T0, BR3 & ~nready_latch_q);
	nor (n_ADH_PCH, X[84], ABS_2, T0, T1, BR2, BR3 );
	nor (DL_PCH, n_T0, JB);
	nor (pcl_db_latch1_d, pch_db_latch1_q, n_ready);
	nor (t3, n_PCL_ADL, DL_PCH, BR0);
	nor (pch_adh_latch_d, t3, BR3);
	nand (PC_DB, n_PCL_DB, n_PCH_DB);

	dlatch nready_latch (.d(n_ready), .en(PHI1), .q(nready_latch_q) );
	
	dlatch pcl_db_latch1 (.d(pcl_db_latch1_d), .en(PHI1), .nq(n_PCL_DB) );
	dlatch pch_db_latch1 (.d(n_PCH_DB), .en(PHI2), .q(pch_db_latch1_q) );
	dlatch pcl_db_latch2 (.d(n_PCL_DB), .en(PHI2), .nq(PCL_DB) );
	dlatch pch_db_latch2 (.d(n_PCH_DB), .en(PHI2), .nq(PCH_DB) );

	dlatch pcl_adl_latch (.d(n_PCL_ADL), .en(PHI2), .nq(PCL_ADL) );
	dlatch pch_adh_latch (.d(pch_adh_latch_d), .en(PHI2), .nq(PCH_ADH) );
	dlatch pcl_pcl_latch (.d(~n_ADL_PCL), .en(PHI2), .q(pcl_pcl_latch_q) );
	dlatch adl_pcl_latch (.d(n_ADL_PCL), .en(PHI2), .q(adl_pcl_latch_q) );
	dlatch adh_pch_latch (.d(n_ADH_PCH), .en(PHI2), .q(adh_pch_latch_q) );
	dlatch pch_pch_latch (.d(n_PCH_PCH), .en(PHI2), .q(pch_pch_latch_q) );

	nor (PCL_PCL, pcl_pcl_latch_q, PHI2);
	nor (ADL_PCL, adl_pcl_latch_q, PHI2);
	nor (ADH_PCH, adh_pch_latch_q, PHI2);
	nor (PCH_PCH, pch_pch_latch_q, PHI2);
	not (n_PCH_PCH, n_ADH_PCH);

endmodule // PC_Control
