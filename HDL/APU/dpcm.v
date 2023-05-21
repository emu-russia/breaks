
// At first glance you might get lost here, but in fact there is nothing complicated: there is a control circuit (which includes a number of subcircuits), counters for sampling, a counter for addressing, and an output circuit.

module DPCMChan (
	PHI1, ACLK1, nACLK2, 
	RES, DB, RnW, LOCK,
	W4010, W4011, W4012, W4013, W4015, n_R4015, 
	n_DMCAB, RUNDMC, DMCRDY, DMCINT,
	DMC_Addr, DMC_Out);

	input PHI1; 			// PHI1 is used together with the R/W core signal to determine the 6502 read cycle, because the RDY setting is ignored by the 6502 core during the write cycle (see datasheet)
	input ACLK1;
	input nACLK2;

	input RES;
	inout [7:0] DB;	
	input RnW;			// CPU data bus mode (1: Read, 0: Write)
	input LOCK;			// The LOCK signal is used to temporarily suspend the sound generators so that their values can be fixed in the debug registers  (2A03 only)

	input W4010;
	input W4011;
	input W4012;
	input W4013;
	input W4015;
	input n_R4015;

	output n_DMCAB;			// 0: Gain control of the address bus to read the DPCM sample
	output RUNDMC;			// 1: DMC is minding its own business and hijacks DMA control
	output DMCRDY;			// 1: DMC Ready. Used to control processor readiness (RDY)
	output DMCINT;			// 1: DMC interrupt is active

	output [15:0] DMC_Addr;		// Address for reading the DPCM sample
	output [6:0] DMC_Out;		// Output value for DAC

	// Internal wires

	wire ACLK2;				// Other ACLK
	wire LOOPMode;			// 1: DPCM looped playback
	wire n_IRQEN;			// 0: Enable interrupt from DPCM
	wire DSLOAD;			// Load value into Sample Counter
	wire DSSTEP;			// Perform Sample Counter decrement
	wire BLOAD;				// Load value into Sample Buffer
	wire BSTEP;				// Perform a Sample Buffer bit shift
	wire NSTEP;				// Perform Sample Bit Counter increment
	wire DSTEP;				// Increment/decrement the DPCM Output counter
	wire PCM;				// Load new sample value into Sample Buffer
	wire DOUT;				// DPCM Out counter has finished counting
	wire n_NOUT;			// 0: Sample Bit Counter has finished counting
	wire SOUT;				// Sample Counter has finished counting
	wire DFLOAD;			// Frequency LFSR finished counting and reloaded itself
	wire n_BOUT; 			// The next bit value pushed out of the Sample Buffer shift register (inverted value)
	wire [7:0] DPA; 		// Register $4012 value
	wire [7:0] DSC; 		// Register $4013 value
	wire [3:0] Fx;			// Decoder in
	wire [8:0] FR;			// Decoder out

	// Instantiate

	// Control

	assign ACLK2 = ~nACLK2;

	DPCM_ControlReg ctrl_reg (.ACLK1(ACLK1), .W4010(W4010), .DB(DB), .Fx(Fx), .n_IRQEN(n_IRQEN), .LOOPMode(LOOPMode) );

	DPCM_Control dpcm_ctrl (
		.nACLK2(nACLK2),
		.ACLK1(ACLK1),
		.ACLK2(ACLK2),
		.PHI1(PHI1),
		.RES(RES),
		.RnW(RnW),
		.LOCK(LOCK),
		.W4015(W4015),
		.n_R4015(n_R4015),
		.LOOPMode(LOOPMode),
		.n_IRQEN(n_IRQEN),
		.DOUT(DOUT),
		.n_NOUT(n_NOUT),
		.SOUT(SOUT),
		.DFLOAD(DFLOAD),
		.DB(DB),
		.n_DMCAB(n_DMCAB),
		.RUNDMC(RUNDMC),
		.DMCRDY(DMCRDY),
		.DMCINT(DMCINT),
		.DSLOAD(DSLOAD),
		.DSSTEP(DSSTEP),
		.BLOAD(BLOAD),
		.BSTEP(BSTEP),
		.NSTEP(NSTEP),
		.DSTEP(DSTEP),
		.PCM(PCM) );

	// Sampling

	DPCM_Decoder decoder (.Fx(Fx), .FR(FR) );

	DPCM_FreqLFSR lfsr (.nACLK2(nACLK2), .ACLK1(ACLK1), .ACLK2(ACLK2), .RES(RES), .FR(FR), .DFLOAD(DFLOAD) );

	DPCM_SampleCounterReg scnt_reg (.ACLK1(ACLK1), .W4013(W4013), .DB(DB), .DSC(DSC) );

	DPCM_SampleCounter scnt (.ACLK1(ACLK1), .RES(RES), .DSLOAD(DSLOAD), .DSSTEP(DSSTEP), .DSC(DSC), .SOUT(SOUT) );

	DPCM_SampleBitCounter sbcnt (.ACLK1(ACLK1), .RES(RES), .NSTEP(NSTEP), .n_NOUT(n_NOUT) );

	DPCM_SampleBuffer sbuf (.ACLK1(ACLK1), .RES(RES), .BLOAD(BLOAD), .BSTEP(BSTEP), .PCM(PCM), .DB(DB), .n_BOUT(n_BOUT) );

	// Addressing & Output

	DPCM_AddressReg addr_reg (.ACLK1(ACLK1), .W4012(W4012), .DB(DB), .DPA(DPA) );

	DPCM_AddressCounter addr_cnt (.ACLK1(ACLK1), .RES(RES), .DSLOAD(DSLOAD), .DSSTEP(DSSTEP), .DPA(DPA), .DMC_Addr(DMC_Addr) );

	DPCM_Output dpcm_out (.ACLK1(ACLK1), .RES(RES), .W4011(W4011), .CountDown(n_BOUT), .DSTEP(DSTEP), .DB(DB), .DMC_Out(DMC_Out), .DOUT(DOUT) );

endmodule // DPCMChan

module DPCM_ControlReg (ACLK1, W4010, DB, Fx, n_IRQEN, LOOPMode);

	input ACLK1;
	input W4010;
	inout [7:0] DB;
	output [3:0] Fx;
	output n_IRQEN;
	output LOOPMode;

	RegisterBit f_reg [3:0] (.ACLK1(ACLK1), .ena(W4010), .d(DB[3:0]), .q(Fx) );
	RegisterBit loop_reg (.ACLK1(ACLK1), .ena(W4010), .d(DB[6]), .q(LOOPMode) );
	RegisterBit irq_reg (.ACLK1(ACLK1), .ena(W4010), .d(DB[7]), .nq(n_IRQEN) );

endmodule // DPCM_ControlReg

module DPCM_Control( nACLK2, ACLK1, ACLK2, PHI1, RES, RnW, LOCK, W4015, n_R4015, LOOPMode, n_IRQEN, DOUT, n_NOUT, SOUT, DFLOAD, DB,
	n_DMCAB, RUNDMC, DMCRDY, DMCINT, DSLOAD, DSSTEP, BLOAD, BSTEP, NSTEP, DSTEP, PCM );

	input nACLK2;
	input ACLK1;
	input ACLK2;
	input PHI1;
	input RES;
	input RnW;
	input LOCK;
	input W4015;
	input n_R4015;
	input LOOPMode;
	input n_IRQEN;
	input DOUT;
	input n_NOUT;
	input SOUT;
	input DFLOAD;
	inout [7:0] DB;

	output n_DMCAB;
	output RUNDMC;
	output DMCRDY;
	output DMCINT;
	output DSLOAD;
	output DSSTEP;
	output BLOAD;
	output BSTEP;
	output NSTEP;
	output DSTEP;
	output PCM;

	// Internal temp wires

	wire ED1;
	wire ED2;
	wire DMC1;
	wire DMC2;
	wire CTRL1;
	wire CTRL2;

	DPCM_IntControl int_ctrl (.RES(RES), .W4015(W4015), .n_R4015(n_R4015), .n_IRQEN(n_IRQEN), .AssertInt(ED1), .DB(DB), .DMCINT(DMCINT) );

	DPCM_EnableControl enable_ctrl (.ACLK1(ACLK1), .RES(RES), .W4015(W4015), .n_R4015(n_R4015), .LOOPMode(LOOPMode), .PCMDone(DMC1), .SOUT(SOUT), .DB(DB), .ED1(ED1), .DMC2(DMC2), .ED2(ED2) );

	DPCM_DMAControl dma_ctrl (.nACLK2(nACLK2), .ACLK1(ACLK1), .ACLK2(ACLK2), .PHI1(PHI1), .RnW(RnW), .RES(RES), .nDMAStop(CTRL1), .nDMCEnableDelay(CTRL2), .DMCRDY(DMCRDY), .RUNDMC(RUNDMC), .n_DMCAB(n_DMCAB) );

	DPCM_SampleCounterControl scnt_ctrl (.nACLK2(nACLK2), .ACLK1(ACLK1), .ACLK2(ACLK2), .PCMDone(DMC1), .DMCFinish(DMC2), .DMCEnable(ED2), .DFLOAD(DFLOAD), .DSLOAD(DSLOAD), .DSSTEP(DSSTEP), .NSTEP(NSTEP), .CTRL2(CTRL2) );

	DPCM_SampleBufferControl sbuf_ctrl (.nACLK2(nACLK2), .ACLK1(ACLK1), .ACLK2(ACLK2), .PHI1(PHI1), .RES(RES), .LOCK(LOCK), .DFLOAD(DFLOAD), .DOUT(DOUT), .n_NOUT(n_NOUT), .n_DMCAB(n_DMCAB), .BLOAD(BLOAD), .BSTEP(BSTEP), .PCM(PCM), .DSTEP(DSTEP), .DMC1(DMC1), .CTRL1(CTRL1) );

endmodule // DPCMControl

module DPCM_IntControl(RES, W4015, n_R4015, n_IRQEN, AssertInt, DB, DMCINT);

	input RES;
	input W4015;
	input n_R4015;
	input n_IRQEN;
	input AssertInt;
	inout [7:0] DB;
	output DMCINT;

	wire int_ff_nq;

	rsff_2_4 int_ff (.res1(W4015), .res2(n_IRQEN), .res3(RES), .s(AssertInt), .nq(int_ff_nq) );
	bustris int_stat (.a(int_ff_nq), .n_x(DB[7]), .n_en(n_R4015) );
	nor (DMCINT, int_ff_nq, n_IRQEN);

endmodule // DPCMIntControl

module DPCM_EnableControl(ACLK1, RES, W4015, n_R4015, LOOPMode, PCMDone, SOUT, DB, ED1, DMC2, ED2);

	input ACLK1;
	input RES;
	input W4015;
	input n_R4015;
	input LOOPMode;
	input PCMDone;
	input SOUT;
	inout [7:0] DB;
	output ED1;
	output DMC2;
	output ED2;

	wire sout_latch_nq;
	wire ena_ff_nq;

	dlatch sout_latch (.d(SOUT), .en(ACLK1), .q(DMC2), .nq(sout_latch_nq) );
	RegisterBitRes2 ena_ff (.ACLK1(ACLK1), .ena(W4015), .d(DB[4]), .res1(ED1), .res2(RES), .q(ED2), .nq(ena_ff_nq) );
	nor (ED1, LOOPMode, sout_latch_nq, ~PCMDone);
	bustris ena_stat (.a(ena_ff_nq), .n_x(DB[4]), .n_en(n_R4015) );

endmodule // DPCMEnableControl

module DPCM_DMAControl(nACLK2, ACLK1, ACLK2, PHI1, RnW, RES, nDMAStop, nDMCEnableDelay, DMCRDY, RUNDMC, n_DMCAB);

	input nACLK2;
	input ACLK1;
	input ACLK2;
	input PHI1;
	input RnW;
	input RES;
	input nDMAStop;
	input nDMCEnableDelay;
	output DMCRDY;
	output RUNDMC;
	output n_DMCAB;

	wire DMAStart;
	wire run_latch1_q;
	wire run_latch1_nq;
	wire start_set;
	wire rdy_ff_nq;

	dlatch run_latch1 (.d(DMAStart), .en(ACLK2), .q(run_latch1_q), .nq(run_latch1_nq) );
	dlatch run_latch2 (.d(run_latch1_nq), .en(ACLK1), .nq(RUNDMC) );
	assign start_set = ~( ~(~PHI1 & RnW) | nDMCEnableDelay | ~nDMAStop );
	rsff_2_4 start_ff (.res1(nDMCEnableDelay), .res2(RES), .res3(~nDMAStop), .s(start_set), .q(DMAStart) );
	rsff rdy_ff (.r(run_latch1_q & ACLK1), .s(ACLK2), .q(n_DMCAB), .nq(rdy_ff_nq) );
	nor (DMCRDY, DMAStart, rdy_ff_nq);

endmodule // DPCM_DMAControl

module DPCM_SampleCounterControl(nACLK2, ACLK1, ACLK2, PCMDone, DMCFinish, DMCEnable, DFLOAD, DSLOAD, DSSTEP, NSTEP, CTRL2);

	input nACLK2;
	input ACLK1;
	input ACLK2;
	input PCMDone;
	input DMCFinish;
	input DMCEnable;
	input DFLOAD;
	output DSLOAD;
	output DSSTEP;
	output NSTEP;
	output CTRL2;

	wire DMC3;
	wire en_latch1_nq;
	wire en_latch2_nq;
	wire en_latch3_q;

	dlatch en_latch1 (.d(DMCEnable), .en(ACLK1), .nq(en_latch1_nq) );
	dlatch en_latch2 (.d(en_latch1_nq), .en(ACLK2), .nq(en_latch2_nq) );
	dlatch en_latch3 (.d(en_latch2_nq), .en(ACLK1), .q(en_latch3_q), .nq(CTRL2) );
	nor (DMC3, nACLK2, en_latch1_nq, en_latch3_q);

	assign NSTEP = ~(~DFLOAD);
	assign DSLOAD = ~(~((DMCFinish & PCMDone) | DMC3));
	assign DSSTEP = ~(~PCMDone | DMC3 | DMCFinish);

endmodule // DPCM_SampleCounterControl

module DPCM_SampleBufferControl(nACLK2, ACLK1, ACLK2, PHI1, RES, LOCK, DFLOAD, DOUT, n_NOUT, n_DMCAB, BLOAD, BSTEP, PCM, DSTEP, DMC1, CTRL1);

	input nACLK2;
	input ACLK1;
	input ACLK2;
	input PHI1;
	input RES;
	input LOCK;
	input DFLOAD;
	input DOUT;
	input n_NOUT;
	input n_DMCAB;
	output BLOAD;
	output BSTEP;
	output PCM;
	output DSTEP;
	output DMC1;
	output CTRL1;

	wire n_DFLOAD;
	wire step_ff_nq;
	wire stop_ff_q;
	wire pcm_ff_nq;
	wire dout_latch_q;
	wire dstep_latch_q;
	wire stop_latch_nq;
	wire pcm_latch_q;

	assign n_DFLOAD = ~DFLOAD;

	rsff_2_3 step_ff (.res1(~(~stop_latch_nq | n_DFLOAD | n_NOUT)), .res2(RES), .s(BLOAD), .nq(step_ff_nq) );
	rsff_2_3 stop_ff (.res1(BLOAD), .res2(RES), .s(PCM), .q(stop_ff_q), .nq(CTRL1) );
	rsff_2_3 pcm_ff (.res1(DMC1), .res2(RES), .s(PCM), .nq(pcm_ff_nq) );

	dlatch dout_latch (.d(DOUT), .en(ACLK1), .q(dout_latch_q) );
	dlatch dstep_latch (.d(step_ff_nq), .en(ACLK1), .q(dstep_latch_q) );
	dlatch stop_latch (.d(stop_ff_q), .en(ACLK1), .nq(stop_latch_nq) );
	dlatch pcm_latch (.d(pcm_ff_nq), .en(ACLK1), .q(pcm_latch_q) );

	nor (PCM, PHI1, n_DMCAB);
	nor (DMC1, pcm_latch_q, ~ACLK2);
	nor (DSTEP, dout_latch_q, dstep_latch_q, n_DFLOAD, LOCK);
	nor (BLOAD, stop_latch_nq, n_DFLOAD, n_NOUT);
	nor (BSTEP, n_DFLOAD, ~n_NOUT);

endmodule // DPCM_SampleBufferControl

module DPCM_Decoder (Fx, FR);

	input [3:0] Fx;
	output [8:0] FR;

	wire [15:0] Dec1_out;

	DPCM_Decoder1 dec1 (.Dec1_in(Fx), .Dec1_out(Dec1_out) );
	DPCM_Decoder2 dec2 (.Dec2_in(Dec1_out), .Dec2_out(FR) );

endmodule // DPCM_Decoder

module DPCM_Decoder1 (Dec1_in, Dec1_out);

	input [3:0] Dec1_in;
	output [15:0] Dec1_out;

	wire [3:0] F;
	wire [3:0] nF;

	assign F = Dec1_in;
	assign nF = ~Dec1_in;

	nor (Dec1_out[0], F[0], F[1], F[2], F[3]);
	nor (Dec1_out[1], nF[0], F[1], F[2], F[3]);
	nor (Dec1_out[2], F[0], nF[1], F[2], F[3]);
	nor (Dec1_out[3], nF[0], nF[1], F[2], F[3]);
	nor (Dec1_out[4], F[0], F[1], nF[2], F[3]);
	nor (Dec1_out[5], nF[0], F[1], nF[2], F[3]);
	nor (Dec1_out[6], F[0], nF[1], nF[2], F[3]);
	nor (Dec1_out[7], nF[0], nF[1], nF[2], F[3]);

	nor (Dec1_out[8], F[0], F[1], F[2], nF[3]);
	nor (Dec1_out[9], nF[0], F[1], F[2], nF[3]);
	nor (Dec1_out[10], F[0], nF[1], F[2], nF[3]);
	nor (Dec1_out[11], nF[0], nF[1], F[2], nF[3]);
	nor (Dec1_out[12], F[0], F[1], nF[2], nF[3]);
	nor (Dec1_out[13], nF[0], F[1], nF[2], nF[3]);
	nor (Dec1_out[14], F[0], nF[1], nF[2], nF[3]);
	nor (Dec1_out[15], nF[0], nF[1], nF[2], nF[3]);

endmodule // DPCM_Decoder1

module DPCM_Decoder2 (Dec2_in, Dec2_out);

	input [15:0] Dec2_in;
	output [8:0] Dec2_out;

	wire [15:0] d;
	assign d = Dec2_in;

	nor (Dec2_out[0], d[1], d[4], d[9], d[14], d[15]);
	nor (Dec2_out[1], d[6], d[7], d[8], d[9], d[10], d[11], d[12], d[13]);
	nor (Dec2_out[2], d[0], d[1], d[2], d[3], d[7], d[8], d[10], d[11], d[13]);
	nor (Dec2_out[3], d[0], d[2], d[7], d[10], d[15]);
	nor (Dec2_out[4], d[1], d[2], d[4], d[8], d[12], d[13], d[14]);
	nor (Dec2_out[5], d[1], d[2], d[3], d[7], d[8], d[9], d[12], d[13], d[14], d[15]);
	nor (Dec2_out[6], d[1], d[5], d[8], d[12], d[13], d[14]);
	nor (Dec2_out[7], d[0], d[2], d[5], d[6], d[8], d[15]);
	nor (Dec2_out[8], d[1], d[3], d[5], d[6], d[8], d[9], d[10], d[11], d[12]);

endmodule // DPCM_Decoder2

module DPCM_FreqLFSR (nACLK2, ACLK1, ACLK2, RES, FR, DFLOAD);

	input nACLK2;
	input ACLK1;
	input ACLK2;
	input RES;
	input [8:0] FR;
	output DFLOAD;

	wire feedback;
	wire DFSTEP;
	wire [8:0] sout;
	wire nor1_out;
	wire nor2_out;
	wire nor3_out;

	assign feedback = ~((sout[0] & sout[4]) | RES | ~(sout[0] | sout[4] | nor1_out));
	assign nor3_out = ~(RES | ~nor2_out);
	assign DFLOAD = ~(~ACLK2 | ~nor3_out);
	assign DFSTEP = ~(~ACLK2 | nor3_out);

	nor (nor1_out, sout[0], sout[1], sout[2], sout[3], sout[4], sout[5], sout[6], sout[7], sout[8]);
	nor (nor2_out, ~sout[0], sout[1], sout[2], sout[3], sout[4], sout[5], sout[6], sout[7], sout[8]);

	DPCM_LFSRBit lfsr [8:0] (.ACLK1(ACLK1), .load(DFLOAD), .step(DFSTEP), .val(FR), .sin({feedback,sout[8:1]}), .sout(sout) );

endmodule // DPCM_FreqLFSR

module DPCM_LFSRBit (ACLK1, load, step, val, sin, sout);

	input ACLK1;
	input load;
	input step;
	input val;
	input sin;
	output sout;

	wire d;
	wire in_latch_nq;

	assign d = load ? val : (step ? sin : 1'bz);

	dlatch in_latch (.d(d), .en(1'b1), .nq(in_latch_nq) );
	dlatch out_latch (.d(in_latch_nq), .en(ACLK1), .nq(sout) );

endmodule // DPCM_LFSRBit

module DPCM_SampleCounterReg (ACLK1, W4013, DB, DSC);

	input ACLK1;
	input W4013;
	inout [7:0] DB;
	output [7:0] DSC;

	RegisterBit scnt_reg [7:0] (.ACLK1(ACLK1), .ena(W4013), .d(DB[7:0]), .q(DSC[7:0]) );

endmodule // DPCM_SampleCounterReg

module DPCM_SampleCounter (ACLK1, RES, DSLOAD, DSSTEP, DSC, SOUT);

	input ACLK1;
	input RES;
	input DSLOAD;
	input DSSTEP;
	input [7:0] DSC;
	output SOUT;

	wire [11:0] cout;

	DownCounterBit cnt [11:0] (.ACLK1(ACLK1), .d({DSC[7:0],4'b0000}), .load(DSLOAD), .clear(RES), .step(DSSTEP), .cin({cout[10:0],1'b1}), .cout(cout) );

	assign SOUT = cout[11];

endmodule // DPCM_SampleCounter

module DPCM_SampleBitCounter (ACLK1, RES, NSTEP, n_NOUT);

	input ACLK1;
	input RES;
	input NSTEP;
	output n_NOUT;

	wire [2:0] cout;

	CounterBit cnt [2:0] (.ACLK1(ACLK1), .d(3'b000), .load(RES), .clear(RES), .step(NSTEP), .cin({cout[1:0],1'b1}), .cout(cout) );
	dlatch nout_latch (.d(cout[2]), .en(ACLK1), .nq(n_NOUT));

endmodule // DPCM_SampleBitCounter

module DPCM_SampleBuffer (ACLK1, RES, BLOAD, BSTEP, PCM, DB, n_BOUT);

	input ACLK1;
	input RES;
	input BLOAD;
	input BSTEP;
	input PCM;
	inout [7:0] DB;
	output n_BOUT;

	wire [7:0] buf_nq;
	wire [7:0] sout;

	RegisterBit buf_reg [7:0] (.ACLK1(ACLK1), .ena(PCM), .d(DB), .nq(buf_nq) );
	DPCM_SRBit shift_reg [7:0] (.ACLK1(ACLK1), .clear(RES), .load(BLOAD), .step(BSTEP), .n_val(buf_nq), .sin({1'b0,sout[7:1]}), .sout(sout) );

	assign n_BOUT = ~sout[0];

endmodule // DPCM_SampleBuffer

module DPCM_SRBit (ACLK1, clear, load, step, n_val, sin, sout);

	input ACLK1;
	input clear;
	input load;
	input step;
	input n_val;
	input sin;
	output sout;

	wire d;
	wire in_latch_nq;

	assign d = clear ? 1'b0 : (load ? n_val : (step ? in_latch_nq : (ACLK1 ? ~sout : 1'bz)));

	dlatch in_latch (.d(sin), .en(ACLK1), .nq(in_latch_nq) );
	dlatch out_latch (.d(d), .en(1'b1), .nq(sout) );

endmodule // DPCM_SRBit

module DPCM_AddressReg (ACLK1, W4012, DB, DPA);

	input ACLK1;
	input W4012;
	inout [7:0] DB;
	output [7:0] DPA;

	RegisterBit addr_reg [7:0] (.ACLK1(ACLK1), .ena(W4012), .d(DB[7:0]), .q(DPA[7:0]) );

endmodule // DPCM_AddressReg

module DPCM_AddressCounter (ACLK1, RES, DSLOAD, DSSTEP, DPA, DMC_Addr);

	input ACLK1;
	input RES;
	input DSLOAD;
	input DSSTEP;
	input [7:0] DPA;
	output [15:0] DMC_Addr;

	wire [7:0] addr_lo_cout;
	wire [6:0] addr_hi_cout;
	wire [7:0] addr_lo_q;
	wire [6:0] addr_hi_q;

	CounterBit addr_lo [7:0] (.ACLK1(ACLK1), .d({DPA[1:0], 6'b000000}), .load(DSLOAD), .clear(RES), .step(DSSTEP), .cin({addr_lo_cout[6:0],1'b1}), .q(addr_lo_q), .cout(addr_lo_cout));
	CounterBit addr_hi [6:0] (.ACLK1(ACLK1), .d({1'b1, DPA[7:2]}), .load(DSLOAD), .clear(RES), .step(DSSTEP), .cin({addr_hi_cout[5:0],addr_lo_cout[7]}), .q(addr_hi_q), .cout(addr_hi_cout) );

	assign DMC_Addr = {1'b1,addr_hi_q,addr_lo_q};

endmodule // DPCM_AddressCounter

module DPCM_Output (ACLK1, RES, W4011, CountDown, DSTEP, DB, DMC_Out, DOUT);

	input ACLK1;
	input RES;
	input W4011;
	input CountDown;
	input DSTEP;
	inout [7:0] DB;
	output [6:0] DMC_Out;
	output DOUT;

	wire out_reg_q;
	wire [5:0] out_cnt_q;
	wire [5:0] cout;

	RevCounterBit out_cnt [5:0] (.ACLK1(ACLK1), .d(DB[6:1]), .load(W4011), .clear(RES), .step(DSTEP), .cin({cout[4:0],1'b1}), .dec(CountDown), .q(out_cnt_q), .cout(cout) );
	RegisterBit out_reg (.ACLK1(ACLK1), .ena(W4011), .d(DB[0]), .q(out_reg_q) );

	assign DMC_Out = {out_cnt_q,out_reg_q};
	assign DOUT = cout[5];

endmodule // DPCM_Output
