// A dummy device that uses the 6502 as a processor.
// Contains 64 Kbytes of memory and nothing else.

using System;

using Be.Windows.Forms;

namespace BreaksDebug
{
    class BogusSystem
    {
        public int Cycle = 0;

        byte CLK = 0;
        IByteProvider mem;

        public void Step()
        {
            Console.WriteLine("Step");

            mem.WriteByte(0, (byte)(mem.ReadByte(0) + 1));

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
