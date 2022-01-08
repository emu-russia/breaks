// A dummy device that uses the 6502 as a processor.
// Contains 64 Kbytes of memory and nothing else.

using System;
using System.ComponentModel;

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
            [Category("Data Bus")]
            public byte [] D { get; set; } = new byte[8];
        }

        public class CpuDebugInfo
        {
            public int bogus;
        }

        public CpuPads cpu_pads = new CpuPads();
        public CpuDebugInfo cpu_debugInfo = new CpuDebugInfo();

        public void Step()
        {
            Console.WriteLine("Step");

            mem.WriteByte(0, (byte)(mem.ReadByte(0) + 1));

            cpu_pads.PHI0 = CLK;

            // TODO: Execute M6502Core::sim

            cpu_pads.PHI1 = (byte)(~cpu_pads.PHI0 & 1);
            cpu_pads.PHI2 = cpu_pads.PHI0;

            // TODO: GetDebugInfo

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
    }

}
