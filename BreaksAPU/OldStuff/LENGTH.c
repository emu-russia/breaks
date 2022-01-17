// Length counter sim.

if ( W4003 ) InputLatch = D
if (STEP) {
    if ( carry_in ) {
        if (nACLK) OutputLatch = NOT(InputLatch);
    }
    else {
        if (nACLK) OutputLatch = InputLatch;
    }
    if (nACLK) InputLatch = NOR ( NOT(InputLatch), OutputLatch);
    else InputLatch = NOT(OutputLatch);
}
carry_out = NOR ( InputLatch, NOT(carry_in) );
if ( nACLK ) InputLatch = InputLatch;

 N - I = N-  O
 0 - 0 = 0,  0
 0 - 1 = 1,  1
 1 - 1 = 0,  0
 1 - 0 = 1,  0

int Counter = Counter - CarryIn
if (Counter < 0) CarryOut = 1;
else CarryOut = 0;
