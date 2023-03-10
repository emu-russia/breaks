// NES HDL Descrption. Based on KiCad schematics by Redherring32

module NES (CLK, CIC_CLK, AUDIO_Out, VIDEO_Out);

	input CLK; 			// 21.477272 MHz
	input CIC_CLK; 		// 4 MHz
	output AUDIO_Out;
	output VIDEO_Out;

	wire vdd;
	wire gnd;

	assign vdd = 1'b1;
	assign gnd = 1'b0;

	// Clocks
	wire PPU_CLK;
	wire SYSTEM_CLK;
	wire CPU_CLK;

	assign PPU_CLK = CLK;
	assign SYSTEM_CLK = CLK;
	assign CPU_CLK = CLK;

	// Buses
	wire [7:0] CPU_D;
	wire [15:0] CPU_A;
	wire [7:0] PPU_D;
	wire [13:0] PPU_A;

	wire CPU_RnW;
	wire [2:0] RS; 		// PPU register index

	// PPU <-> VRAM
	wire PPU_nRD;
	wire PPU_nWR;
	wire PPU_ALE;

	// I/O
	wire nOE1; 		// aka nRDP0 from cpu
	wire nOE2; 		// aka nRDP1 from cpu
	wire [2:0] OUT; 	// from cpu
	wire [4:0] P1_D; 		// $4016 bus
	wire [4:0] P2_D;		// $4017 bus
	wire [9:0] EXP;

	// Misc
	wire nRST;
	wire nIRQ;
	wire nNMI;
	wire M2; 			// from cpu
	wire AUX1;
	wire AUX2;
	wire PPU_VIDEO;
	wire EXP_VIDEO;
	wire EXPAUDIO_ToMB;
	wire EXPAUDIO_FromMB;
	wire WRAM_nCE;
	wire PPU_nCE; 		// 0: Enable CPU/PPU I/F	
	wire nROMSEL;
	wire VRAM_A10;
	wire VRAM_nCE;

	wire P4_IO_Unused;
	wire P5_IO_Unused;

	wire [3:0] nY1;
	wire [3:0] nY2;

	// CIC
	wire CIC_TO_MB;   		// Cart CIC -> MB CIC
	wire CIC_TO_CART; 		// MB CIC -> Cart CIC
	wire CIC_RST; 			// Cart CIC -> MB CIC

	// Instantiate

	CPU cpu (
		.CLK(CPU_CLK),
		.M2(M2),
		.TST(gnd),
		.nRST(nRST),
		.nIRQ(nIRQ),
		.nNMI(nNMI),
		.D(CPU_D),
		.A(CPU_A),
		.RnW(CPU_RnW),
		.nOE1(nOE1),
		.nOE2(nOE2),
		.OUT(OUT),
		.AUX1(AUX1),
		.AUX2(AUX2) );

	PPU ppu (
		.CLK(PPU_CLK),
		.nRST(nRST),
		.nINT(nNMI),
		.nDBE(PPU_nCE),
		.CPU_RnW(CPU_RnW),
		.CPU_D(CPU_D),
		.RS(CPU_A[2:0]),
		.EXT({gnd,gnd,gnd,gnd}),
		.nRD(PPU_nRD),
		.nWR(PPU_nWR),
		.AD(PPU_D),
		.A(PPU_A[13:8]),
		.ALE(PPU_ALE),
		.VIDEO(PPU_VIDEO) );

	CIC cic (
		.CLK_IN(CIC_CLK),
		.DATA_OUT(CIC_TO_CART),
		.DATA_IN(CIC_TO_MB),
		.SEED(vdd),
		.LOCK_KEY(vdd),
		.RST(vdd),
		.CIC_RST(CIC_RST),
		.nHOST_RST(nRST) );

	RAM WRAM (
		.A(CPU_A[10:0]),
		.D(CPU_D),
		.nCS(WRAM_nCE),
		.nWE(CPU_RnW),
		.nOE(gnd) );

	RAM VRAM (
		.A({VRAM_A10,PPU_A[9:0]}),
		.D(PPU_D),
		.nCS(VRAM_nCE),
		.nWE(PPU_nWR),
		.nOE(PPU_nRD) );

	LS373 PPU_AddrLatch (
		.nOE(gnd),
		.Q(PPU_A[7:0]),
		.D(PPU_D),
		.LE(PPU_ALE) );

	LS139 DMX (
		.First_nE(gnd),
		.First_A({CPU_A[15],M2}),
		.First_nY(nY1),
		.Second_nE(nY1[1]),
		.Second_A({CPU_A[14],CPU_A[13]}),
		.Second_nY(nY2) );

	assign nROMSEL = nY1[3];
	assign WRAM_nCE = nY2[0];
	assign PPU_nCE = nY2[1];

	CtrlPort P4 (
		.CUP(nOE1),
		.OUT0(OUT[0]),
		.D0(P1_D[0]),
		.D3(P1_D[3]),
		.D4(P1_D[4]) );
	
	CtrlPort P5 (
		.CUP(nOE2),
		.OUT0(OUT[0]),
		.D0(P2_D[0]),
		.D3(P2_D[3]),
		.D4(P2_D[4]) );

	LS368 P4_IO (
		.nG1(nOE1),
		.nG2(nOE1),
		.A({P1_D[4],P1_D[3],P1_D[2],gnd,P1_D[1],P1_D[0]}),
		.nY({CPU_D[4],CPU_D[3],CPU_D[2],P4_IO_Unused,CPU_D[1],CPU_D[0]}) );

	LS368 P5_IO (
		.nG1(nOE2),
		.nG2(nOE2),
		.A({P2_D[4],P2_D[3],P2_D[2],gnd,P2_D[1],P2_D[0]}),
		.nY({CPU_D[4],CPU_D[3],CPU_D[2],P5_IO_Unused,CPU_D[1],CPU_D[0]}) );

	CartPort P1 (
		.SYSTEM_CLK(SYSTEM_CLK),
		.M2(M2),
		.CIC_TO_MB(CIC_TO_MB),
		.CIC_TO_CART(CIC_TO_CART),
		.CIC_CLK(CIC_CLK),
		.CIC_RST(CIC_RST), 
		.CPU_D(CPU_D),
		.CPU_A(CPU_A[14:0]), 		// not using A15
		.CPU_RnW(CPU_RnW),
		.nROMSEL(nROMSEL),
		.EXP(EXP),
		.nIRQ(nIRQ), 
		.PPU_D(PPU_D),
		.PPU_A(PPU_A),
		.PPU_nA13(~PPU_A[13]),
		.VRAM_A10(VRAM_A10),
		.VRAM_nCE(VRAM_nCE),
		.PPU_nRD(PPU_nRD),
		.PPU_nWR(PPU_nWR) );

	ExpPort P2 (
		.CIC_CLK(CIC_CLK),
		.AUDIO_IN(EXPAUDIO_FromMB),
		.AUDIO_OUT(EXPAUDIO_ToMB),
		.VIDEO(EXP_VIDEO),
		.nNMI(nNMI),
		.nIRQ(nIRQ),
		.A15(CPU_A[15]),
		.EXP(EXP),
		.P1_D(P1_D),
		.P2_D(P2_D),
		.nOE1(nOE1),
		.nOE2(nOE2),
		.OUT(OUT),
		.D(CPU_D) );

	AudioMix aud_out (.AUX1(AUX1), .AUX2(AUX2), .FromEXP(EXPAUDIO_ToMB), .ToExp(EXPAUDIO_FromMB), .AUDIO_Out(AUDIO_Out) );

	VideoMix vid_out (.FromPPU(PPU_VIDEO), .FromEXP(EXP_VIDEO), .VIDEO_Out(VIDEO_Out) );

	// Pullups

	pullup p1_pullups [4:0] (P1_D);
	pullup p2_pullups [4:0] (P2_D);
	pullup (nIRQ);
	pullup (nNMI);
	pullup (nOE1);
	pullup (nOE2);
	pullup (PPU_A[13]);
	pullup (OUT[0]);

endmodule // NES

module CPU (CLK, M2, TST, nRST, nIRQ, nNMI, D, A, RnW, nOE1, nOE2, OUT, AUX1, AUX2);
	input CLK;
	output M2;
	input TST;
	input nRST;
	input nIRQ;
	input nNMI;
	inout [7:0] D;
	output [15:0] A;
	output RnW;
	output nOE1;
	output nOE2;
	output [2:0] OUT;
	output AUX1;
	output AUX2;
endmodule // CPU

module PPU (CLK, nRST, nINT, nDBE, CPU_RnW, CPU_D, RS, EXT, nRD, nWR, AD, A, ALE, VIDEO);
	input CLK;
	input nRST;
	output nINT;
	inout [3:0] EXT;
	// CPU I/F
	input nDBE;
	input CPU_RnW;
	inout [7:0] CPU_D;
	input [2:0] RS;
	// VRAM I/F
	output nRD;
	output nWR;
	inout [7:0] AD;
	output [13:8] A;
	output ALE;
	output VIDEO;
endmodule // PPU

module CIC (CLK_IN, DATA_OUT, DATA_IN, SEED, LOCK_KEY, RST, CIC_RST, nHOST_RST);
	input CLK_IN;
	output DATA_OUT;
	input DATA_IN;
	input SEED;
	input LOCK_KEY;
	input RST;
	input CIC_RST;
	output nHOST_RST;
endmodule // CIC

module CartPort (SYSTEM_CLK, M2, CIC_TO_MB, CIC_TO_CART, CIC_CLK, CIC_RST, 
	CPU_D, CPU_A, CPU_RnW, nROMSEL, EXP, nIRQ, 
	PPU_D, PPU_A, PPU_nA13, VRAM_A10, VRAM_nCE, PPU_nRD, PPU_nWR);

	input SYSTEM_CLK; 		// NES Board specific ⚠️
	input M2;
	output CIC_TO_MB; 		// NES Board specific ⚠️
	input CIC_TO_CART; 		// NES Board specific ⚠️
	input CIC_CLK;			// NES Board specific ⚠️
	output CIC_RST;			// NES Board specific ⚠️

	// CPU Part
	inout [7:0] CPU_D;
	input [14:0] CPU_A; 	// not using A15
	input CPU_RnW;
	input nROMSEL;
	input [9:0] EXP;		// NES Board specific ⚠️
	output nIRQ;

	// PPU Part
	// If you've been doing NES/Famicom for a long time, you've long known that the cartridge controls the VRAM access for the PPU. For everyone else, welcome to the world of Alien.
	inout [7:0] PPU_D;
	input [13:0] PPU_A;
	input PPU_nA13;
	output VRAM_A10;
	output VRAM_nCE;
	input PPU_nRD;
	input PPU_nWR;

endmodule // CartPort

module CtrlPort (CUP, OUT0, D0, D3, D4);
	input CUP;
	input OUT0;
	inout D0;
	inout D3;
	inout D4;
endmodule // CtrlPort

// NES Board specific ⚠️
module ExpPort (CIC_CLK, AUDIO_IN, AUDIO_OUT, VIDEO, nNMI, nIRQ, A15, EXP, P1_D, P2_D, nOE1, nOE2, OUT, D);
	input CIC_CLK;
	input AUDIO_IN;
	output AUDIO_OUT;
	output VIDEO;
	output nNMI;
	output nIRQ;
	input A15;
	inout [9:0] EXP;
	output [4:0] P1_D; 		// $4016
	output [4:0] P2_D;		// $4017
	input nOE1;
	input nOE2;
	input [2:0] OUT;
	inout [7:0] D;
endmodule // ExpPort

// 2 KByte (0x800 bytes)
module RAM (A, D, nCS, nWE, nOE);
	input [10:0] A;
	input [7:0] D;
	input nCS;
	input nWE;
	input nOE;
endmodule // RAM

// Tristate x6
module LS368 (nG1, nG2, A, nY);
	input nG1; 			// 0: Tristates 5,6
	input nG2; 			// 0: Tristates 1,2,3,4
	input [5:0] A; 		// A1-A6 actually
	output [5:0] nY; 	// nY1-nY6 actually
endmodule // LS368

// 2-to-4 dmx
module LS139 (First_nE, First_A, First_nY, Second_nE, Second_A, Second_nY);
	input First_nE;
	input [1:0] First_A;
	output [3:0] First_nY;
	input Second_nE;
	input [1:0] Second_A;
	output [3:0] Second_nY;
endmodule // LS139

// PPU address latch
module LS373 (nOE, Q, D, LE);
	input nOE; 			// 3-state output enable input (active LOW)
	output [7:0] Q; 	// 3-state latch outputs
	input [7:0] D;		// data inputs
	input LE;			// latch enable input (active HIGH)
endmodule // LS373

module AudioMix (AUX1, AUX2, FromEXP, ToExp, AUDIO_Out);
	input AUX1;
	input AUX2;
	input FromEXP;
	output ToExp;
	output AUDIO_Out;
	// There's some kind of magic going on, we don't care.
endmodule // AudioMix

module VideoMix (FromPPU, FromEXP, VIDEO_Out);
	input FromPPU;
	input FromEXP;
	output VIDEO_Out;
	// There's some kind of magic going on, we don't care.
endmodule // VideoMix
