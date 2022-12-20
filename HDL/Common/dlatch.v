// Asynchronous dynamic (d=dynamic) latch used in old NMOS chips. Totally unprotected against jitter and other timing circuit problems.
// Use carefully and wisely.

module dlatch (d, en, q, nq);

	input d;		// Input value
	input en;		// 1: Allow write
	output q;		// Current value
	output nq; 		// Current value (complement)

`ifdef ICARUS

	reg dout; 
	always @(d or en) begin
		if (en == 1'b1 && (d == 1'b0 || d == 1'b1))
			dout <= d;   // Use non-blocking
	end

	assign q = dout;
	assign nq = ~dout;

	initial dout <= 1'b0;

`elsif QUARTUS

	LATCH MyLatch (.d(d), .ena(en), .q(q), .nq(nq));

`else

	(* keep = "true" *) wire floater;
	bufif1(floater, d, en);

	buf (q, floater);
	not (nq, floater);

`endif

endmodule // dlatch
