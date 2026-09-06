`timescale 1ns/1ns
// Full-PPU test bench: enable rendering, load OAM, run a field.
module PPU_Render();
	reg CLK;
	reg RnW;
	reg [2:0] RS;
	reg n_DBE;
	reg [7:0] D_reg;
	reg n_RES;
	wire [7:0] D = n_DBE ? 8'bz : D_reg;
	wire [3:0] ext = 4'bz;

	always #23.28 CLK = ~CLK;

	PPU ppu (.RnW(RnW), .D(D), .RS(RS), .n_DBE(n_DBE), .EXT(ext), .CLK(CLK), .n_RES(n_RES));

	task cpu_write(input [2:0] addr, input [7:0] data);
		begin
			@(negedge CLK);
			RS = addr; RnW = 1'b0; n_DBE = 1'b0; D_reg = data;
			@(negedge CLK); @(negedge CLK);
			n_DBE = 1'b1;
		end
	endtask

	initial begin
		$dumpfile("ppu_render.vcd");
		$dumpvars(0, PPU_Render);
		CLK = 0; RnW = 1; RS = 0; n_DBE = 1; D_reg = 0; n_RES = 1'b0;
		#3000;               // reset
		n_RES = 1'b1;
		#3000;

		cpu_write(3'd1, 8'h1E);   // $2001: BG + sprites on
		cpu_write(3'd0, 8'h00);   // $2000
		cpu_write(3'd3, 8'h00);   // $2003: OAM addr = 0
		begin : oam_load
			integer i;
			for (i = 0; i < 64; i = i + 1) begin
				cpu_write(3'd4, 8'h20 + (i[5:0])); // Y
				cpu_write(3'd4, 8'h00);            // tile
				cpu_write(3'd4, 8'h00);            // attr
				cpu_write(3'd4, 8'h10 + (i*4));    // X
			end
		end

		repeat (2048 * 3) @(posedge CLK);
		$finish;
	end
endmodule
