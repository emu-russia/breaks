// Go through all 6502 decoder values and output them to CSV.

`timescale 1ns/1ns

module Decoder_Run ();

	reg CLK;
	integer f;

	always #1 CLK = ~CLK;

	reg [13:0] Decoder_cnt; 		// The counter acts as an enumerator for all decoder inputs

	wire [129:0] Decoder_out;

	wire n_T0;
	wire n_T1X;
	wire n_T2;
	wire n_T3;
	wire n_T4;
	wire n_T5; 
	wire IR01;
	wire [7:0] IR;

	// Assign the decoder inputs.
	// The lower six bits represent the Tx. The remaining high bits are IR.

	assign n_T0 = ~Decoder_cnt[0];
	assign n_T1X = ~Decoder_cnt[1];
	assign n_T2 = ~Decoder_cnt[2];
	assign n_T3 = ~Decoder_cnt[3];
	assign n_T4 = ~Decoder_cnt[4];
	assign n_T5 = ~Decoder_cnt[5];
	assign IR = Decoder_cnt[13:6];
	assign IR01 = IR[0]|IR[1];

	Decoder dec (
		.n_T0(n_T0), .n_T1X(n_T1X),
		.n_T2(n_T2), .n_T3(n_T3), .n_T4(n_T4), .n_T5(n_T5), 
		.IR01(IR01),
		.IR(IR), .n_IR(~IR),
		.X(Decoder_out) );

	always @(posedge CLK) begin
		$fwrite (f, "%b,%b\n", Decoder_cnt, Decoder_out);
		Decoder_cnt = Decoder_cnt + 1;
	end

	initial begin

		$dumpfile("decoder_test.vcd");
		$dumpvars(0, Decoder_Run);

		f = $fopen("decoder_6502.csv","w");
		$fwrite(f, "inputs,outputs\n");

		Decoder_cnt <= 0;
		CLK <= 1'b0;

		repeat (1<<14) @ (posedge CLK);
		$fclose (f);
		$finish;
	end

endmodule // Decoder_Run
