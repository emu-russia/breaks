//
// MOS 6502 Core
//

using System;
using System.ComponentModel;

public class Cpu
{
    private int _Phi0;
    private int _Phi1;
    private int _Phi2;
    private bool DecimalALUEnabled;

    public Cpu()
    {
    }

    [Category("Pads")]
    public int Phi0
    {
        get { return _Phi0; }
        set
        {
            if (_Phi0 != value)
            {
                _Phi0 = value;

                Propagate();
            }
        }
    }

    [Category("Pads")]
    public int Phi1
    {
        get { return _Phi1; }
        set
        {
            // Output signal, cannot change
        }
    }

    [Category("Pads")]
    public int Phi2
    {
        get { return _Phi2; }
        set
        {
            // Output signal, cannot change
        }
    }

    //
    // Enable/disable decimal mode
    //

    public void EnableNesHack (bool enable)
    {
        DecimalALUEnabled = !enable;
    }

    //
    // Update state
    //

    private void Propagate ()
    {

        _Phi1 = ~Phi0 & 1;
        _Phi2 = Phi0;

    }
}
