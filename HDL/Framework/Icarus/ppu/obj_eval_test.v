// ObjEval (sprite evaluation) self-check against NES sprite semantics.
// Reference: BreakingNESWiki/PPU/obj_eval.md and oam.md: during the
// evaluation window of a visible scanline the PPU walks the 64 OAM sprites
// (4 bytes each) and copies the up to 8 sprites whose Y range (8 or 16 rows,
// O8_16) contains the current scanline V into the secondary (temp) OAM; the
// 9th on-line sprite sets SPR_OV ($2002[5]) and stops the evaluation;
// sprite 0 on the line drives n_SPR0_EV low.
//
// The bench models the OAM around ObjEval exactly like the die/OAM block:
//   * main OAM 256 bytes (64 sprites x 4), temp (secondary) OAM 32 bytes;
//   * the data bus OB mirrors the cell being addressed (OAM8=0: main OAM,
//     OAM8=1: temp area), so the module input OB always matches the address
//     it presented on the previous dot (1-dot OAM buffer latency);
//   * when OAMCTR2=1 (temp write-back dot) the OAM copies the OB buffer
//     value of the previous read into the addressed temp cell.
// After the evaluation, the test reads the temp OAM and checks that exactly
// the expected sprites, in OAM order, were copied.
// Compile with -D RP2C02 -D ICARUS (NTSC).

`timescale 1ns/1ns

module obj_eval_test ();

	reg PCLK = 0;
	reg n_PCLK = 1;
	always #50 PCLK = ~PCLK;
	always #50 n_PCLK = ~n_PCLK;

	reg S_EV = 0, I_OAM2 = 0, n_EVAL = 1, OBJ_READ = 0, RESCL = 0;
	reg n_R2 = 1, n_DBE = 1;
	reg O8_16 = 0;
	reg n_FNT = 1, BLNK = 0, n_VIS = 1;
	reg H0_DD = 0, H0_D = 0, n_H2_D = 1;
	reg OFETCH = 0, n_W3 = 1;
	reg [7:0] V = 0;
	wire [7:0] OB;
	wire [7:0] n_OAM;
	wire OAM8, OAMCTR2, SPR_OV, DB5, n_SPR0_EV, PD_FIFO;
	wire [7:0] OV;

	ObjEval uut (
		.DB5(DB5), .n_OAM(n_OAM), .OAM8(OAM8), .OAMCTR2(OAMCTR2),
		.SPR_OV(SPR_OV), .OV(OV), .PD_FIFO(PD_FIFO), .n_SPR0_EV(n_SPR0_EV),
		.n_FNT(n_FNT), .S_EV(S_EV), .n_PCLK(n_PCLK), .BLNK(BLNK),
		.I_OAM2(I_OAM2), .n_VIS(n_VIS), .OBJ_READ(OBJ_READ), .n_EVAL(n_EVAL),
		.RESCL(RESCL), .H0_DD(H0_DD), .H0_D(H0_D), .n_H2_D(n_H2_D),
		.OFETCH(OFETCH), .n_W3(n_W3), .n_DBE(n_DBE), .PCLK(PCLK),
		.n_R2(n_R2), .CPU_DB(8'd0), .OB(OB), .V(V), .O8_16(O8_16) );

	// ------------------------------------------------------------------
	// OAM model
	// ------------------------------------------------------------------
	reg [7:0] main_oam [0:255];
	reg [7:0] temp_oam [0:31];
	reg [7:0] ob_latch = 8'd0;
	integer i;

	wire [7:0] addr = ~n_OAM;

	// OB mirrors the addressed cell: main OAM unless OAM8 selects the temp
	// area.  For write-back dots the value is irrelevant to the module.
	assign OB = OAM8 ? temp_oam[addr[4:0]] : main_oam[addr];

	// OAM buffer: latch the read value; on a temp write-back dot (OAMCTR2)
	// copy the value read one dot earlier into the addressed temp cell.
	always @(posedge PCLK) begin
		ob_latch <= OB;
		if (OAM8 && OAMCTR2)
			temp_oam[addr[4:0]] <= ob_latch;
	end

	initial for (i = 0; i < 256; i = i + 1) main_oam[i] = 8'hFF;  // far off
	initial for (i = 0; i < 32;  i = i + 1) temp_oam[i]  = 8'h00;

	// ------------------------------------------------------------------
	integer errors = 0;
	integer checks = 0;

	task check_val(input [159:0] what, input [7:0] got, input [7:0] exp);
		begin
			checks = checks + 1;
			if (got !== exp) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL: %0s got=%02x exp=%02x", what, got, exp);
			end
		end
	endtask

	task check_bit(input [159:0] what, input got, input exp);
		begin
			checks = checks + 1;
			if (got !== exp) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL: %0s got=%b exp=%b", what, got, exp);
			end
		end
	endtask

	// one dot
	task dot;
		begin
			@(posedge PCLK);
			#3;
		end
	endtask

	integer guards;

	// clear the whole main OAM (everything off the line)
	task clear_oam;
		integer ci;
		begin
			for (ci = 0; ci < 256; ci = ci + 1) main_oam[ci] = 8'hFF;
		end
	endtask

	// write one sprite into the (test) main OAM
	task oam_sprite(input [5:0] idx, input [7:0] y, tile, attr, x);
		begin
			main_oam[{2'b00, idx, 2'b00} + 8'd0] = y;
			main_oam[{2'b00, idx, 2'b00} + 8'd1] = tile;
			main_oam[{2'b00, idx, 2'b00} + 8'd2] = attr;
			main_oam[{2'b00, idx, 2'b00} + 8'd3] = x;
		end
	endtask

	// run a full evaluation pass for scanline v: I_OAM2, S_EV, n_EVAL low
	// for `run` dots, then the window ends (n_EVAL high)
	task eval_line(input [7:0] v, input integer run);
		integer k;
		begin
			V = v;
			n_EVAL = 1;
			OBJ_READ = 0;
			I_OAM2 = 1; dot(); I_OAM2 = 0; dot(); dot();
			S_EV = 1; dot(); S_EV = 0;
			n_EVAL = 0;
			for (k = 0; k < run; k = k + 1) dot();
			n_EVAL = 1;
			dot();          // end-of-eval edge -> fetch phase arms
		end
	endtask

	// read $2002 bit5 (DB5)
	task rd_2002(input [159:0] what, input exp);
		begin
			n_R2 = 1'b0; n_DBE = 1'b0;
			#2;
			check_bit(what, DB5, exp);
			n_R2 = 1'b1; n_DBE = 1'b1;
		end
	endtask

	// ------------------------------------------------------------------
	initial begin
		$dumpfile("obj_eval_test.vcd");
		$dumpvars(0, obj_eval_test);

		// ---- 0. idle state ------------------------------------------------
		I_OAM2 = 1; dot(); I_OAM2 = 0; dot(); dot();   // defined idle state
		check_bit("idle n_SPR0_EV=1", n_SPR0_EV, 1'b1);
		check_bit("idle SPR_OV=0", SPR_OV, 1'b0);
		check_bit("idle OAM8=0", OAM8, 1'b0);
		check_bit("idle OAMCTR2=0", OAMCTR2, 1'b0);
		check_bit("idle PD_FIFO=0", PD_FIFO, 1'b0);
		check_val("idle n_OAM", n_OAM, 8'hFF);
		rd_2002("idle $2002[5]=0", 1'b0);
		// DB5 tri-state when not reading $2002
		n_R2 = 1'b1; n_DBE = 1'b0; #2;
		checks = checks + 1;
		if (DB5 !== 1'bz) begin
			errors = errors + 1;
			$display("FAIL: DB5 not z when n_R2=1 (got %b)", DB5);
		end
		n_DBE = 1'b1;

		// ---- 1. selection: sprites 3,5,7 on line V=100 --------------------
		clear_oam();
		oam_sprite(6'd3, 8'd96,  8'h11, 8'h00, 8'd10);
		oam_sprite(6'd5, 8'd100, 8'h22, 8'h01, 8'd20);
		oam_sprite(6'd7, 8'd97,  8'h33, 8'h02, 8'd30);
		// boundary cases: Y=92 -> rows 92..99 (off), Y=93 -> rows 93..100 (on)
		oam_sprite(6'd10, 8'd92, 8'h44, 8'h00, 8'd40);
		oam_sprite(6'd11, 8'd93, 8'h55, 8'h00, 8'd50);
		eval_line(8'd100, 220);

		// temp OAM: slot0 = sprite 3, slot1 = sprite 5, slot2 = sprite 7,
		// slot3 = sprite 11 (Y=93)
		check_val("slot0 Y", temp_oam[4'd0], 8'd96);
		check_val("slot0 tile", temp_oam[4'd1], 8'h11);
		check_val("slot0 attr", temp_oam[4'd2], 8'h00);
		check_val("slot0 X", temp_oam[4'd3], 8'd10);
		check_val("slot1 Y", temp_oam[4'd4], 8'd100);
		check_val("slot1 tile", temp_oam[4'd5], 8'h22);
		check_val("slot1 attr", temp_oam[4'd6], 8'h01);
		check_val("slot1 X", temp_oam[4'd7], 8'd20);
		check_val("slot2 Y", temp_oam[4'd8], 8'd97);
		check_val("slot2 X", temp_oam[4'd11], 8'd30);
		check_val("slot3 Y", temp_oam[4'd12], 8'd93);
		check_bit("sprite 0 not on line", n_SPR0_EV, 1'b1);
		check_bit("no overflow", SPR_OV, 1'b0);
		rd_2002("no overflow $2002[5]=0", 1'b0);

		// fetch window: PD_FIFO for 4 real sprites (16 bytes), OV = V-Y.
		// The end-of-eval edge inside eval_line already armed the fetch;
		// raise OBJ_READ to clock the fetch bytes out.
		OBJ_READ = 1;
		guards = 0;
		while (uut.in_fetch !== 1'b1 && guards < 100) begin
			dot(); guards = guards + 1;
		end
		guards = 0;
		while (uut.fetch_ptr !== 5'd0 && guards < 100) begin
			dot(); guards = guards + 1;
		end
		#1;
		check_bit("fetch PD_FIFO on slot0", PD_FIFO, 1'b1);
		check_val("fetch OV slot0", OV, 8'd4);      // 100-96
		guards = 0;
		while (uut.fetch_ptr !== 5'd4 && guards < 60) begin
			dot(); guards = guards + 1;
		end
		#1;
		check_val("fetch OV slot1", OV, 8'd0);      // 100-100
		guards = 0;
		while (uut.fetch_ptr !== 5'd12 && guards < 60) begin
			dot(); guards = guards + 1;
		end
		#1;
		check_val("fetch OV slot3", OV, 8'd7);      // 100-93
		guards = 0;
		while (uut.fetch_ptr !== 5'd16 && guards < 60) begin
			dot(); guards = guards + 1;
		end
		#1;
		check_bit("fetch PD_FIFO past slots", PD_FIFO, 1'b0);
		OBJ_READ = 0;
		dot();

		// ---- 2. sprite 0 on the line drives n_SPR0_EV low -----------------
		clear_oam();
		oam_sprite(6'd0, 8'd99, 8'hAA, 8'h00, 8'd5);
		eval_line(8'd100, 220);
		OBJ_READ = 0; dot();
		check_bit("sprite 0 found", n_SPR0_EV, 1'b0);
		check_val("sprite0 temp Y", temp_oam[4'd0], 8'd99);

		// next line: I_OAM2 resets n_SPR0_EV
		I_OAM2 = 1; dot(); I_OAM2 = 0;
		check_bit("I_OAM2 resets spr0 flag", n_SPR0_EV, 1'b1);
		OBJ_READ = 0; n_EVAL = 1;

		// ---- 3. overflow with 9 sprites on the line ------------------------
		// sprites 1..9 all on line V=100; sprite 0 off
		clear_oam();
		oam_sprite(6'd0, 8'd0, 8'h00, 8'h00, 8'd0);
		for (i = 1; i <= 9; i = i + 1)
			oam_sprite(i[5:0], 8'd100, 8'h00 + i[7:0], 8'h00, 8'd0);
		eval_line(8'd100, 150);
		OBJ_READ = 0; dot();
		check_bit("overflow SPR_OV", SPR_OV, 1'b1);
		rd_2002("overflow $2002[5]=1", 1'b1);
		// exactly the first 8 sprites (1..8) were copied
		check_val("ovf slot7 Y", temp_oam[5'd28], 8'd100);
		check_val("ovf slot7 tile", temp_oam[5'd29], 8'd8);
		// 9th sprite (tile 9) must not be copied anywhere
		begin : no_9th
			integer j;
			for (j = 0; j < 8; j = j + 1) begin
				if (temp_oam[4*j + 1] === 8'd9) begin
					errors = errors + 1;
					$display("FAIL: 9th sprite leaked into slot %0d", j);
				end
			end
			checks = checks + 1;
		end

		// RESCL clears the sticky $2002[5] flag, SPR_OV stays until I_OAM2
		RESCL = 1; dot(); RESCL = 0;
		rd_2002("RESCL clears $2002[5]", 1'b0);
		check_bit("live SPR_OV holds until I_OAM2", SPR_OV, 1'b1);
		I_OAM2 = 1; dot(); I_OAM2 = 0;
		check_bit("I_OAM2 clears SPR_OV", SPR_OV, 1'b0);
		n_EVAL = 1;

		// ---- 4. 8x16 sprites: range is 16 rows ----------------------------
		clear_oam();
		oam_sprite(6'd2, 8'd90, 8'h10, 8'h00, 8'd0);   // rows 90..105 -> on
		oam_sprite(6'd3, 8'd100, 8'h20, 8'h00, 8'd0);  // rows 100..115 -> on
		oam_sprite(6'd4, 8'd106, 8'h30, 8'h00, 8'd0);  // rows 106..121 -> off
		O8_16 = 1;
		eval_line(8'd100, 220);
		OBJ_READ = 0; dot();
		check_val("8x16 slot0 Y", temp_oam[4'd0], 8'd90);
		check_val("8x16 slot0 tile", temp_oam[4'd1], 8'h10);
		check_val("8x16 slot1 Y", temp_oam[4'd4], 8'd100);
		check_val("8x16 slot1 tile", temp_oam[4'd5], 8'h20);
		// Y=106 + 16 rows would need V in 106..121: not on V=100 -> no slot
		O8_16 = 0;
		n_EVAL = 1;
		I_OAM2 = 1; dot(); I_OAM2 = 0;
		eval_line(8'd100, 220);       // 8x8 mode: same sprites -> 90..97 & 100..107 both on
		OBJ_READ = 0; dot();
		// 8x8 rows for sprite 2 (Y=90 -> 90..97) and sprite 4 (Y=106 ->
		// 106..113) do not cover V=100; only sprite 3 (Y=100) is copied
		check_val("8x8 slot0 Y", temp_oam[4'd0], 8'd100);
		check_val("8x8 slot0 tile", temp_oam[4'd1], 8'h20);
		begin : no_off8
			integer j2;
			checks = checks + 1;
			for (j2 = 0; j2 < 8; j2 = j2 + 1)
				if (temp_oam[4*j2 + 1] === 8'h10 || temp_oam[4*j2 + 1] === 8'h30) begin
					errors = errors + 1;
					$display("FAIL: off-line 8x8 sprite leaked into slot %0d", j2);
				end
		end

		if (errors == 0)
			$display("obj_eval_test: TEST PASS (%0d checks)", checks);
		else
			$display("obj_eval_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // obj_eval_test
