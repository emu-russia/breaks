# Layer mix #
<img src='http://ogamespec.com/imgstore/whc4ff5f55ad23ac.jpg'>

bits 1...7 are identical to bit 0.<br>
<br>
<h1>Transistor-level</h1>
<img src='http://ogamespec.com/imgstore/whc4ff5f55f6f8d6.jpg'>

<h1>Runflow</h1>

Y/SB, SB/Y, X/SB, SB/X and SB/S are low during PHI2.<br>
<br>
SB[0...7] are high during PHI2 ("precharged")<br>
<br>
If both S/S and SB/S are low and PHI2 is high, S register set to 0xFF.<br>
Otherwise S value is refreshed if S/S is high, and replaced by SB value, if SB/S is high also.<br>
S value stored in latch in inverted logic.