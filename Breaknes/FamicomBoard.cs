//
// Home for all components
//

using System;
using System.ComponentModel;

public class FamiBoard
{
    private int _Clk;
    public Apu apu = new Apu();
    public CartBoard cart = null;

    public FamiBoard ()
    {
    }

    [Category("Internal state")]
    public int Clk
    {
        get { return _Clk; }
        set
        {
            if (_Clk != value)
            {
                _Clk = value;

                Propagate();
            }
        }
    }

    //
    // Update state
    //

    private void Propagate ()
    {
        apu.core.Phi0 = Clk;

    }
}
