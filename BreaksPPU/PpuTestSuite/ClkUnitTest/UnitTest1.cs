using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ClkUnitTest
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void PpuClkBasicTest()
        {
            Ppu ppu = new Ppu();

            ppu.SetPad("CLK", 0);

            Assert.IsTrue(ppu.Pads.CLK == 0);

            ppu.ToggleClock();

            Assert.IsTrue(ppu.Pads.CLK == 1);
            Assert.IsTrue(ppu.ToggleCounter == 1);

            Assert.IsTrue(ppu.NotCLKout == 0);
            Assert.IsTrue(ppu.CLKout == 1);
        }
    }
}
