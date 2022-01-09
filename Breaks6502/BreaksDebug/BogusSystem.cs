// A dummy device that uses the 6502 as a processor.
// Contains 64 Kbytes of memory and nothing else.

using System;
using System.ComponentModel;
using System.Runtime.InteropServices;

using Be.Windows.Forms;

namespace BreaksDebug
{
    class BogusSystem
    {
        public int Cycle = 0;

        byte CLK = 0;
        IByteProvider mem;

        public class CpuPads
        {
            [Category("Inputs")]
            public byte n_NMI { get; set; }
            [Category("Inputs")]
            public byte n_IRQ { get; set; }
            [Category("Inputs")]
            public byte n_RES { get; set; }
            [Category("Inputs")]
            public byte PHI0 { get; set; }
            [Category("Inputs")]
            public byte RDY { get; set; }
            [Category("Inputs")]
            public byte SO { get; set; }
            [Category("Outputs")]
            public byte PHI1 { get; set; }
            [Category("Outputs")]
            public byte PHI2 { get; set; }
            [Category("Outputs")]
            public byte RnW { get; set; }
            [Category("Outputs")]
            public byte SYNC { get; set; }
            [Category("Address Bus")]
            public byte[] A { get; set; } = new byte[16];
            [Category("Address Bus")]
            public string Addr { get; set; } = "?";
            [Category("Data Bus")]
            public byte [] D { get; set; } = new byte[8];
        }

        [StructLayout(LayoutKind.Sequential, Pack=1)]
        unsafe struct CpuPadsRaw
        {
            public byte n_NMI;
            public byte n_IRQ;
            public byte n_RES;
            public byte PHI0;
            public byte RDY;
            public byte SO;
            public byte PHI1;
            public byte PHI2;
            public byte RnW;
            public byte SYNC;
            public fixed byte A[16];
            public fixed byte D[8];
        }

        public class CpuDebugInfo
        {
            public int bogus;
        }

        [StructLayout(LayoutKind.Sequential, Pack = 1)]
        unsafe struct CpuDebugInfoRaw
        {
            public byte bogus;
        }

        public CpuPads cpu_pads = new CpuPads();
        public CpuDebugInfo cpu_debugInfo = new CpuDebugInfo();

        public void Step()
        {
            Console.WriteLine("Step");

            cpu_pads.PHI0 = CLK;

            // Execute M6502Core::sim

            CpuPadsRaw pads = SerializePads (cpu_pads);
            CpuDebugInfoRaw info = new CpuDebugInfoRaw();

            Sim(ref pads, ref info);

            cpu_pads = DeserializePads(pads);

            // TODO: CpuDebugInfo

            // Handling memory operations

            UInt16 address = 0;

            for (int i = 0; i < 16; i++)
            {
                if (cpu_pads.A[i] != 0)
                {
                    address |= (UInt16)(1 << i);
                }
            }

            if (cpu_pads.RnW == 1)
            {
                // CPU Read

                byte data = mem.ReadByte(address);

                for (int i =0; i<8; i++)
                {
                    if ((data & (1 << i)) != 0)
                    {
                        cpu_pads.D[i] = 1;
                    }
                    else
                    {
                        cpu_pads.D[i] = 0;
                    }
                }
            }
            else
            {
                // CPU Write

                byte data = 0;

                for (int i = 0; i < 8; i++)
                {
                    if (cpu_pads.D[i] != 0)
                    {
                        data |= (byte)(1 << i);
                    }
                }

                mem.WriteByte(address, data);
            }

            // Clockgen

            if (CLK != 0)
            {
                CLK = 0;
                Cycle++;
            }
            else
            {
                CLK = 1;
            }
        }
  
        public void AttatchMemory (IByteProvider prov)
        {
            mem = prov;
        }

        CpuPadsRaw SerializePads (CpuPads pads)
        {
            CpuPadsRaw pads_raw = new CpuPadsRaw();

            pads_raw.n_NMI = pads.n_NMI;
            pads_raw.n_IRQ = pads.n_IRQ;
            pads_raw.n_RES = pads.n_RES;
            pads_raw.PHI0 = pads.PHI0;
            pads_raw.RDY = pads.RDY;
            pads_raw.SO = pads.SO;
            pads_raw.PHI1 = pads.PHI1;
            pads_raw.PHI2 = pads.PHI2;
            pads_raw.RnW = pads.RnW;
            pads_raw.SYNC = pads.SYNC;

            unsafe
            {
                for (int i = 0; i < 16; i++)
                {
                    pads_raw.A[i] = pads.A[i];
                }

                for (int i = 0; i < 8; i++)
                {
                    pads_raw.D[i] = pads.D[i];
                }
            }

            return pads_raw;
        }

        CpuPads DeserializePads(CpuPadsRaw pads_raw)
        {
            CpuPads pads = new CpuPads();

            pads.n_NMI = pads_raw.n_NMI;
            pads.n_IRQ = pads_raw.n_IRQ;
            pads.n_RES = pads_raw.n_RES;
            pads.PHI0 = pads_raw.PHI0;
            pads.RDY = pads_raw.RDY;
            pads.SO = pads_raw.SO;
            pads.PHI1 = pads_raw.PHI1;
            pads.PHI2 = pads_raw.PHI2;
            pads.RnW = pads_raw.RnW;
            pads.SYNC = pads_raw.SYNC;

            unsafe
            {
                UInt16 Addr = 0;

                for (int i = 0; i < 16; i++)
                {
                    pads.A[i] = pads_raw.A[i];

                    if (pads.A[i] != 0)
                    {
                        Addr |= (UInt16)(1 << i);
                    }
                }

                pads.Addr = "0x" + Addr.ToString("X4");

                for (int i = 0; i < 8; i++)
                {
                    pads.D[i] = pads_raw.D[i];
                }
            }

            return pads;
        }

        [DllImport("M6502CoreInterop.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern void Sim(ref CpuPadsRaw pads, ref CpuDebugInfoRaw debugInfo);
    }

}
