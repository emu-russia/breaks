// Decoder self-check.
// The decoder is a pure combinational NOR array: X[i] = ~|{d[a],d[b],...},
// i.e. X[i] = 1 exactly when every selected bit of the 21-bit input word d is 0.
// The masks below are taken from decoder.v. The test sweeps all 2^14
// (IR x cycle) combinations, checks all 130 outputs against the formula and
// makes sure no output is ever x/z.
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module decoder_test ();

	reg CLK;
	always #1 CLK = ~CLK;

	reg [13:0] Decoder_cnt;

	wire [129:0] Decoder_out;
	wire n_T0, n_T1X, n_T2, n_T3, n_T4, n_T5;
	wire IR01;
	wire [7:0] IR;

	assign n_T0  = ~Decoder_cnt[0];
	assign n_T1X = ~Decoder_cnt[1];
	assign n_T2  = ~Decoder_cnt[2];
	assign n_T3  = ~Decoder_cnt[3];
	assign n_T4  = ~Decoder_cnt[4];
	assign n_T5  = ~Decoder_cnt[5];
	assign IR    = Decoder_cnt[13:6];
	assign IR01  = IR[0] | IR[1];

	Decoder dec (
		.n_T0(n_T0), .n_T1X(n_T1X),
		.n_T2(n_T2), .n_T3(n_T3), .n_T4(n_T4), .n_T5(n_T5),
		.IR01(IR01),
		.IR(IR), .n_IR(~IR),
		.X(Decoder_out) );

	// formula masks (bit b of the mask selects d[b]; d layout as in decoder.v)
	reg [20:0] Xmask [0:129];
	reg [20:0] d;
	integer errors = 0;
	integer tests  = 0;
	integer cnt, i;
	reg ok;

	initial begin
		$dumpfile("decoder_test.vcd");
		$dumpvars(0, decoder_test);
		Decoder_cnt <= 0;

		Xmask[0] = 21'h2c120;
		Xmask[1] = 21'h2c44;
		Xmask[2] = 21'h3448;
		Xmask[3] = 21'ha3320;
		Xmask[4] = 21'hab520;
		Xmask[5] = 21'hb0320;
		Xmask[6] = 21'h4408;
		Xmask[7] = 21'h8110;
		Xmask[8] = 21'h2a48;
		Xmask[9] = 21'hab310;
		Xmask[10] = 21'hb3310;
		Xmask[11] = 21'hd0320;
		Xmask[12] = 21'h28110;
		Xmask[13] = 21'hab510;
		Xmask[14] = 21'hc8110;
		Xmask[15] = 21'h133310;
		Xmask[16] = 21'h153320;
		Xmask[17] = 21'hcb510;
		Xmask[18] = 21'h123320;
		Xmask[19] = 21'hcc120;
		Xmask[20] = 21'hc8320;
		Xmask[21] = 21'hcaaa0;
		Xmask[22] = 21'h2aaa1;
		Xmask[23] = 21'ha32a0;
		Xmask[24] = 21'h52aa2;
		Xmask[25] = 21'h432a4;
		Xmask[26] = 21'h32aa1;
		Xmask[27] = 21'h50090;
		Xmask[28] = 21'h8;
		Xmask[29] = 21'hb00c0;
		Xmask[30] = 21'h152a0;
		Xmask[31] = 21'h5208;
		Xmask[32] = 21'ha80c0;
		Xmask[33] = 21'h808;
		Xmask[34] = 21'h80000;
		Xmask[35] = 21'h22a8;
		Xmask[36] = 21'h2a4;
		Xmask[37] = 21'haaa2;
		Xmask[38] = 21'h32aa2;
		Xmask[39] = 21'h2a44;
		Xmask[40] = 21'h2c42;
		Xmask[41] = 21'h2c48;
		Xmask[42] = 21'h1404;
		Xmask[43] = 21'h432a0;
		Xmask[44] = 21'h50110;
		Xmask[45] = 21'h2a42;
		Xmask[46] = 21'h2c44;
		Xmask[47] = 21'h12aa0;
		Xmask[48] = 21'h4aaa8;
		Xmask[49] = 21'h90320;
		Xmask[50] = 21'hb0140;
		Xmask[51] = 21'hd0140;
		Xmask[52] = 21'hd0040;
		Xmask[53] = 21'h48090;
		Xmask[54] = 21'h152a4;
		Xmask[55] = 21'h8090;
		Xmask[56] = 21'h4aaa1;
		Xmask[57] = 21'h22a8;
		Xmask[58] = 21'hab520;
		Xmask[59] = 21'h1000c0;
		Xmask[60] = 21'h150040;
		Xmask[61] = 21'h103290;
		Xmask[62] = 21'hab310;
		Xmask[63] = 21'hd32a0;
		Xmask[64] = 21'hc8140;
		Xmask[65] = 21'h80040;
		Xmask[66] = 21'hcb320;
		Xmask[67] = 21'h83290;
		Xmask[68] = 21'hcb310;
		Xmask[69] = 21'hcc2a0;
		Xmask[70] = 21'hc80c0;
		Xmask[71] = 21'h1402;
		Xmask[72] = 21'h2c41;
		Xmask[73] = 21'h82c20;
		Xmask[74] = 21'h332a8;
		Xmask[75] = 21'h93290;
		Xmask[76] = 21'h10090;
		Xmask[77] = 21'h2aaa8;
		Xmask[78] = 21'h4aaa4;
		Xmask[79] = 21'h28140;
		Xmask[80] = 21'h2c28;
		Xmask[81] = 21'h4808;
		Xmask[82] = 21'h2848;
		Xmask[83] = 21'h1008;
		Xmask[84] = 21'h52aa1;
		Xmask[85] = 21'h2;
		Xmask[86] = 21'h4;
		Xmask[87] = 21'ha2aa0;
		Xmask[88] = 21'h952a0;
		Xmask[89] = 21'h2a41;
		Xmask[90] = 21'h1004;
		Xmask[91] = 21'h2c42;
		Xmask[92] = 21'h1404;
		Xmask[93] = 21'h2c24;
		Xmask[94] = 21'h22aa0;
		Xmask[95] = 21'h4aaa0;
		Xmask[96] = 21'h152a0;
		Xmask[97] = 21'h28100;
		Xmask[98] = 21'h2aaa2;
		Xmask[99] = 21'h2b2a8;
		Xmask[100] = 21'h232a8;
		Xmask[101] = 21'h152a2;
		Xmask[102] = 21'h12aa1;
		Xmask[103] = 21'h4aaa1;
		Xmask[104] = 21'h352a8;
		Xmask[105] = 21'h432a4;
		Xmask[106] = 21'h10010;
		Xmask[107] = 21'h8090;
		Xmask[108] = 21'h934a0;
		Xmask[109] = 21'h14c2a0;
		Xmask[110] = 21'h8b4a0;
		Xmask[111] = 21'h4c04;
		Xmask[112] = 21'h150040;
		Xmask[113] = 21'hcc2a0;
		Xmask[114] = 21'hcb2a0;
		Xmask[115] = 21'h32aa2;
		Xmask[116] = 21'h130140;
		Xmask[117] = 21'h115320;
		Xmask[118] = 21'h10b290;
		Xmask[119] = 21'h110b20;
		Xmask[120] = 21'h93520;
		Xmask[121] = 21'h8000;
		Xmask[122] = 21'h5204;
		Xmask[123] = 21'h4a08;
		Xmask[124] = 21'h2841;
		Xmask[125] = 21'h1402;
		Xmask[126] = 21'h80;
		Xmask[127] = 21'h4b520;
		Xmask[128] = 21'h3000;
		Xmask[129] = 21'h32a0;

		// sweep all inputs
		for (cnt = 0; cnt < (1 << 14); cnt = cnt + 1) begin
			Decoder_cnt = cnt[13:0];
			#1;
			d = {~Decoder_cnt[1], ~Decoder_cnt[0], ~IR[5], IR[5], ~IR[6], IR[6],
			      ~IR[2], IR[2], ~IR[3], IR[3], ~IR[4], IR[4], ~IR[7], IR[7],
			      ~IR[0], IR01, ~IR[1], ~Decoder_cnt[2], ~Decoder_cnt[3],
			      ~Decoder_cnt[4], ~Decoder_cnt[5]};
			ok = 1;
			for (i = 0; i < 130; i = i + 1) begin
				if (Decoder_out[i] === 1'bx || Decoder_out[i] === 1'bz) ok = 0;
				else if (Decoder_out[i] !== ((d & Xmask[i]) == 0)) ok = 0;
			end
			tests = tests + 1;
			if (!ok) begin
				$display("FAIL cnt=%04x d=%05x", cnt, d);
				for (i = 0; i < 130; i = i + 1)
					if (Decoder_out[i] !== ((d & Xmask[i]) == 0))
						$display("  X[%0d]=%b expected %b", i, Decoder_out[i], (d & Xmask[i]) == 0);
				errors = errors + 1;
				if (errors > 3) i = 130;
			end
		end

		if (errors == 0)
			$display("decoder_test: TEST PASS (%0d checks)", tests);
		else
			$display("decoder_test: TEST FAIL (%0d of %0d)", errors, tests);
		$finish;
	end

endmodule // decoder_test
