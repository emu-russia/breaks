// PAR (Picture Address Register) self-check.
// Reference: BreakingNESWiki/PPU/par.md (bit role table) + dataread.md and
// the way the FSM drives the fetches (fsm.v): on the "load" window (an NT
// fetch, signalled by H0_DD with n_FNT=0) PAR captures the byte that the
// next pattern fetch must address, holding it until the next window.
//   PAddr_out[13]   = 0                      (pattern data in $0000-$1FFF)
//   PAddr_out[12]   = table select: ~BGSEL for BG, ~OBSEL for 8x8 sprites,
//                     OAM tile byte bit 0 for 8x16 sprites  (ParControl PAD12)
//   PAddr_out[11:5] = tile index bits 7..1: BG from the name-table byte
//                     (PD), sprites from the OAM tile byte (OB)
//   PAddr_out[4]    = tile index bit 0 (BG: PD[0]; 8x8: OB[0]);
//                     8x16: inverted OV[3] (upper/lower 8-row half)
//   PAddr_out[3]    = ~n_H1D  (A/B low/high pattern byte select)
//   PAddr_out[2:0]  = pattern row: BG from the fine-V bus (n_FVO);
//                     sprites from OV[2:0], inverted when the sprite's
//                     vertical-flip attribute (OB[7], latched by
//                     V_Inversion during the attribute read) is set
// The cells' outputs are complemented (dynamic NMOS), so the polarity
// above is per the module pins (PAMUX re-inverts when driving /PA).

`timescale 1ns/1ns

module par_test ();

	reg PCLK = 1'b0;
	wire n_PCLK = ~PCLK;
	always #10 PCLK = ~PCLK;

	reg H0_DD;
	reg n_FNT;
	reg BGSEL;
	reg OBSEL;
	reg O8_16;
	reg OBJ_READ;
	reg n_OBJ_RD_ATTR;
	reg n_H1D;
	reg [3:0] OV;
	reg [2:0] n_FVO;
	reg [7:0] OB;
	reg [7:0] PD;
	wire [13:0] PAddr;

	PAR uut (
		.n_PCLK(n_PCLK), .H0_DD(H0_DD), .n_FNT(n_FNT), .BGSEL(BGSEL),
		.OBSEL(OBSEL), .O8_16(O8_16), .OBJ_READ(OBJ_READ),
		.n_OBJ_RD_ATTR(n_OBJ_RD_ATTR), .n_H1D(n_H1D),
		.OV(OV), .n_FVO(n_FVO), .OB(OB), .PD(PD), .PAddr_out(PAddr) );

	integer errors = 0;
	integer checks = 0;

	// assert an NT-fetch load window (O pulses) then release
	task load_window();
		begin
			H0_DD = 1'b1; n_FNT = 1'b0;
			repeat (3) #10;
			H0_DD = 1'b0; n_FNT = 1'b1;
			#15;
		end
	endtask

	// latch OB[7] as the sprite vertical-flip flag (attribute read)
	task load_flip(input f);
		begin
			OB[7] = f;
			n_OBJ_RD_ATTR = 1'b0;
			// wait until n_PCLK is high so the read window (n_PCLK=0) sees OB[7]
			repeat (3) #10;
			n_OBJ_RD_ATTR = 1'b1;
			#5;
		end
	endtask

	task chk(input [159:0] what, input [13:0] exp);
		begin
			checks = checks + 1;
			if (PAddr !== exp) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL: %s exp=%h got=%h", what, exp, PAddr);
			end
		end
	endtask

	initial begin
		$dumpfile("par_test.vcd");
		$dumpvars(0, par_test);

		H0_DD = 0; n_FNT = 1; BGSEL = 0; OBSEL = 0; O8_16 = 0; OBJ_READ = 0;
		n_OBJ_RD_ATTR = 1; n_H1D = 1; OV = 4'b0000; n_FVO = 3'b000;
		OB = 8'h00; PD = 8'h00;
		repeat (3) #10;

		// ---------- background fetches ----------
		// n_FVO is the (active-low) fine-V bus: PAddr[2:0] = ~n_FVO.
		// table=1 (PAD12 = ~BGSEL -> bit12=0), tile=0x55, /H1 high (bit3=0),
		// fine-Y row 3 -> n_FVO=~3=100
		BGSEL = 1; PD = 8'h55; n_H1D = 1; n_FVO = 3'b100;
		load_window();
		chk("BG: tbl1 NT=55 /H1 high row3", {1'b0, ~BGSEL, PD[7:0], ~n_H1D, ~n_FVO});
		// tile = 0x3C, /H1 low (bit3=1), fine-Y row 5 -> n_FVO=010
		PD = 8'h3C; n_H1D = 0; n_FVO = 3'b010;
		load_window();
		chk("BG: NT=3C /H1 low row5", {1'b0, ~BGSEL, PD[7:0], ~n_H1D, ~n_FVO});
		// table=0
		BGSEL = 0;
		load_window();
		chk("BG: table0", {1'b0, ~BGSEL, PD[7:0], ~n_H1D, ~n_FVO});

		// ---------- 8x8 sprite fetches ----------
		// tile from OB (direct), PAD12=~OBSEL, row = OV[2:0] (or ~OV[2:0]
		// when vertically flipped)
		OBJ_READ = 1; OBSEL = 1; OB = 8'h3C; OV = 4'b0101; BGSEL = 0;
		n_H1D = 0; n_OBJ_RD_ATTR = 1;
		load_window();
		chk("SPR8x8: obs1 OB=3C row5", {1'b0, ~OBSEL, OB[7:0], ~n_H1D, OV[2:0]});
		// vertical flip set: OB[7]=1 latched; row becomes ~OV[2:0] = 2
		load_flip(1'b1);
		load_window();
		chk("SPR8x8 flipped row ~5", {1'b0, ~OBSEL, OB[7:0], ~n_H1D, ~OV[2:0]});
		// flip cleared again
		load_flip(1'b0);
		load_window();
		chk("SPR8x8 flip cleared", {1'b0, ~OBSEL, OB[7:0], ~n_H1D, OV[2:0]});
		// OBSEL=0
		OBSEL = 0;
		load_window();
		chk("SPR8x8 obs0", {1'b0, ~OBSEL, OB[7:0], ~n_H1D, OV[2:0]});

		// ---------- 8x16 sprite fetches ----------
		// PAD12 comes from the OAM tile byte bit 0; PA4 = ~OV[3] selects the
		// lower/upper 8-row half of the 16-row pattern
		OBSEL = 0; O8_16 = 1; OB = 8'h21; OV = 4'b0011;  // OB0=1 -> bit12=1; OV3=0 -> bit4=1
		n_H1D = 1;
		load_window();
		chk("SPR8x16 lower half OB0=1", {1'b0, OB[0], OB[7:1], ~OV[3], ~n_H1D, OV[2:0]});
		OB = 8'h20; OV = 4'b1011;  // OB0=0 -> bit12=0; OV3=1 -> bit4=0
		load_window();
		chk("SPR8x16 upper half OB0=0", {1'b0, OB[0], OB[7:1], ~OV[3], ~n_H1D, OV[2:0]});

		if (errors == 0)
			$display("par_test: TEST PASS (%0d checks)", checks);
		else
			$display("par_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // par_test
