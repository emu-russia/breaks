// With this test we are trying to get the Sweep Unit to generate the ADDOUT signal as it should be for the Sweep process to work.

// Here is an excerpt from our wiki describing the rather intricate logic of the Sweep Unit:

// By carefully examining and understanding all the signals that are used in the Sweep Unit you can get a picture of what is going on:
// - The main driver of the Sweep process is the ADDOUT signal. When this signal is activated the frequency modulation process in the Freq Reg is started using the shift register and the adder
// - The Sweep counter iterates with the low frequency oscillation signal `/LFO2`
// - The Sweep counter is overloaded by itself with the value from the Sweep Reg register, at the same time the ADDOUT signal is triggered (if all conditions are met, see below)

// Sweep does NOT occur under the following conditions (in the schematic it is a large NOR):
// - Sweep is disabled by the appropriate control register (SWDIS)
// - A square channel length counter has finished counting or has been disabled (NOSQ)
// - The magnitude value of the Shift Reg is 0 (SRZ)
// - Frequency value led to an overflow of the adder, in the frequency increase mode (SWCTRL)
// - Frequency value is less than 4 (SWEEP)
// - Sweep counter has not completed its work (SCO=0)
// - Low-frequency oscillation signal is not active (/LFO2=1)

// That is, we need to organize the artificial generation of /LFO2 signal (not too slow, as in real conditions, to speed up the process)
// and check that the ADDOUT signal is generated as it should be.

// For this test it does not matter what happens to the Freq Reg, shifter, adder and all other parts of the square wave generator.

// The simulation of LFO generation is artificially tweaked to trigger more frequently.

module Square_Sweep_Run ();

endmodule // Square_Sweep_Run
