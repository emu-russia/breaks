// Redundant PPU (H/V random logic only)

using System;
using System.Collections.Generic;

public class Ppu
{
    //
    // External pads
    //

    public int CLK;
    public int nRES;

    //
    // Internal state
    //

    private int RES;    // Global Reset
    private int RC;         // Clear PPU registers
    private int RESCL;  // Clear ResetFF (feedback from HV logic)
    private int ResetFF;

    private long ToggleCounter;

    private int[] PCLKDivLatch = { 0, 0, 0, 0 };
    private int PCLK;

    private CounterBit[] HCounter = new CounterBit[9];
    private CounterBit[] VCounter = new CounterBit[9];

    private int[] HLUT = new int[24];
    private int[] VLUT = new int[9];

    public int HCounterValue
    {
        get
        {
            int Value = 0;

            for (int i = HCounter.Length - 1; i >= 0; i--)
            {
                Value <<= 1;
                Value |= HCounter[i].Output;
            }

            return Value;
        }
    }

    public int VCounterValue
    {
        get
        {
            int Value = 0;

            for (int i = VCounter.Length - 1; i >= 0; i--)
            {
                Value <<= 1;
                Value |= VCounter[i].Output;
            }

            return Value;
        }
    }

    private int not(int n)
    {
        return ~n & 1;
    }

    private int nor(int a, int b)
    {
        return not(a | b);
    }

    public Ppu ()
    {
        ToggleCounter = 0;

        for (int i = 0; i < HCounter.Length; i++)
            HCounter[i] = new CounterBit();

        for (int i = 0; i < VCounter.Length; i++)
            VCounter[i] = new CounterBit();

        SetClock(0);
    }

    private void SetClock(int n)
    {
        CLK = n;

        PixelClockDivider(CLK);
        ResetLogic ();
    }

    public void ToggleClock ()
    {
        CLK ^= 1;
        CLK &= 1;
        SetClock(CLK);

        ToggleCounter++;
    }

    private void ResetLogic ()
    {
        RES = not(nRES);
        RC = RES | ResetFF;
        ResetFF = RC & not(RESCL);
    }

    private void PixelClockDivider (int clk)
    {
        if (clk == 1)
            PCLKDivLatch[0] = nor(RES, PCLK);

        if (clk == 0)
            PCLKDivLatch[1] = not(PCLKDivLatch[0]);

        if (clk == 1)
            PCLKDivLatch[2] = not(PCLKDivLatch[1]);

        if (clk == 0)
            PCLKDivLatch[3] = not(PCLKDivLatch[2]);

        PCLK = not(PCLKDivLatch[3]);

        HVCounters();
    }

    private void HVCounters ()
    {
        int CarryInput = 1;

        for (int i=0; i<HCounter.Length; i++)
        {
            HCounter[i].Clear = 0;
            HCounter[i].Reset = RES;
            HCounter[i].CarryInput = CarryInput;
            HCounter[i].Step(PCLK);
            CarryInput = HCounter[i].CarryOut;
        }

        HCounterLut();

        CarryInput = 0;         // FIXME: Replace on V_IN control

        for (int i=0; i<VCounter.Length; i++)
        {
            VCounter[i].Clear = 0;
            VCounter[i].Reset = RES;
            VCounter[i].CarryInput = CarryInput;
            VCounter[i].Step(PCLK);
            CarryInput = VCounter[i].CarryOut;
        }

        VCounterLut();
    }
    
    private void HCounterLut ()
    {
        HLUT[0] = not( 
            not(HCounter[0].Output) | 
            not(HCounter[1].Output) |
            not(HCounter[2].Output) | 
            HCounter[3].Output |
            not(HCounter[4].Output) |
            HCounter[5].Output |
            HCounter[6].Output |
            HCounter[7].Output |
            not(HCounter[8].Output) );

    }

    private void VCounterLut ()
    {

    }

    public void Dump ()
    {
        Console.WriteLine(
            "Step: " + ToggleCounter.ToString() + ", " +
            "CLK: " + CLK.ToString() + ", " +
            "PCLK: " + PCLK.ToString() + ", " +
            "H: " + HCounterValue.ToString() + ", " +
            "V: " + VCounterValue.ToString() 
            );
        
    }

}

public class CounterBit
{
    private int Latch = 0;
    private int FlipFlop = 0;
    public int CarryInput;
    public int CarryOut;
    public int Output = 0;
    public int Clear;
    public int Reset;

    public void Step (int clk)
    {
        Output = nor(FlipFlop, Reset);
        CarryOut = nor(FlipFlop, not(CarryInput));

        //
        // Update FlipFlop
        //

        if (clk == 0)
            FlipFlop = not(Output);
        else
            FlipFlop = not(nor(Clear, Latch));

        //
        // Update Latch
        //

        if ( clk == 0)
        {
            if (CarryInput == 1)
                Latch = Output;
            else
                Latch = FlipFlop;
        }
    }

    private int not(int n)
    {
        return ~n & 1;
    }

    private int nor(int a, int b)
    {
        return not(a | b);
    }
}
