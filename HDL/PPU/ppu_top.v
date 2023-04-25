
module PPU(RnW, D, RS, n_DBE, EXT, CLK, n_INT, ALE, AD, A, n_RD, n_WR, n_RES, VOut);

	input RnW;					// Read-notWrite. Used to read/write PPU registers. If R/W = 1 it reads, otherwise it writes. It is easy to remember: "Read(1), do not write".
	inout [7:0] D;				// The data bus for transferring register values. When /DBE = 1 the bus is disconnected (Z)
	input [2:0] RS;				// Register Select. Sets the PPU register number (0-7)
	input n_DBE;				// Data Bus Enable. If /DBE = 0, then the D0-D7 bus is used to exchange values with the PPU registers, otherwise the bus is disconnected.
	inout [3:0] EXT;			// The bus is used to mix the color of the current pixel from another PPU (slave mode), or to output the current color to the outside (master mode).
								// The direction of the bus is determined by the register bit $2000[6] (0: PPU slave mode, 1: PPU master mode)
	input CLK;					// Master Clock
	output n_INT;				// PPU interrupt signal (VBlank)
	output ALE;					// Address Latch Enable. If ALE=1, then the bus AD0-AD7 operates as an address bus (A0-A7), otherwise it operates as a data bus (D0-D7)
	inout [7:0] AD;				// Multiplexed address/data bus. When ALE=1 the bus operates as an address bus, when ALE=0 the bus sends data to the PPU (patterns, attributes), or out from the PPU port (register $2007)
	output [5:0] A;				// This bus carries the rest of the address lines.
	output n_RD;				// /RD=0: the PPU data bus (AD0-AD7) is used for reading (VRAM -> PPU)
	output n_WR;				// /WR=0: the PPU data bus (AD0-AD7) is used for writing (PPU -> VRAM)
	input n_RES;				// /RES=0: reset the PPU
	output [31:0] VOut;			// Composite video signal from DAC [float as uint32]

	// Wires

	wire n_CLK_frompad;			// First half of the PPU cycle
	wire CLK_frompad;			// Second half of the PPU cycle
	wire n_PCLK;				// First half of the Pixel Clock cycle
	wire PCLK;					// Second half of the Pixel Clock cycle

	wire RES_frompad;			// Global reset
	wire RegClear;
	
	wire n_CpuRD;				// /RD to D0-D7 pads (CPU I/F)
	wire n_CpuWR;				// /WR to D0-D7 pads (CPU I/F)

	wire n_W5_1;				// 0: First write to $2005
	wire n_W5_2;				// 0: Second write to $2005
	wire n_W6_1;				// 0: First write to $2006
	wire n_W6_2;				// 0: Second write to $2006
	wire n_R7;					// 0: Read $2007
	wire n_W7;					// 0: Write $2007
	wire n_W4;					// 0: Write $2004
	wire n_W3;					// 0: Write $2003
	wire n_R2;					// 0: Read $2002
	wire n_W1;					// 0: Write $2001
	wire n_W0;					// 0: Write $2000
	wire n_R4;					// 0: Read $2004

	wire I_1_32;				// Increment PPU address 1/32.
	wire OBSEL;					// Selecting Pattern Table for sprites
	wire BGSEL;					// Selecting Pattern Table for background
	wire O_8_16;				// Object lines 8/16 (sprite size).
	wire n_SLAVE;				// PPU operating mode (Master/Slave)
	wire VBL_Ena;				// Used in the VBlank interrupt handling circuitry
	wire BnW;
	wire n_BGCLIP;				// To generate the CLIP_B control signal
	wire n_OBCLIP;				// To generate the CLIP_O control signal
	wire BGE;
	wire BLACK;					// Active when PPU rendering is disabled (see $2001[3] и $2001[4]).
	wire OBE;
	wire n_TR;					// 0: "Tint Red". Modifying value for Emphasis
	wire n_TG;					// 0: "Tint Green". Modifying value for Emphasis
	wire n_TB;					// 0: "Tint Blue". Modifying value for Emphasis

	wire [8:0] HCnt; 			// H counter bits
	wire [8:0] VCnt;			// V counter bits
	wire [23:0] HDecoder_out; 	// H decoder outputs
	wire [9:0] VDecoder_out; 	// V decoder outputs

	wire H0_D;					// H0 signal delayed by one DLatch
	wire nH1_D;					// H1 signal delayed by one DLatch (in inverse logic)
	wire nH2_D;					// H2 signal delayed by one DLatch (in inverse logic)

	wire H0_DD;					// H0-H5 signals delayed by two DLatch
	wire H1_DD;	
	wire H2_DD;	
	wire H3_DD;
	wire H4_DD;
	wire H5_DD;

	wire S_EV;					// "Start Sprite Evaluation"
	wire CLIP_O;				// "Clip Objects". 1: Do not show the left 8 screen points for sprites. Used to get the CLPO signal that goes into the OAM FIFO.
	wire CLIP_B;				// "Clip Background". 1: Do not show the left 8 points of the screen for the background. Used to get the /CLPB signal that goes into the Data Reader.
	wire Z_HPOS;				// "Clear HPos". Clear the H counters in the sprite FIFO and start the FIFO
	wire n_EVAL;				// 0: "Sprite Evaluation in Progress"
	wire E_EV;					// "End Sprite Evaluation"
	wire I_OAM2;				// "Init OAM2". Initialize an additional (temp) OAM
	wire PAR_O;					// "PAR for Object". Selecting a tile for an object (sprite)
	wire n_VIS;					// "Not Visible". The invisible part of the signal (used in sprite logic)
	wire n_FNT;					// 0: "Fetch Name Table"
	wire F_TB;					// "Fetch Tile B"
	wire F_TA;					// "Fetch Tile A"
	wire n_FO;					// 0: "Fetch Output Enable"
	wire F_AT;					// "Fetch Attribute Table"
	wire SC_CNT;				// "Scroll Counters Control". Update the scrolling registers.
	wire BURST;					// Do Color Burst
	wire SYNC;					// Do Sync pulse

	wire n_PICTURE;				// Visible part of the scan-lines
	wire RESCL;					// "Reset FF Clear" / "VBlank Clear". VBlank period end event. Initially the connection was established with contact /RES, but then it turned out a more global purpose of the signal. Therefore, the signal has two names.
	wire VB;					// Active when the invisible part of the video signal is output (used only in H Decoder)
	wire BLNK;					// Active when PPU rendering is disabled (by BLACK signal) or during VBlank
	wire Int;					// 1: "Interrupt". PPU Interrupt
	wire V_IN;					// "VCounter In". Increment the VCounter
	wire HC;					// "HCounter Clear"
	wire VC;					// "VCounter Clear"

	wire n_CLPB;				// To enable background clipping
	wire CLPO;					// To enable sprite clipping

	wire [7:0] n_OAM;			// OAM Address. (inverse polarity)
	wire OAM8;					// Selects an additional (temp) OAM for addressing
	wire OAMCTR2;				// OAM Buffer Control
	wire OFETCH;
	wire SPR_OV;				// Sprites on the current line are more than 8 or the main OAM counter is full, copying is stopped
	wire [7:0] OV;
	wire PD_FIFO;				// To zero the output of the H. Inv circuit
	wire n_SPR0_EV;				// 0: Sprite "0" is found on the current line. To define a Sprite 0 Hit event
	wire n_SPR0HIT;				// To detect a Sprite 0 Hit event (from FIFO side)
	wire n_ZCOL0;				// Sprite color. ⚠️ The lower 2 bits are in inverse logic, the higher 2 bits are in direct logic.
	wire n_ZCOL1;
	wire ZCOL2;
	wire ZCOL3;
	wire n_ZPRIO;				// 0: Priority of sprite over background
	wire n_SH2;

	wire [4:0] TH;
	wire [4:0] TV;
	wire NTH;
	wire NTV;
	wire [2:0] FH;				// Fine H value
	wire [2:0] FV;				// Fine V value
	wire [2:0] n_FVO;
	wire [4:0] THO;
	wire [4:0] TVO;
	wire W6_2_Ena;
	wire [3:0] BGC;				// Background color
	wire [13:0] PAD;

	wire [7:0] CPU_DB;			// Internal CPU data bus DB
	wire [7:0] PD;				// Read-only PPU Data bus
	wire [13:0] n_PA_out;		// VRAM address bus (Output)
	wire [7:0] OB;				// OAM Buffer output value
	wire [3:0] EXT_in;			// Input subcolor from Master PPU
	wire [3:0] n_EXT_out;		// Output color for Slave PPU

	wire DB_PAR;
	wire TSTEP;					// For PAR Counters control logic
	wire WR;					// Output value for /WR pad
	wire RD;					// Output value for /RD pad
	wire n_ALE;					// Output value for ALE pad
	wire PD_RB;					// Opens RB input (connect PD and RB).
	wire XRB;					// Opens RB output (connect RB and DB).
	wire TH_MUX;				// Send the TH Counter value to the MUX input, which will cause the value to go into the palette as Direct Color.

	wire [4:0] CRAM_Addr;
	wire [3:0] n_CC;			// 4 bits of the chrominance of the current "pixel" (inverted value)
	wire [1:0] n_LL;			// 2 bits of the luminance of the current "pixel" (inverted value)
	wire [10:0] RawVOut; 		// Unprocessed RAW Video

	// Module instantiation

	PpuPadsLogic pads(
		.n_PCLK(n_PCLK),
		.n_CpuRD(n_CpuRD),
		.n_CpuWR(n_CpuWR),
		.CPU_DB(CPU_DB),
		.DPads(D),
		.n_ALE_topad(n_ALE),
		.ALE(ALE),
		.PD_out(PD),
		.n_PA(n_PA_out),
		.PAPads(A),
		.ADPads(AD),
		.RD_topad(RD),
		.WR_topad(WR),
		.n_RDPad(n_RD),
		.n_WRPad(n_WR), 
		.EXTPads(EXT),
		.n_SLAVE(n_SLAVE),
		.EXT_in(EXT_in),
		.n_EXT_out(n_EXT_out), 
		.CLKPad(CLK),
		.n_CLK_frompad(n_CLK_frompad),
		.CLK_frompad(CLK_frompad),
		.n_RESPad(n_RES),
		.RES(RES_frompad),
		.RESCL(RESCL),
		.RC(RegClear),
		.Int_topad(Int),
		.n_INTPad(n_INT) );

	PixelClock pclk(
		.n_CLK(n_CLK_frompad),
		.CLK(CLK_frompad),
		.RES(RES_frompad),
		.n_PCLK(n_PCLK),
		.PCLK(PCLK) );

	RWDecoder rwdec(
		.RnW(RnW),
		.n_DBE(n_DBE),
		.n_RD(n_CpuRD),
		.n_WR(n_CpuWR) );

	PpuRegs regs(
		.RC(RegClear),
		.n_DBE(),
		.RS(RS),
		.RnW(RnW),
		.CPU_DB(CPU_DB), 
		.n_W5_1(n_W5_1),
		.n_W5_2(n_W5_2),
		.n_W6_1(n_W6_1),
		.n_W6_2(n_W6_2),
		.n_R7(n_R7),
		.n_W7(n_W7),
		.n_W4(n_W4),
		.n_W3(n_W3),
		.n_R2(n_R2),
		.n_W1(n_W1),
		.n_W0(n_W0),
		.n_R4(n_R4), 
		.I_1_32(I_1_32),
		.OBSEL(OBSEL),
		.BGSEL(BGSEL),
		.O_8_16(O_8_16),
		.n_SLAVE(n_SLAVE),
		.VBL(VBL_Ena), 
		.BnW(BnW),
		.n_BGCLIP(n_BGCLIP),
		.n_OBCLIP(n_OBCLIP),
		.BGE(BGE),
		.BLACK(BLACK),
		.OBE(OBE),
		.n_TR(n_TR),
		.n_TG(n_TG),
		.n_TB(n_TB) );

	HVCounters hv(
		.n_PCLK(n_PCLK),
		.PCLK(PCLK),
		.RES(RES_frompad),
		.HC(HC),
		.VC(VC),
		.V_IN(V_IN),
		.H_out(HCnt),
		.V_out(VCnt) );

	HVDecoder hvdec(
		.H_in(HCnt),
		.V_in(VCnt),
		.VB(VB),
		.BLNK(BLNK),
		.HPLA_out(HDecoder_out),
		.VPLA_out(VDecoder_out) );

	PPU_FSM fsm(
		.n_PCLK(n_PCLK),
		.PCLK(PCLK),
		.H_out(HCnt),
		.V_out(VCnt),
		.HPLA_out(HDecoder_out),
		.VPLA_out(VDecoder_out),
		.RES(RES_frompad),
		.VBL_EN(VBL_Ena),
		.n_R2(n_R2),
		.n_DBE(n_DBE),
		.n_OBCLIP(n_OBCLIP),
		.n_BGCLIP(n_BGCLIP),
		.BLACK(BLACK),
		.H0_DD(H0_DD),
		.H0_D(H0_D),
		.H1_DD(H1_DD),
		.nH1_D(nH1_D),
		.H2_DD(H2_DD),
		.nH2_D(nH2_D),
		.H3_DD(H3_DD),
		.H4_DD(H4_DD),
		.H5_DD(H5_DD),
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
		.SC_CNT(SC_CNT),
		.BURST(BURST),
		.SYNC(SYNC),
		.n_PICTURE(n_PICTURE),
		.RESCL(RESCL),
		.VB(VB),
		.BLNK(BLNK),
		.Int(Int),
		.DB7(CPU_DB[7]),
		.V_IN(V_IN),
		.HC(HC),
		.VC(VC) );

	Clipper clip(
		.n_PCLK(n_PCLK),
		.n_VIS(n_VIS),
		.CLIP_B(CLIP_B),
		.CLIP_O(CLIP_O),
		.BGE(BGE),
		.OBE(OBE),
		.n_CLPB(n_CLPB),
		.CLPO(CLPO) );

	OAMEval eval(
		.n_PCLK(n_PCLK),
		.PCLK(PCLK),
		.BLNK(BLNK),
		.I_OAM2(I_OAM2),
		.n_VIS(n_VIS),
		.PAR_O(PAR_O),
		.n_EVAL(n_EVAL),
		.RESCL(RESCL),
		.H0_DD(H0_DD),
		.H0_D(H0_D),
		.n_H2_D(nH2_D),
		.OFETCH(OFETCH),
		.n_FNT(n_FNT),
		.S_EV(S_EV),
		.n_W3(n_W3),
		.n_DBE(n_DBE),
		.DB5(CPU_DB[5]), 
		.n_OAM(n_OAM),
		.OAM8(OAM8),
		.OAMCTR2(OAMCTR2),
		.SPR_OV(SPR_OV),
		.OV(OV),
		.PD_FIFO(PD_FIFO),
		.n_SPR0_EV(n_SPR0_EV) );

	OAMBlock oam(
		.n_PCLK(n_PCLK),
		.PCLK(PCLK),
		.n_OAM(n_OAM),
		.OAM8(OAM8),
		.BLNK(BLNK),
		.SPR_OV(SPR_OV),
		.OAMCTR2(OAMCTR2),
		.H0_DD(H0_DD),
		.n_VIS(n_VIS),
		.I_OAM2(I_OAM2),
		.n_W4(n_W4),
		.n_R4(n_R4),
		.n_DBE(n_DBE), 
		.CPU_DB(CPU_DB),
		.OB_Out(OB),
		.OFETCH(OFETCH) );

	ObjectFIFO fifo(
		.n_PCLK(n_PCLK),
		.PCLK(PCLK),
		.PAR_O(PAR_O),
		.H0_DD(H0_DD),
		.H1_DD(H1_DD),
		.H2_DD(H2_DD),
		.H3_DD(H3_DD),
		.H4_DD(H4_DD),
		.H5_DD(H5_DD),
		.Z_HPOS(Z_HPOS),
		.n_VIS(n_VIS),
		.PD_FIFO(PD_FIFO),
		.PD(PD),
		.CLPO(CLPO),
		.n_SPR0HIT(n_SPR0HIT),
		.n_ZCOL0(n_ZCOL0),
		.n_ZCOL1(n_ZCOL1),
		.ZCOL2(ZCOL2),
		.ZCOL3(ZCOL3),
		.n_ZPRIO(n_ZPRIO),
		.n_SH2(n_SH2) );

	PataddrGen patgen(
		.n_PCLK(n_PCLK),
		.H0_DD(H0_DD),
		.n_FNT(n_FNT),
		.BGSEL(BGSEL),
		.OBSEL(OBSEL),
		.O8_16(O_8_16),
		.PAR_O(PAR_O),
		.n_SH2(n_SH2),
		.n_H1D(nH1_D),
		.OB(OB),
		.PD(PD),
		.OV(OV[3:0]),
		.n_FVO(n_FVO),
		.PAddr_out(PAD) );

	PAR par(
		.n_PCLK(n_PCLK),
		.PCLK(PCLK),
		.BLNK(BLNK),
		.DB_PAR(DB_PAR),
		.F_AT(F_AT),
		.SC_CNT(SC_CNT),
		.RESCL(RESCL),
		.E_EV(E_EV),
		.TSTEP(TSTEP),
		.F_TB(F_TB),
		.H0_DD(H0_DD),
		.n_H2_D(nH2_D),
		.I_1_32(I_1_32),
		.W6_2_Ena(W6_2_Ena), 
		.PAD_in(PAD),
		.CPU_DB(CPU_DB),
		.TH(TH),
		.TV(TV),
		.NTH(NTH),
		.NTV(NTV),
		.FV(FV), 
		.n_FVO(n_FVO),
		.THO(THO),
		.TVO(TVO),
		.n_PA(n_PA_out) );

	ScrollRegs sccx(
		.n_W0(n_W0),
		.n_W5_1(n_W5_1),
		.n_W5_2(n_W5_2),
		.n_W6_1(n_W6_1),
		.n_W6_2(n_W6_2),
		.n_DBE(n_DBE),
		.RC(RegClear),
		.CPU_DB(CPU_DB),
		.FH(FH),
		.FV(FV),
		.NTH(NTH),
		.NTV(NTV),
		.TV(TV),
		.TH(TH),
		.W6_2_Ena(W6_2_Ena) );

	BGCol bg(
		.n_PCLK(n_PCLK),
		.PCLK(PCLK),
		.H0_DD(H0_DD),
		.F_TA(F_TA),
		.F_TB(F_TB),
		.n_FO(n_FO),
		.F_AT(F_AT),
		.THO(THO),
		.TVO(TVO),
		.FH(FH),
		.PD(PD),
		.n_CLPB(n_CLPB),
		.BGC(BGC) );

	VRAM_Control vrctl(
		.n_PCLK(n_PCLK),
		.PCLK(PCLK), 
		.n_R7(n_R7),
		.n_W7(n_W7),
		.n_DBE(n_DBE),
		.H0_D(H0_D),
		.BLNK(BLNK),
		.nPA(n_PA_out),
		.DB_PAR(DB_PAR),
		.TSTEP(TSTEP),
		.WR(WR),
		.RD(RD),
		.n_ALE(n_ALE),
		.PD_RB(PD_RB),
		.XRB(XRB),
		.TH_MUX(TH_MUX) );

	ReadBuffer rb(
		.XRB(XRB),
		.RC(RegClear),
		.PD_RB(PD_RB),
		.PD_in(PD),
		.CPU_DB(CPU_DB) );

	PictureMUX pmux(
		.n_PCLK(n_PCLK),
		.PCLK(PCLK), 
		.BGC(BGC),
		.n_ZPRIO(n_ZPRIO),
		.n_ZCOL0(n_ZCOL0),
		.n_ZCOL1(n_ZCOL1),
		.ZCOL2(ZCOL2),
		.ZCOL3(ZCOL3),
		.EXT_in(EXT_in),
		.THO(THO),
		.TH_MUX(TH_MUX),
		.PAL_out(CRAM_Addr),
		.n_EXT_out(n_EXT_out) );

	Spr0Hit spr0hit(
		.PCLK(PCLK),
		.BGC(BGC),
		.n_SPR0HIT(n_SPR0HIT),
		.n_SPR0_EV(n_SPR0_EV),
		.n_VIS(n_VIS),
		.n_R2(n_R2),
		.n_DBE(n_DBE),
		.RESCL(RESCL),
		.DB6(CPU_DB[6]) );

	CRAM_Block cram(
		.n_PCLK(n_PCLK),
		.PCLK(PCLK),
		.n_R7(n_R7),
		.n_DBE(n_DBE),
		.TH_MUX(TH_MUX),
		.DB_PAR(DB_PAR),
		.n_PICTURE(n_PICTURE),
		.BnW(BnW),
		.PAL(CRAM_Addr),
		.CPU_DB(CPU_DB), 
		.n_CC(n_CC),
		.n_LL(n_LL) );

	VideoGen vidout(
		.n_CLK(n_CLK_frompad),
		.CLK(CLK_frompad),
		.n_PCLK(n_PCLK),
		.PCLK(PCLK), 
		.RES(RES_frompad),
		.n_CC(n_CC),
		.n_LL(n_LL),
		.BURST(BURST),
		.SYNC(SYNC),
		.n_PICTURE(n_PICTURE),
		.n_TR(n_TR),
		.n_TG(n_TG),
		.n_TB(n_TB), 
`ifdef RP2C07
		.V0(VCnt[0]),
`endif
		.RawVOut(RawVOut) );

	PPU_CompositeDAC dac (.RawIn(RawVOut), .CompositeOut(VOut) );

endmodule // PPU
