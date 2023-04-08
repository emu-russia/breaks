
module Dispatch (
	PHI1, PHI2,
	BRK6E, RESP, ACR, DORES, PC_DB, RDY, B_OUT, BRFW, n_BRTAKEN, n_TWOCYCLE, n_IMPLIED, n_ADL_PCL, 
	X, 
	ACRL2, T6, T7, TRES2, STOR, Z_IR, FETCH, n_ready, WR, T1, n_T0, T0, n_T1X, n_IPC);

	input PHI1;
	input PHI2;

	input BRK6E;
	input RESP;
	input ACR;
	input DORES;
	input PC_DB;
	input RDY;
	input B_OUT;
	input BRFW;
	input n_BRTAKEN;
	input n_TWOCYCLE;
	input n_IMPLIED;
	input n_ADL_PCL;

	input [129:0] X;

	output ACRL2;
	output T6;
	output T7;
	output TRES2;
	output STOR;
	output Z_IR;
	output FETCH;
	output n_ready;
	output WR;
	output T1;
	output n_T0;
	output T0;
	output n_T1X;
	output n_IPC;

	// Implementation

	wire n_STORE;
	wire n_SHIFT;
	wire n_MemOP;
	wire STOR;
	wire REST;
	wire BR2;
	wire BR3;
	wire NotReadyPhi1;
	wire ACRL1;
	wire ENDS;
	wire n_TRESX;
	wire BRA;

	assign n_STORE = ~X[97];
	nor (n_SHIFT, X[106], X[107]);
	nor (n_MemOP, X[111], X[122], X[123], X[124], X[125]);
	nor (STOR, n_MemOP, n_STORE);
	nand (REST, n_SHIFT, n_STORE);
	assign BR2 = X[80];
	assign BR3 = X[93];

	ReadyRW ready_rw (
		.PHI1(PHI1), 
		.PHI2(PHI2), 
		.RDY(RDY), 
		.STOR(STOR), 
		.PC_DB(PC_DB), 
		.D98(X[98]), 
		.D100(X[100]), 
		.T6(T6), 
		.T7(T7), 
		.DORES(DORES), 
		.n_ready(n_ready), 
		.NotReadyPhi1(NotReadyPhi1), 
		.WR(WR) );

	ACRLatch acrl (
		.PHI1(PHI1), 
		.PHI2(PHI2), 
		.ACR(ACR), 
		.NotReadyPhi1(NotReadyPhi1), 
		.ACRL1(ACRL1), 
		.ACRL2(ACRL2) );

	RMWCycle rmw (
		.PHI1(PHI1), 
		.PHI2(PHI2), 
		.n_ready(n_ready), 
		.n_SHIFT(n_SHIFT), 
		.n_MemOP(n_MemOP), 
		.T6(T6), 
		.T7(T7) );

	TwoCycle twocyc (
		.PHI1(PHI1), 
		.PHI2(PHI2), 
		.n_ready(n_ready), 
		.RESP(RESP), 
		.ENDS(ENDS), 
		.n_TWOCYCLE(n_TWOCYCLE), 
		.n_TRESX(n_TRESX),
		.BRA(BRA),
		.T0(T0), 
		.T1(T1), 
		.n_T0(n_T0), 
		.n_T1X(n_T1X) );

	CompletionUnit comp_unit (
		.PHI1(PHI1), 
		.PHI2(PHI2), 
		.n_ready(n_ready), 
		.ACRL1(ACRL1), 
		.REST(REST), 
		.BRK6E(BRK6E), 
		.RESP(RESP), 
		.n_SHIFT(n_SHIFT), 
		.n_MemOP(n_MemOP), 
		.X(X), 
		.T0(T0), 
		.T1(T1), 
		.T7(T7), 
		.n_BRTAKEN(n_BRTAKEN), 
		.BR2(BR2), 
		.BR3(BR3), 
		.TRES2(TRES2), 
		.n_TRESX(n_TRESX), 
		.ENDS(ENDS) );

	IncrementPC incpc (
		.PHI1(PHI1), 
		.PHI2(PHI2), 
		.B_OUT(B_OUT), 
		.NotReadyPhi1(NotReadyPhi1), 
		.BRFW(BRFW), 
		.ACR(ACR), 
		.n_ready(n_ready), 
		.n_BRTAKEN(n_BRTAKEN), 
		.n_ADL_PCL(n_ADL_PCL), 
		.n_IMPLIED(n_IMPLIED), 
		.BR2(BR2),
		.BR3(BR3),
		.BRA(BRA), 
		.n_IPC(n_IPC) );

	FetchUnit fetch_unit (
		.PHI2(PHI2), 
		.B_OUT(B_OUT), 
		.T1(T1), 
		.n_ready(n_ready), 
		.Z_IR(Z_IR), 
		.FETCH(FETCH) );

endmodule // Dispatch

module ReadyRW (PHI1, PHI2, RDY, STOR, PC_DB, D98, D100, T6, T7, DORES, n_ready, NotReadyPhi1, WR);

	input PHI1;
	input PHI2;
	input RDY;
	input STOR;
	input PC_DB;
	input D98;
	input D100;
	input T6;
	input T7;
	input DORES;
	output n_ready;
	output NotReadyPhi1;
	output WR;

	wire wr_latch_d;
	wire wr_latch_q;
	wire ready_latch1_d;
	wire ready_latch1_nq;
	wire ready_latch2_q;
	wire rdydelay_latch1_nq;

	nor (wr_latch_d, STOR, PC_DB, D98, D100, T6, T7);
	nor (ready_latch1_d, RDY, ready_latch2_q);
	nor (WR, n_ready, wr_latch_q, DORES);

	dlatch wr_latch (.d(wr_latch_d), .en(PHI2), .q(wr_latch_q));
	dlatch ready_latch1 (.d(ready_latch1_d), .en(PHI2), .nq(ready_latch1_nq));
	dlatch ready_latch2 (.d(WR), .en(PHI1), .q(ready_latch2_q));
	dlatch rdydelay_latch1 (.d(n_ready), .en(PHI1), .nq(rdydelay_latch1_nq));
	dlatch rdydelay_latch2 (.d(rdydelay_latch1_nq), .en(PHI2), .nq(NotReadyPhi1));

	assign n_ready = ~ready_latch1_nq;

endmodule // ReadyRW

module ACRLatch (PHI1, PHI2, ACR, NotReadyPhi1, ACRL1, ACRL2);

	input PHI1;
	input PHI2;
	input ACR;
	input NotReadyPhi1;
	output ACRL1;
	output ACRL2;

	wire acr_latch1_nq;
	wire ReadyPhi1;
	wire t1;
	wire t2;

	assign ReadyPhi1 = ~NotReadyPhi1;
	and (t1, ~ACR, ReadyPhi1);
	nor (t2, ReadyPhi1, ACRL2);
	nor (ACRL1, t1, t2);

	dlatch acr_latch1 (.d(ACRL1), .en(PHI1), .nq(acr_latch1_nq));
	dlatch acr_latch2 (.d(acr_latch1_nq), .en(PHI2), .nq(ACRL2));

endmodule // ACRLatch

module TwoCycle (PHI1, PHI2, n_ready, RESP, ENDS, n_TWOCYCLE, n_TRESX, BRA, T0, T1, n_T0, n_T1X);

	input PHI1;
	input PHI2;
	input n_ready;
	input RESP;
	input ENDS;
	input n_TWOCYCLE;
	input n_TRESX;
	input BRA;
	output T0;
	output T1;
	output n_T0;
	output n_T1X;

	wire nready_latch_q;
	wire step_latch1_d;
	wire step_latch1_q;
	wire step_latch2_d;
	wire step_latch2_q;
	wire t2;
	wire t1_latch_d;
	wire TRES1;

	nor (step_latch1_d, RESP, nready_latch_q, step_latch2_q);
	nor (step_latch2_d, step_latch1_q, BRA);
	nor (t2, step_latch2_d, n_ready);
	nor (t1_latch_d, t2, ENDS);
	assign TRES1 = ~t1_latch_d;

	dlatch nready_latch (.d(~n_ready), .en(PHI1), .q(nready_latch_q));
	dlatch step_latch1 (.d(step_latch1_d), .en(PHI2), .q(step_latch1_q));
	dlatch step_latch2 (.d(step_latch2_d), .en(PHI1), .q(step_latch2_q));
	dlatch t1_latch (.d(t1_latch_d), .en(PHI1), .nq(T1));
	
	wire comp_latch1_q;
	wire comp_latch2_q;
	wire comp_latch3_q;
	wire t3;
	wire t4;
	wire t0_latch_q;
	wire t1x_latch_q;
	wire t1x_latch_d;

	nor (t3, comp_latch1_q, comp_latch2_q & comp_latch3_q);
	nor (t4, t0_latch_q, t1x_latch_q);
	nor (n_T0, t3, t4);
	assign T0 = ~n_T0;
	nor (t1x_latch_d, t0_latch_q, n_ready);

	dlatch comp_latch1 (.d(TRES1), .en(PHI1), .q(comp_latch1_q));
	dlatch comp_latch2 (.d(n_TWOCYCLE), .en(PHI1), .q(comp_latch2_q));
	dlatch comp_latch3 (.d(n_TRESX), .en(PHI1), .q(comp_latch3_q));
	dlatch t0_latch (.d(n_T0), .en(PHI2), .q(t0_latch_q));
	dlatch t1x_latch (.d(t1x_latch_d), .en(PHI1), .q(t1x_latch_q), .nq(n_T1X));

endmodule // TwoCycle

module RMWCycle (PHI1, PHI2, n_ready, n_SHIFT, n_MemOP, T6, T7);

	input PHI1;
	input PHI2;
	input n_ready;
	input n_SHIFT;
	input n_MemOP;
	output T6;
	output T7;

	wire t67_latch_d;
	wire t67_latch_q;
	wire t6_latch1_d;
	wire t6_latch2_q;
	wire t7_latch1_d;
	wire t7_latch1_nq;
	wire t7_latch2_nq;

	nor (t67_latch_d, n_SHIFT, n_MemOP, n_ready);
	nor (t6_latch1_d, t67_latch_q, t6_latch2_q & n_ready);
	nand (t7_latch1_d, T6, ~n_ready);

	dlatch t67_latch (.d(t67_latch_d), .en(PHI2), .q(t67_latch_q));
	dlatch t6_latch1 (.d(t6_latch1_d), .en(PHI1), .nq(T6));
	dlatch t6_latch2 (.d(T6), .en(PHI2), .q(t6_latch2_q));
	dlatch t7_latch1 (.d(t7_latch1_d), .en(PHI2), .nq(t7_latch1_nq));
	dlatch t7_latch2 (.d(t7_latch1_nq), .en(PHI1), .nq(t7_latch2_nq));

	assign T7 = ~t7_latch2_nq;

endmodule // RMWCycle

module CompletionUnit (PHI1, PHI2, n_ready, ACRL1, REST, BRK6E, RESP, n_SHIFT, n_MemOP, X, T0, T1, T7, n_BRTAKEN, BR2, BR3, TRES2, n_TRESX, ENDS);

	input PHI1;
	input PHI2;
	input n_ready;
	input ACRL1;
	input REST;
	input BRK6E;
	input RESP;
	input n_SHIFT;
	input n_MemOP;
	input [129:0] X;
	input T0;
	input T1;
	input T7;
	input n_BRTAKEN;
	input BR2;
	input BR3;
	output TRES2;
	output n_TRESX;
	output ENDS;

	wire tresx_latch1_q;
	wire tresx_latch1_d;
	wire tresx_latch2_nq;
	wire tresx_latch2_d;
	wire ends_latch1_q;
	wire ends_latch1_d;
	wire ends_latch2_q;
	wire t1;
	wire t2;
	wire t3;
	wire t4;
	wire ENDX;
	wire t5;

	nor (tresx_latch1_d, X[91], X[92]);
	nor (t1, ACRL1, tresx_latch1_q, n_ready, REST);
	nor (n_TRESX, t1, BRK6E, tresx_latch2_nq);

	nor (t2, X[96], ~n_SHIFT, n_MemOP);
	nor (t3, X[100], X[101], X[102], X[103], X[104], X[105]);
	nor (ENDX, t2, T7, ~t3, BR3);
	nor (t4, n_ready, ENDX);
	nor (tresx_latch2_d, RESP, ENDS, t4);

	nor (t5, T0, n_BRTAKEN & BR2);
	assign ends_latch1_d = n_ready ? ~T1 : t5;

	dlatch tresx_latch1 (.d(tresx_latch1_d), .en(PHI2), .q(tresx_latch1_q));
	dlatch tresx_latch2 (.d(tresx_latch2_d), .en(PHI2), .nq(tresx_latch2_nq));
	dlatch tres2_latch (.d(n_TRESX), .en(PHI1), .nq(TRES2));
	dlatch ends_latch1 (.d(ends_latch1_d), .en(PHI2), .q(ends_latch1_q));
	dlatch ends_latch2 (.d(RESP), .en(PHI2), .q(ends_latch2_q));

	nor (ENDS, ends_latch1_q, ends_latch2_q);

endmodule // CompletionUnit

module IncrementPC (PHI1, PHI2, B_OUT, NotReadyPhi1, BRFW, ACR, n_ready, n_BRTAKEN, n_ADL_PCL, n_IMPLIED, BR2, BR3, BRA, n_IPC);

	input PHI1;
	input PHI2;
	input B_OUT;
	input NotReadyPhi1;
	input BRFW;
	input ACR;
	input n_ready;
	input n_BRTAKEN;
	input n_ADL_PCL;
	input n_IMPLIED;
	input BR2;
	input BR3;
	output BRA;
	output n_IPC;

	wire br_latch2_d;
	wire br_latch2_nq;
	wire br_latch1_q;
	wire br_latch1_d;
	wire ipc_latch1_q;
	wire ipc_latch2_q;
	wire ipc_latch3_q;
	wire ipc_latch3_d;
	wire t1;
	wire t2;

	nor (br_latch2_d, ~BR3, NotReadyPhi1);
	xor (t1, BRFW, ~ACR);
	and (BRA, t1, ~br_latch2_nq);
	nor (t2, n_ADL_PCL, BR2 | BR3);
	nor (br_latch1_d, t2, n_BRTAKEN & BR2);
	nor (ipc_latch3_d, n_ready, br_latch1_q, ~n_IMPLIED);

	dlatch br_latch2 (.d(br_latch2_d), .en(PHI2), .nq(br_latch2_nq));
	dlatch br_latch1 (.d(br_latch1_d), .en(PHI2), .q(br_latch1_q));
	dlatch ipc_latch1 (.d(B_OUT), .en(PHI1), .q(ipc_latch1_q));
	dlatch ipc_latch2 (.d(BRA), .en(PHI1), .q(ipc_latch2_q));
	dlatch ipc_latch3 (.d(ipc_latch3_d), .en(PHI1), .q(ipc_latch3_q));

	nand (n_IPC, ipc_latch1_q, ipc_latch2_q | ipc_latch3_q);

endmodule // IncrementPC

module FetchUnit (PHI2, B_OUT, T1, n_ready, Z_IR, FETCH);

	input PHI2;
	input B_OUT;
	input T1;
	input n_ready;
	output Z_IR;
	output FETCH;

	wire fetch_latch_nq;

	dlatch fetch_latch (.d(T1), .en(PHI2), .nq(fetch_latch_nq));

	nor (FETCH, fetch_latch_nq, n_ready);
	nand (Z_IR, FETCH, B_OUT);

endmodule // FetchUnit
