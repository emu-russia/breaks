`timescale 1ns/1ns

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

	wire [7:0] pcl_nout;
	wire [3:0] pch_nout;
	wire [7:1] pclc;
	wire [7:1] pchc;

	wire PCLC;
	nor (PCLC, n_IPC, pcl_nout[0], pcl_nout[1], pcl_nout[2], pcl_nout[3], pcl_nout[4], pcl_nout[5], pcl_nout[6], pcl_nout[7] );
	wire PCHC;
	nor (PCHC, ~PCLC, pch_nout[0], pch_nout[1], pch_nout[2], pch_nout[3] );

	// PCL

	pc_notcarry pcl0 (.pc(pc[0]), .pcs(pcs[0]), .PHI2(PHI2), .n_carry(n_IPC), .AD(ADL[0]), .DB(DB[0]), .PC_AD(PCL_ADL), .PC_DB(PCL_DB), .AD_PC(ADL_PCL), .PC_PC(PCL_PCL), .n_val(pcl_nout[0]), .cout(pclc[1]) );
	pc_carry    pcl1 (.pc(pc[1]), .pcs(pcs[1]), .PHI2(PHI2), .carry(pclc[1]), .AD(ADL[1]), .DB(DB[1]), .PC_AD(PCL_ADL), .PC_DB(PCL_DB), .AD_PC(ADL_PCL), .PC_PC(PCL_PCL), .n_val(pcl_nout[1]), .n_cout(pclc[2]) );
	pc_notcarry pcl2 (.pc(pc[2]), .pcs(pcs[2]), .PHI2(PHI2), .n_carry(pclc[2]), .AD(ADL[2]), .DB(DB[2]), .PC_AD(PCL_ADL), .PC_DB(PCL_DB), .AD_PC(ADL_PCL), .PC_PC(PCL_PCL), .n_val(pcl_nout[2]), .cout(pclc[3]) );
	pc_carry    pcl3 (.pc(pc[3]), .pcs(pcs[3]), .PHI2(PHI2), .carry(pclc[3]), .AD(ADL[3]), .DB(DB[3]), .PC_AD(PCL_ADL), .PC_DB(PCL_DB), .AD_PC(ADL_PCL), .PC_PC(PCL_PCL), .n_val(pcl_nout[3]), .n_cout(pclc[4]) );
	pc_notcarry pcl4 (.pc(pc[4]), .pcs(pcs[4]), .PHI2(PHI2), .n_carry(pclc[4]), .AD(ADL[4]), .DB(DB[4]), .PC_AD(PCL_ADL), .PC_DB(PCL_DB), .AD_PC(ADL_PCL), .PC_PC(PCL_PCL), .n_val(pcl_nout[4]), .cout(pclc[5]) );
	pc_carry    pcl5 (.pc(pc[5]), .pcs(pcs[5]), .PHI2(PHI2), .carry(pclc[5]), .AD(ADL[5]), .DB(DB[5]), .PC_AD(PCL_ADL), .PC_DB(PCL_DB), .AD_PC(ADL_PCL), .PC_PC(PCL_PCL), .n_val(pcl_nout[5]), .n_cout(pclc[6]) );
	pc_notcarry pcl6 (.pc(pc[6]), .pcs(pcs[6]), .PHI2(PHI2), .n_carry(pclc[6]), .AD(ADL[6]), .DB(DB[6]), .PC_AD(PCL_ADL), .PC_DB(PCL_DB), .AD_PC(ADL_PCL), .PC_PC(PCL_PCL), .n_val(pcl_nout[6]), .cout(pclc[7]) );
	pc_carry    pcl7 (.pc(pc[7]), .pcs(pcs[7]), .PHI2(PHI2), .carry(pclc[7]), .AD(ADL[7]), .DB(DB[7]), .PC_AD(PCL_ADL), .PC_DB(PCL_DB), .AD_PC(ADL_PCL), .PC_PC(PCL_PCL), .n_val(pcl_nout[7])  ); 	// discard output carry, PCLC used instead

	// PCH

	pc_carry    pch0 (.pc(pc[8]), .pcs(pcs[8]), .PHI2(PHI2), .carry(PCLC), .AD(ADH[0]), .DB(DB[0]), .PC_AD(PCH_ADH), .PC_DB(PCH_DB), .AD_PC(ADH_PCH), .PC_PC(PCH_PCH), .n_val(pch_nout[0]), .n_cout(pchc[1]) );
	pc_notcarry pch1 (.pc(pc[9]), .pcs(pcs[9]), .PHI2(PHI2), .n_carry(pchc[1]), .AD(ADH[1]), .DB(DB[1]), .PC_AD(PCH_ADH), .PC_DB(PCH_DB), .AD_PC(ADH_PCH), .PC_PC(PCH_PCH), .n_val(pch_nout[1]), .cout(pchc[2]) );
	pc_carry    pch2 (.pc(pc[10]), .pcs(pcs[10]), .PHI2(PHI2), .carry(pchc[2]), .AD(ADH[2]), .DB(DB[2]), .PC_AD(PCH_ADH), .PC_DB(PCH_DB), .AD_PC(ADH_PCH), .PC_PC(PCH_PCH), .n_val(pch_nout[2]), .n_cout(pchc[3]) );
	pc_notcarry pch3 (.pc(pc[11]), .pcs(pcs[11]), .PHI2(PHI2), .n_carry(pchc[3]), .AD(ADH[3]), .DB(DB[3]), .PC_AD(PCH_ADH), .PC_DB(PCH_DB), .AD_PC(ADH_PCH), .PC_PC(PCH_PCH), .n_val(pch_nout[3])  ); 	// discard output carry, PCHC used instead

	pc_carry    pch4 (.pc(pc[12]), .pcs(pcs[12]), .PHI2(PHI2), .carry(PCHC), .AD(ADH[4]), .DB(DB[4]), .PC_AD(PCH_ADH), .PC_DB(PCH_DB), .AD_PC(ADH_PCH), .PC_PC(PCH_PCH), .n_cout(pchc[5]) );
	pc_notcarry pch5 (.pc(pc[13]), .pcs(pcs[13]), .PHI2(PHI2), .n_carry(pchc[5]), .AD(ADH[5]), .DB(DB[5]), .PC_AD(PCH_ADH), .PC_DB(PCH_DB), .AD_PC(ADH_PCH), .PC_PC(PCH_PCH), .cout(pchc[6]) );
	pc_carry    pch6 (.pc(pc[14]), .pcs(pcs[14]), .PHI2(PHI2), .carry(pchc[6]), .AD(ADH[6]), .DB(DB[6]), .PC_AD(PCH_ADH), .PC_DB(PCH_DB), .AD_PC(ADH_PCH), .PC_PC(PCH_PCH), .n_cout(pchc[7]) );
	pc_notcarry pch7 (.pc(pc[15]), .pcs(pcs[15]), .PHI2(PHI2), .n_carry(pchc[7]), .AD(ADH[7]), .DB(DB[7]), .PC_AD(PCH_ADH), .PC_DB(PCH_DB), .AD_PC(ADH_PCH), .PC_PC(PCH_PCH) ); 		// discard output carry, no need

	// Debug
	wire IPC; 				// 1: Incerement PC
	not (IPC, n_IPC);
	wire [15:0] pc; 		// PC
	wire [15:0] pcs; 		// PC Shadow

endmodule // PC

// PC bit, input carry in inverted polarity and output carry in regular polarity
module pc_notcarry (PHI2, n_carry, AD, DB, PC_AD, PC_DB, AD_PC, PC_PC, n_val, cout, pc, pcs);

	input PHI2;
	input n_carry;
	inout AD;
	inout DB;
	input PC_AD;
	input PC_DB;
	input AD_PC;
	input PC_PC;
	output n_val;
	output cout;
	output pc; 		// Not on a real chip
	output pcs;		// Not on a real chip

	wire in_latch_d;
	assign in_latch_d = AD_PC ? AD : (PC_PC ? q : 1'bz);

	wire out_latch_d;
	aoi g1 (.a0(n_val), .a1(n_carry), .b(cout), .x(out_latch_d) );

	dlatch in_latch (.d(in_latch_d), .en(1'b1), .nq(n_val) ); 				// PCLS/PCHS bits
	dlatch out_latch (.d(out_latch_d), .en(PHI2), .nq(out_latch_nq) ); 		// PCL/PCH bits
	wire out_latch_nq;
	wire q;
	not (q, out_latch_nq);

	nor (cout, n_val, n_carry);

	assign DB = PC_DB ? q : 1'bz;
	assign AD = PC_AD ? q : 1'bz;
	assign pcs = ~n_val;
	assign pc = q;

endmodule // pc_notcarry

// PC bit, input carry in regular polarity and output carry in inverted polarity
module pc_carry (PHI2, carry, AD, DB, PC_AD, PC_DB, AD_PC, PC_PC, n_val, n_cout, pc, pcs);

	input PHI2;
	input carry;
	inout AD;
	inout DB;
	input PC_AD;
	input PC_DB;
	input AD_PC;
	input PC_PC;
	output n_val;
	output n_cout;
	output pc; 		// Not on a real chip
	output pcs;		// Not on a real chip	

	wire in_latch_d;
	assign in_latch_d = AD_PC ? AD : (PC_PC ? q : 1'bz);

	wire out_latch_d;
	oai g1 (.a0(val), .a1(carry), .b(n_cout), .x(out_latch_d) );

	dlatch in_latch (.d(in_latch_d), .en(1'b1), .nq(n_val) ); 			// PCLS/PCHS bits
	wire val;
	not (val, n_val);
	dlatch out_latch (.d(out_latch_d), .en(PHI2), .nq(q) ); 		// PCL/PCH bits
	wire q;

	nand (n_cout, val, carry);

	assign DB = PC_DB ? q : 1'bz;
	assign AD = PC_AD ? q : 1'bz;
	assign pcs = val;
	assign pc = q;

endmodule // pc_carry
