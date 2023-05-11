// The H/V logic is a finite state machine (FSM) that controls all other PPU parts.

module PPU_FSM (
	n_PCLK, PCLK,
	H_out, V_out, HPLA_out, VPLA_out, RES, VBL_EN, n_R2, n_DBE, n_OBCLIP, n_BGCLIP, BLACK,
	H0_DD, H0_D, H1_DD, nH1_D, H2_DD, nH2_D, H3_DD, H4_DD, H5_DD,
	S_EV, CLIP_O, CLIP_B, Z_HPOS, n_EVAL, E_EV, I_OAM2, PAR_O, n_VIS, n_FNT, F_TB, F_TA, n_FO, F_AT, SC_CNT, BURST, SYNC,
	n_PICTURE, RESCL, VB, BLNK,
	Int, DB7, V_IN, HC, VC);

	input n_PCLK;
	input PCLK;

	input [8:0] H_out; 			// HCounter bits 0-5, for outputting to the outside with a delay
	input [8:0] V_out; 			// VCounter bits
	input [23:0] HPLA_out;		// Outputs from H decoder
	input [9:0] VPLA_out;		// Outputs from V decoder
	input RES; 					// Global reset signal. Used in EVEN/ODD logic.
	input VBL_EN; 				// Control Regs ($2000[7]); Used in the VBlank interrupt handling circuit.
	input n_R2; 				// 0: Register $2002 read operation. Used in the VBlank interrupt handling circuit.
	input n_DBE;				// 0: Enable the CPU interface. Used in the VBlank interrupt handling circuit.
	input n_OBCLIP;				// Control Regs ($2001[2]); To generate the CLIP_O control signal
	input n_BGCLIP;				// Control Regs ($2001[1]); To generate the CLIP_B control signal
	input BLACK;				// Active when PPU rendering is disabled (see $2001[3] and $2001[4])

	output H0_DD;
	output H0_D; 				// H0 signal delayed by one DLatch
	output H1_DD;
	output nH1_D; 				// H1 signal delayed by one DLatch (in inverse logic)
	output H2_DD;
	output nH2_D; 				// H2 signal delayed by one DLatch (in inverse logic)
	output H3_DD;
	output H4_DD;
	output H5_DD; 				// H0-H5 signals delayed by two DLatch

	output S_EV; 				// "Start Sprite Evaluation"
	output CLIP_O; 				// "Clip Objects". 1: Do not show the left 8 screen pixels for sprites. Used to get the CLPO signal that goes into the OAM FIFO.
	output CLIP_B; 				// "Clip Background". 1: Do not show the left 8 pixels of the screen for the background. Used to get the /CLPB signal that goes into the Data Reader.
	output Z_HPOS; 				// "Clear HPos". Clear the H counters in the sprite FIFO and start the FIFO
	output n_EVAL; 				// 0: "Sprite Evaluation in Progress"
	output E_EV; 				// "End Sprite Evaluation"
	output I_OAM2; 				// "Init OAM2". Initialize an extra OAM
	output PAR_O; 				// "PAR for Object". Selecting a tile for an object (sprite)
	output n_VIS; 				// 0: "Not Visible". The invisible part of the signal (used by sprite logic)
	output n_FNT; 				// 0: "Fetch Name Table"
	output F_TB; 				// "Fetch Tile B"
	output F_TA; 				// "Fetch Tile A"
	output n_FO; 				// 0: "Fetch Output Enable"
	output F_AT; 				// "Fetch Attribute Table"
	output SC_CNT; 				// "Scroll Counters Control". Update the scrolling registers.
	output BURST; 				// Color Burst
	output SYNC; 				// Horizontal sync pulse

	output n_PICTURE; 			// 0: Visible part of the scan-lines
	output RESCL; 				// "Reset FF Clear" / "VBlank Clear". VBlank period end event.
	output VB; 					// Active when the invisible part of the video signal is output (used only in H Decoder)
	output BLNK; 				// Active when PPU rendering is disabled (by BLACK signal) or during VBlank

	output Int; 				// "Interrupt". PPU Interrupt
	inout DB7;
	output V_IN; 				// "VCounter In". Increment the VCounter
	output HC; 					// "HCounter Clear"
	output VC; 					// "VCounter Clear"

	// Wires

	wire BPORCH; 				// "Back Porch"
	wire nVSET; 				// 0: "VBlank Set". VBlank period start event.
	wire EvenOddOut; 			// Intermediate signal for the HCounter control circuit / 2C07: EvenOddOut signal goes into sprite logic instead of controlling the H/V counters
	wire n_HB; 					// 0: "HBlank"
	wire VSYNC; 				// Vertical sync pulse

	// Instances

	DelayedH delayed_h (
		.PCLK(PCLK),
		.n_PCLK(n_PCLK),
		.H_out(H_out),
		.H0_DD(H0_DD),
		.H0_D(H0_D),
		.H1_DD(H1_DD),
		.nH1_D(nH1_D),
		.H2_DD(H2_DD),
		.nH2_D(nH2_D),
		.H3_DD(H3_DD),
		.H4_DD(H4_DD),
		.H5_DD(H5_DD) );

`ifdef RP2C02

	EvenOdd even_odd (
		.V8(V_out[8]),
		.RES(RES),
		.nHPLA_5(~HPLA_out[5]),
		.RESCL(RESCL),
		.EvenOddOut(EvenOddOut) );

`elsif RP2C07

	EvenOdd_2C07 even_odd_pal (
		.n_PCLK(n_PCLK), 
		.PCLK(PCLK), 
		.BLNK(BLNK), 
		.H0_D(H0_D), 
		.VPLA_8(VPLA_out[8]), 
		.VPLA_9(VPLA_out[9]), 
		.EvenOddOut(EvenOddOut) );

`else
`endif

	VBlankInt vbl (
		.PCLK(PCLK),
		.n_PCLK(n_PCLK),
		.nVSET(nVSET),
		.VCLR(RESCL),
		.VBL_EN(VBL_EN),
		.n_R2(n_R2),
		.n_DBE(n_DBE),
		.INT(Int),
		.DB7Out(DB7) );

`ifdef RP2C02

	HVCounterControl hv_ctrl (
		.n_PCLK(n_PCLK),
		.HPLA_23(HPLA_out[23]),
		.EvenOddOut(EvenOddOut),
		.VPLA_2(VPLA_out[2]),
		.V_IN(V_IN),
		.HC(HC),
		.VC(VC) );

`elsif RP2C07

	HVCounterControl_2C07 hv_ctrl_pal (
		.n_PCLK(n_PCLK), 
		.HPLA_23(HPLA_out[23]), 
		.VPLA_8(VPLA_out[8]), 
		.V_IN(V_IN), 
		.HC(HC), 
		.VC(VC) );

`else
`endif

	HPosLogic hpos (
		.PCLK(PCLK),
		.n_PCLK(n_PCLK),
		.HPLA_out(HPLA_out),
		.n_OBCLIP(n_OBCLIP),
		.n_BGCLIP(n_BGCLIP),
		.VSYNC(VSYNC),
		.BLACK(BLACK), 
		.S_EV(S_EV),
		.CLIP_O(CLIP_O),
		.CLIP_B(CLIP_B),
		.Z_HPOS(Z_HPOS),
		.n_EVAL(n_EVAL),
		.E_EV(E_EV),
		.I_OAM2(I_OAM2),
		.PAR_O(PAR_O),
		.n_VIS(n_VIS),
		.n_FNT(n_FNT),
		.F_TB(F_TB),
		.F_TA(F_TA),
		.n_FO(n_FO),
		.F_AT(F_AT),
		.BPORCH(BPORCH),
		.SC_CNT(SC_CNT),
		.n_HB(n_HB),
		.BURST(BURST),
		.SYNC(SYNC) );

	VPosLogic vpos (
		.PCLK(PCLK),
		.n_PCLK(n_PCLK),
		.n_HB(n_HB),
		.BPORCH(BPORCH),
		.BLACK(BLACK),
		.VPLA_out(VPLA_out), 
		.n_PICTURE(n_PICTURE),
		.RESCL(RESCL),
		.VSYNC(VSYNC),
		.nVSET(nVSET),
		.VB(VB),
		.BLNK(BLNK) );

endmodule // PPU_FSM

// Delayed counter H value output circuits
module DelayedH (PCLK, n_PCLK, H_out, H0_DD, H0_D, H1_DD, nH1_D, H2_DD, nH2_D, H3_DD, H4_DD, H5_DD);

	input PCLK;
	input n_PCLK;
	input [8:0] H_out;

	output H0_DD;
	output H0_D;
	output H1_DD; 
	output nH1_D;
	output H2_DD;
	output nH2_D;
	output H3_DD;
	output H4_DD;
	output H5_DD;

	// Wires

	wire h0_latch1_nq;
	wire h3_latch1_nq;
	wire h4_latch1_nq;
	wire h5_latch1_nq;

	// Instances

	dlatch h0_latch1 (.d(H_out[0]), .en(n_PCLK), .nq(h0_latch1_nq));
	dlatch h0_latch2 (.d(h0_latch1_nq), .en(PCLK), .nq(H0_DD));
	dlatch h1_latch1 (.d(H_out[1]), .en(n_PCLK), .nq(nH1_D));
	dlatch h1_latch2 (.d(nH1_D), .en(PCLK), .nq(H1_DD));
	dlatch h2_latch1 (.d(H_out[2]), .en(n_PCLK), .nq(nH2_D));
	dlatch h2_latch2 (.d(nH2_D), .en(PCLK), .nq(H2_DD));
	dlatch h3_latch1 (.d(H_out[3]), .en(n_PCLK), .nq(h3_latch1_nq));
	dlatch h3_latch2 (.d(h3_latch1_nq), .en(PCLK), .nq(H3_DD));
	dlatch h4_latch1 (.d(H_out[4]), .en(n_PCLK), .nq(h4_latch1_nq));
	dlatch h4_latch2 (.d(h4_latch1_nq), .en(PCLK), .nq(H4_DD));
	dlatch h5_latch1 (.d(H_out[5]), .en(n_PCLK), .nq(h5_latch1_nq));
	dlatch h5_latch2 (.d(h5_latch1_nq), .en(PCLK), .nq(H5_DD));

endmodule // DelayedH

// EVEN/ODD circuitry
module EvenOdd (V8, RES, nHPLA_5, RESCL, EvenOddOut);

	input V8;
	input RES;
	input nHPLA_5;
	input RESCL;
	output EvenOddOut;

	wire q1;
	wire q2;
	wire nq2;

	sdff FF_1 (.d(nq2), .phi_keep(V8), .q(q1));
	sdffr FF_2 (.d(q1), .res(), .phi_keep(~V8), .q(q2), .nq(nq2));

	nor (EvenOddOut, q2, nHPLA_5, ~RESCL);

endmodule // EvenOdd

// In place of the Even/Odd circuit in 2C07 there is a circuit for the workaround associated with the OAM corrupt. But traditionally we still call this circuit "Even/Odd".
module EvenOdd_2C07 (n_PCLK, PCLK, BLNK, H0_D, VPLA_8, VPLA_9, EvenOddOut);

	input n_PCLK;
	input PCLK;
	input BLNK;
	input H0_D;
	input VPLA_8;
	input VPLA_9;
	output EvenOddOut; 		// Don't mind the name, it's just historically that way. In fact, it's more like `Sprite_Workaround`.

	wire latch1_q;
	wire latch2_q;
	wire latch3_in;
	wire latch3_nq;
	wire tmp;

	dlatch latch1 (.d(VPLA_9), .en(n_PCLK), .q(latch1_q));
	dlatch latch2 (.d(VPLA_8), .en(n_PCLK), .q(latch2_q));
	dlatch latch3 (.d(latch3_in), .en(PCLK), .nq(latch3_nq));
	rsff FF_1 (.r(latch2_q), .s(latch1_q), .nq());

	nand (tmp, BLNK, latch3_nq);
	nor (EvenOddOut, ~H0_D, tmp, n_PCLK);

endmodule // EvenOdd_2C07

// PPU interrupt handling (VBlank)
module VBlankInt (PCLK, n_PCLK, nVSET, VCLR, VBL_EN, n_R2, n_DBE, INT, DB7Out);

	input PCLK;
	input n_PCLK;
	input nVSET;
	input VCLR;
	input VBL_EN;
	input n_R2;
	input n_DBE;
	output INT;
	inout DB7Out;

	wire R2_EN;
	wire vset_latch1_nq;
	wire vset_latch2_q;
	wire db_latch_nq;
	wire int_ff_q;

	dlatch vset_latch1 (.d(nVSET), .en(PCLK), .nq(vset_latch1_nq));
	dlatch vset_latch2 (.d(vset_latch1_nq), .en(n_PCLK), .q(vset_latch2));
	dlatch db_latch (.d(~int_ff_q), .en(~R2_EN), .nq(db_latch_nq));
	rsff_2_3 int_ff (.res1(VCLR), .res2(R2_EN), .s(~(n_PCLK | nVSET | vset_latch2_q)), .q(int_ff_q));

	nor (R2_EN, n_R2, n_DBE);
	nor (INT, ~VBL_EN, ~int_ff_q);
	assign DB7Out = R2_EN ? db_latch_nq : 1'bz;

endmodule // VBlankInt

// H/V counter control circuitry
module HVCounterControl (n_PCLK, HPLA_23, EvenOddOut, VPLA_2, V_IN, HC, VC);

	input n_PCLK;
	input HPLA_23;
	input EvenOddOut;
	input VPLA_2;
	output V_IN;
	output HC;
	output VC;

	wire ctrl_latch2_nq;

	dlatch ctrl_latch1 (.d(~(HPLA_23 | EvenOddOut)), .en(n_PCLK), .nq(HC));
	dlatch ctrl_latch2 (.d(VPLA_2), .en(n_PCLK), .nq(ctrl_latch2_nq));

	assign V_IN = HPLA_23;
	nor (VC, ~HC, ctrl_latch2_nq);

endmodule // HVCounterControl

// 2C07 Version (minor difference: no Even/Odd, VPLA8 instead VPLA2)
module HVCounterControl_2C07 (n_PCLK, HPLA_23, VPLA_8, V_IN, HC, VC);

	input n_PCLK;
	input HPLA_23;
	input VPLA_8;
	output V_IN;
	output HC;
	output VC;

	wire ctrl_latch2_nq;

	dlatch ctrl_latch1 (.d(~HPLA_23), .en(n_PCLK), .nq(HC));
	dlatch ctrl_latch2 (.d(VPLA_8), .en(n_PCLK), .nq(ctrl_latch2_nq));

	assign V_IN = HPLA_23;
	nor (VC, ~HC, ctrl_latch2_nq);

endmodule // HVCounterControl_2C07

// Horizontal logic associated with an H decoder
module HPosLogic (PCLK, n_PCLK, HPLA_out, n_OBCLIP, n_BGCLIP, VSYNC, BLACK, 
	S_EV, CLIP_O, CLIP_B, Z_HPOS, n_EVAL, E_EV, I_OAM2, PAR_O, n_VIS, n_FNT, F_TB, F_TA, n_FO, F_AT, BPORCH, SC_CNT, n_HB, BURST, SYNC);

	input PCLK;
	input n_PCLK;
	input [23:0] HPLA_out;
	input n_OBCLIP;
	input n_BGCLIP;
	input VSYNC;
	input BLACK;

	output S_EV;
	output CLIP_O;
	output CLIP_B;
	output Z_HPOS;
	output n_EVAL;
	output E_EV;
	output I_OAM2;
	output PAR_O;
	output n_VIS;
	output n_FNT;
	output F_TB;
	output F_TA;
	output n_FO;
	output F_AT;
	output BPORCH;
	output SC_CNT;
	output n_HB;
	output BURST;
	output SYNC;

	// Wires

	wire fp_latch1_q;
	wire fp_latch2_q;
	wire sev_latch1_nq;
	wire sev_latch2_nq;
	wire clpo_latch1_q;
	wire clpo_latch2_q;
	wire clpb_latch1_nq;
	wire clpb_latch2_q;
	wire hpos_latch1_q;
	wire hpos_latch1_nq;
	wire hpos_latch2_nq;
	wire eval_latch1_q;
	wire eval_latch2_nq;
	wire eev_latch1_q;
	wire eev_latch1_nq;
	wire eev_latch2_nq;
	wire ioam_latch1_nq;
	wire ioam_latch2_nq;
	wire paro_latch1_nq;
	wire paro_latch2_nq;
	wire nvis_latch1_nq;
	wire nvis_latch2_nq;
	wire fnt_latch1_nq;
	wire fnt_latch2_nq;
	wire ftb_latch1_nq;
	wire ftb_latch2_q;
	wire fta_latch1_nq;
	wire fta_latch2_q;
	wire fo_latch1_q;
	wire fo_latch2_q;
	wire fo_latch3_q;
	wire fo_latch3_nq;
	wire fat_latch1_nq;
	wire bp_latch1_q;
	wire bp_latch2_q;
	wire hb_latch1_q;
	wire hb_latch2_q;
	wire cb_latch1_q;
	wire cb_latch2_q;
	wire sync_latch1_q;
	wire sync_latch2_q;
	wire fporch_ff_nq;
	wire bporch_ff_q;
	wire hblank_ff_q;
	wire hblank_ff_nq;
	wire burst_ff_nq;

	wire clp;
	wire fo3;

	// Instances

	dlatch fp_latch1 (.d(HPLA_out[0]), .en(n_PCLK), .q(fp_latch1_q));
	dlatch fp_latch2 (.d(HPLA_out[1]), .en(n_PCLK), .q(fp_latch2_q));
	dlatch sev_latch1 (.d(HPLA_out[2]), .en(n_PCLK), .nq(sev_latch1_nq));
	dlatch sev_latch2 (.d(sev_latch1_nq), .en(PCLK), .nq(sev_latch2_nq));
	dlatch clpo_latch1 (.d(HPLA_out[3]), .en(n_PCLK), .q(clpo_latch1_q));
	dlatch clpo_latch2 (.d(clp), .en(PCLK), .q(clpo_latch2_q));
	dlatch clpb_latch1 (.d(HPLA_out[4]), .en(n_PCLK), .nq(clpb_latch1_nq));
	dlatch clpb_latch2 (.d(clp), .en(PCLK), .q(clpb_latch2_q));
	dlatch hpos_latch1 (.d(HPLA_out[5]), .en(n_PCLK), .q(hpos_latch1_q), .nq(hpos_latch1_nq));
	dlatch hpos_latch2 (.d(hpos_latch1_nq), .en(PCLK), .nq(hpos_latch2_nq));
	dlatch eval_latch1 (.d(HPLA_out[6]), .en(n_PCLK), .q(eval_latch1_q));
	dlatch eval_latch2 (.d(~(hpos_latch1_q | eval_latch1_q | eev_latch1_q)), .en(PCLK), .nq(eval_latch2_nq));
	dlatch eev_latch1 (.d(HPLA_out[7]), .en(n_PCLK), .q(eev_latch1_q), .nq(eev_latch1_nq));
	dlatch eev_latch2 (.d(eev_latch1_nq), .en(PCLK), .nq(eev_latch2_nq));
	dlatch ioam_latch1 (.d(HPLA_out[8]), .en(n_PCLK), .nq(ioam_latch1_nq));
	dlatch ioam_latch2 (.d(ioam_latch1_nq), .en(PCLK), .nq(ioam_latch2_nq));
	dlatch paro_latch1 (.d(HPLA_out[9]), .en(n_PCLK), .nq(paro_latch1_nq));
	dlatch paro_latch2 (.d(paro_latch1_nq), .en(PCLK), .nq(paro_latch2_nq));
	dlatch nvis_latch1 (.d(HPLA_out[10]), .en(n_PCLK), .nq(nvis_latch1_nq));
	dlatch nvis_latch2 (.d(nvis_latch1_nq), .en(PCLK), .nq(nvis_latch2_nq));
	dlatch fnt_latch1 (.d(HPLA_out[11]), .en(n_PCLK), .nq(fnt_latch1_nq));
	dlatch fnt_latch2 (.d(fnt_latch1_nq), .en(PCLK), .nq(fnt_latch2_nq));
	dlatch ftb_latch1 (.d(HPLA_out[12]), .en(n_PCLK), .nq(ftb_latch1_nq));
	dlatch ftb_latch2 (.d(ftb_latch1_nq), .en(PCLK), .q(ftb_latch2_q));
	dlatch fta_latch1 (.d(HPLA_out[13]), .en(n_PCLK), .nq(fta_latch1_nq));
	dlatch fta_latch2 (.d(fta_latch1_nq), .en(PCLK), .q(fta_latch2_q));
	dlatch fo_latch1 (.d(HPLA_out[14]), .en(n_PCLK), .q(fo_latch1_q));
	dlatch fo_latch2 (.d(HPLA_out[15]), .en(n_PCLK), .q(fo_latch2_q));
	dlatch fo_latch3 (.d(fo3), .en(PCLK), .q(fo_latch3_q), .nq(fo_latch3_nq));
	dlatch fat_latch1 (.d(HPLA_out[16]), .en(n_PCLK), .nq(fat_latch1_nq));
	
	dlatch bp_latch1 (.d(HPLA_out[17]), .en(n_PCLK), .q(bp_latch1_q));
	dlatch bp_latch2 (.d(HPLA_out[18]), .en(n_PCLK), .q(bp_latch2_q));
	dlatch hb_latch1 (.d(HPLA_out[19]), .en(n_PCLK), .q(hb_latch1_q));
	dlatch hb_latch2 (.d(HPLA_out[20]), .en(n_PCLK), .q(hb_latch2_q));
	dlatch cb_latch1 (.d(HPLA_out[21]), .en(n_PCLK), .q(cb_latch1_q));
	dlatch cb_latch2 (.d(HPLA_out[22]), .en(n_PCLK), .q(cb_latch2_q));
	dlatch sync_latch1 (.d(burst_ff_nq), .en(PCLK), .q(sync_latch1_q));
	dlatch sync_latch2 (.d(~fporch_ff_nq), .en(PCLK), .q(sync_latch2_q));

	rsff fporch_ff (.r(fp_latch1_q), .s(fp_latch2_q), .nq(fporch_ff_nq));
	rsff bporch_ff (.r(bp_latch2_q), .s(bp_latch1_q), .q(bporch_ff_q));
	rsff hblank_ff (.r(hb_latch2_q), .s(hb_latch1_q), .q(hblank_ff_q), .nq(hblank_ff_nq));
	rsff burst_ff (.r(cb_latch1_q), .s(cb_latch2_q), .nq(burst_ff_nq));

	nor (clp, clpo_latch1_q, clpb_latch1_nq);
	nor (fo3, fo_latch1_q, fo_latch2_q);

	assign S_EV = sev_latch2_nq;
	assign CLIP_O = ~(n_OBCLIP | clpo_latch2_q);
	assign CLIP_B = ~(n_BGCLIP | clpb_latch2_q);
	assign Z_HPOS = hpos_latch2_nq;
	assign n_EVAL = ~eval_latch2_nq;
	assign E_EV = eev_latch2_nq;
	assign I_OAM2 = ioam_latch2_nq;
	assign PAR_O = paro_latch2_nq;
	assign n_VIS = ~nvis_latch2_nq;
	assign n_FNT = ~fnt_latch2_nq;
	assign F_TB = ~(ftb_latch2_q | fo_latch3_q);
	assign F_TA = ~(fta_latch2_q | fo_latch3_q);
	assign n_FO = fo_latch3_nq;
	assign F_AT = ~(fo3 | fat_latch1_nq);
	assign BPORCH = bporch_ff_q;
	assign SC_CNT = ~(hblank_ff_nq | BLACK);
	assign n_HB = hblank_ff_q;
	assign BURST = ~(sync_latch1_q | SYNC);
	assign SYNC = ~(sync_latch2_q | VSYNC);

endmodule // HPosLogic

// Vertical logic associated with the V decoder
module VPosLogic (PCLK, n_PCLK, n_HB, BPORCH, BLACK, VPLA_out, 
	n_PICTURE, RESCL, VSYNC, nVSET, VB, BLNK);

	input PCLK;
	input n_PCLK;
	input n_HB;
	input BPORCH;
	input BLACK;
	input [9:0] VPLA_out;
	
	output n_PICTURE;
	output RESCL;
	output VSYNC;
	output nVSET;
	output VB;
	output BLNK;

	// Wires

	wire vsync_latch1_q;
	wire pic_latch1_q;
	wire pic_latch2_q;
	wire vset_latch1_nq;
	wire vb_latch1_q;
	wire vb_latch2_q;
	wire blnk_latch1_q;
	wire vclr_latch1_nq;
	wire vclr_latch2_nq;

	wire vsync_ff_q;
	wire picture_ff_q;
	wire vb_ff_nq;
	wire blnk_ff_q;

	// Instances

	dlatch vsync_latch1 (.d(~(n_HB | vsync_ff_q)), .en(PCLK), .q(vsync_latch1_q));
	dlatch pic_latch1 (.d(picture_ff_q), .en(PCLK), .q(pic_latch1_q));
	dlatch pic_latch2 (.d(BPORCH), .en(PCLK), .q(pic_latch2_q));
	dlatch vset_latch1 (.d(VPLA_out[4]), .en(n_PCLK), .nq(vset_latch1_nq));
	dlatch vb_latch1 (.d(VPLA_out[5]), .en(n_PCLK), .q(vb_latch1_q));
	dlatch vb_latch2 (.d(VPLA_out[6]), .en(n_PCLK), .q(vb_latch2_q));
	dlatch blnk_latch1 (.d(VPLA_out[7]), .en(n_PCLK), .q(blnk_latch1_q));
	dlatch vclr_latch1 (.d(VPLA_out[8]), .en(n_PCLK), .nq(vclr_latch1_nq));
	dlatch vclr_latch2 (.d(vclr_latch1_nq), .en(PCLK), .nq(vclr_latch2_nq));

	rsff vsync_ff (.r(n_HB & VPLA_out[0]), .s(n_HB & VPLA_out[1]), .q(vsync_ff_q));
	rsff picture_ff (.r(BPORCH & VPLA_out[2]), .s(BPORCH & VPLA_out[3]), .q(picture_ff_q));
	rsff vb_ff (.r(vb_latch1_q), .s(vb_latch2_q), .nq(vb_ff_nq));
	rsff blnk_ff (.r(blnk_latch1_q), .s(vb_latch2_q), .q(blnk_ff_q));

	assign n_PICTURE = ~(~(pic_latch1_q | pic_latch2_q));
	assign RESCL = vclr_latch2_nq;
	assign VSYNC = vsync_latch1_q;
	assign nVSET = vset_latch1_nq;
	assign VB = ~vb_ff_nq;
	assign BLNK = ~(~blnk_ff_q & ~BLACK);

endmodule // VPosLogic
