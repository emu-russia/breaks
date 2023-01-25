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
	input [8:0] VPLA_out;		// Outputs from V decoder
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
	wire EvenOddOut; 			// Intermediate signal for the HCounter control circuit.
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

	EvenOdd even_odd (
		.V8(V_out[8]),
		.RES(RES),
		.nHPLA_5(~HPLA_out[5]),
		.RESCL(RESCL),
		.EvenOddOut(EvenOddOut) );

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

	HVCounterControl hv_ctrl (
		.n_PCLK(n_PCLK),
		.HPLA_23(HPLA_out[23]),
		.EvenOddOut(EvenOddOut),
		.VPLA_2(VPLA_out[2]),
		.V_IN(V_IN),
		.HC(HC),
		.VC(VC) );

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

endmodule // DelayedH

// EVEN/ODD circuitry
module EvenOdd (V8, RES, nHPLA_5, RESCL, EvenOddOut);

	input V8;
	input RES;
	input nHPLA_5;
	input RESCL;
	output EvenOddOut;

endmodule // EvenOdd

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
	output DB7Out;

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

endmodule // HVCounterControl

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

endmodule // HPosLogic

// Vertical logic associated with the V decoder
module VPosLogic (PCLK, n_PCLK, n_HB, BPORCH, BLACK, VPLA_out, 
	n_PICTURE, RESCL, VSYNC, nVSET, VB, BLNK);

	input PCLK;
	input n_PCLK;
	input n_HB;
	input BPORCH;
	input BLACK;
	input [8:0] VPLA_out;
	
	output n_PICTURE;
	output RESCL;
	output VSYNC;
	output nVSET;
	output VB;
	output BLNK;

endmodule // VPosLogic
