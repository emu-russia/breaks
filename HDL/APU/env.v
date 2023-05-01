// Envelope Unit
// Shared between the square channels and the noise generator.

module Envelope_Unit (ACLK1, RES, WR_Reg, WR_LC, n_LFO1, DB, V, LC);

	input ACLK1;
	input RES;
	input WR_Reg;
	input WR_LC;
	input n_LFO1;
	inout [7:0] DB;
	output [3:0] V;
	output LC;

	// Internal wires

	wire RELOAD;
	wire RLOAD;
	wire RSTEP;
	wire RCO;
	wire ESTEP;
	wire ERES;
	wire EIN;
	wire ECO;
	wire [3:0] VOL;
	wire [3:0] ENV;
	wire ENVDIS;
	wire [3:0] decay_cnt_cout;
	wire [3:0] env_cnt_cout;
	wire EnvReload_q;
	wire erld_latch_q;
	wire reload_latch_q;
	wire rco_latch_q;
	wire rco_latch_nq;
	wire eco_latch_q;
	wire eco_reload;

	// Logic

	RegisterBit envdis_reg (.ACLK1(ACLK1), .ena(WR_Reg), .d(DB[4]), .q(ENVDIS) );
	RegisterBit lc_reg (.ACLK1(ACLK1), .ena(WR_Reg), .d(DB[5]), .nq(LC) );
	RegisterBit vol_reg [3:0] (.ACLK1(ACLK1), .ena(WR_Reg), .d(DB[3:0]), .q(VOL) );

	DownCounterBit decay_cnt [3:0] (.ACLK1(ACLK1), .d(VOL), .load(RLOAD), .clear(RES), .step(RSTEP), .cin({decay_cnt_cout[2:0],1'b1}), .cout(decay_cnt_cout) );
	DownCounterBit env_cnt [3:0] (.ACLK1(ACLK1), .d({4{EIN}}), .load(ERES), .clear(RES), .step(ESTEP), .q(ENV), .cin({env_cnt_cout[2:0],1'b1}), .cout(env_cnt_cout) );
	assign RCO = decay_cnt_cout[3];
	assign ECO = env_cnt_cout[3];

	rsff EnvReload (.r(WR_LC), .s(~(n_LFO1 | erld_latch_q)), .q(EnvReload_q), .nq(RELOAD) );

	dlatch erld_latch (.d(EnvReload_q), .en(ACLK1), .q(erld_latch_q) );
	dlatch reload_latch (.d(RELOAD), .en(ACLK1), .q(reload_latch_q) );
	dlatch rco_latch (.d(~(RCO | RELOAD)), .en(ACLK1), .q(rco_latch_q), .nq(rco_latch_nq) );
	dlatch eco_latch (.d(ECO & ~RELOAD), .en(ACLK1), .q(eco_latch_q) );

	nor (RLOAD, n_LFO1, rco_latch_q);
	nor (RSTEP, n_LFO1, rco_latch_nq);
	nand (EIN, eco_latch_q, LC);
	nor (eco_reload, eco_latch_q, reload_latch_q);
	nor (ESTEP, ~RLOAD, ~eco_reload);
	nor (ERES, ~RLOAD, eco_reload);

	assign V = ENVDIS ? VOL : ENV;

endmodule // Envelope_Unit
