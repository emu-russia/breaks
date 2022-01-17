// Sweep unit.

//$4001.3=1: decrease mode
//$4001.3=0: increase mode

// Square channel 1:
// decrease mode: F = F + NOT(F >> N)
// increase mode: F = F + (F >> N).

main ()
{
    char in[11], out[11], sr;
    int i, nsum, ncout;
    int DEC;

    // Test values.
    unpackreg ( in, 182, 11 );
    sr = 2;
    DEC = 0;
    // sum = 227

    printf ( "%i[%02X] + ", packreg ( in, 11), packreg ( in, 11) );

    // Invert input in decrease mode.
    if (DEC) {
        for (i=0; i<11; i++) in[i] = NOT(in[i]);
    }

    // Barrel shifter.
    for (i=0;i<(11-sr);i++) out[i] = in[i+sr];
    for (i;i<11;i++) out[i] = DEC;

    printf ( "%i[%02X] = ", packreg (out, 11), packreg (out, 11) );

    // Adder.
    ncout = 1;
    for (i=0;i<11;i++)
    {
        nsum = NOT(in[i] & NOT(out[i]) & ncout) & NOT(NOT(in[i]) & out[i] & ncout) & NOT(NOT(in[i]) & NOT(out[i]) & NOT(ncout)) & NOT(in[i] & out[i] & NOT(ncout));
        ncout = NOT(in[i] & out[i]) & NOT(in[i] & NOT(out[i]) & NOT(ncout)) & NOT(NOT(in[i]) & out[i] & NOT(ncout));
        in[i] = NOT(nsum);
    }

    printf ( "%i[%02X] \n", packreg (in, 11), packreg (in, 11) );
}

/*
a b c | cout sum
0 0 0 | 0 1   0 
0 0 1 | 0 1   1 
0 1 0 | 0 0   1 
0 1 1 | 1 1   0 
1 0 0 | 0 0   1 
1 0 1 | 1 1   0 
1 1 0 | 1 0   0 
1 1 1 | 1 0   1 
*/


/*
main ()
{
    int a, b, c, ncout, nsum;
    int n;
    int vec[8] = { 1, 1, 1, 0, 1, 0, 0, 0 };

    int comb, z, op[4];

    printf ( "a b c | ncout nsum\n");

    for (n=0; n<8; n++)
    {
        a = BIT(n >> 2);
        b = BIT(n >> 1);
        c = BIT(n >> 0);

        ncout = NOT(a & b) & NOT(a & NOT(b) & c) & NOT(NOT(a) & b & c);
        nsum = NOT(a & NOT(b) & NOT(c)) & NOT(NOT(a) & b & NOT(c)) & NOT(NOT(a) & NOT(b) & c) & NOT(a & b & c);
        printf ( "%i %i %i | %i     %i \n", a, b, c, ncout, nsum );
    }

    for (n=0; n<8; n++)
    {
        a = BIT(n >> 2);
        b = BIT(n >> 1);
        c = BIT(n >> 0);

        for (comb=0; comb<256; comb++) {

            z = (comb >> 0) & 3;
            switch (z) {
                case 0: op[0] = NOT ( a & b ); break;
                case 1: op[0] = NOT ( a & NOT(b) ); break;
                case 2: op[0] = NOT ( NOT(a) & b ); break;
                case 3: op[0] = NOT ( NOT(a) & NOT(b) ); break;
            }

            z = (comb >> 2) & 7;
            switch (z) {
                case 0: op[1] = NOT ( a & b & c ); break;
                case 1: op[1] = NOT ( a & b & NOT(c) ); break;
                case 2: op[1] = NOT ( a & NOT(b) & c ); break;
                case 3: op[1] = NOT ( a & NOT(b) & NOT(c) ); break;
                case 4: op[1] = NOT ( NOT(a) & b & c ); break;
                case 5: op[1] = NOT ( NOT(a) & b & NOT(c) ); break;
                case 6: op[1] = NOT ( NOT(a) & NOT(b) & c ); break;
                case 7: op[1] = NOT ( NOT(a) & NOT(b) & NOT(c) ); break;
            }

            z = (comb >> 5) & 7;
            switch (z) {
                case 0: op[2] = NOT ( a & b & c ); break;
                case 1: op[2] = NOT ( a & b & NOT(c) ); break;
                case 2: op[2] = NOT ( a & NOT(b) & c ); break;
                case 3: op[2] = NOT ( a & NOT(b) & NOT(c) ); break;
                case 4: op[2] = NOT ( NOT(a) & b & c ); break;
                case 5: op[2] = NOT ( NOT(a) & b & NOT(c) ); break;
                case 6: op[2] = NOT ( NOT(a) & NOT(b) & c ); break;
                case 7: op[2] = NOT ( NOT(a) & NOT(b) & NOT(c) ); break;
            }

            cout = op[0] & op[1] & op[2];
            printf ("%i", cout == vec[n]);
        }

        printf ( "\n");
    }

}
*/


/*
NAND(a,b) = NOT(a) | NOT(b)
NOR(a,b) = NOT(a) & NOT(b)

a ^ b = NAND(a, b) & (a | b);

XOR = NOR ((a&b), NOR(a,b));
XOR = (a|b) & NAND(a,b);

(a & b) | z = NAND ( NAND(a,b), NOT(z) );
z = ((a ^ b) & c) = ([NAND(a, b) & NAND(NOT(a), NOT(b))] & c)

!( !(a&b) & ! (!(a&b) & !(!a & !b) & c )

(a & b) | z = NOT ( NAND(a,b) & NOT(z) );

*/

