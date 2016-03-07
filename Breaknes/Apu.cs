//
// 2A03 APU
//

using System;
using System.ComponentModel;

public class Apu
{
    public Cpu core = new Cpu();

    public Apu()
    {
        core.EnableNesHack(true);
    }
}
