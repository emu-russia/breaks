// 2C02 PPU HV Trace 
//

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HV_Trace
{
    class Program
    {
        static Ppu ppu = new Ppu();

        static void Main(string[] args)
        {
            //
            // Reset PPU
            //

            ppu.nRES = 0;

            for (int i=0;i<8; i++)
            {
                ppu.ToggleClock();

                ppu.Dump();
            }

            ppu.nRES = 1;

            //
            // Execute PPU a while
            //

            for (int i=0; i<1000; i++)
            {
                ppu.ToggleClock();

                ppu.Dump();
            }

        }
    }
}
