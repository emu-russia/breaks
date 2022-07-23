// Asynchronous static latch used in old NMOS chips. Totally unprotected against jitter and other timing circuit problems.
// Use carefully and wisely.

module dlatch (d, en, q, nq);

	input d;		// Input value
	input en;		// 1: Allow write
	output q;		// Current value
	output nq; 		// Current value (inverted)

	(* keep = "true" *) wire floater;
	bufif1(floater, d, en);

	buf (q, floater);
	not (nq, floater);

endmodule // dlatch
