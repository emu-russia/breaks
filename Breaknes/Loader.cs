//
// ROM Loader
//

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

public class Loader
{

    public CartBoard LoadNes(string filename)
    {
        Unrom unrom = new Unrom();

        MessageBox.Show("Load NES ROM: " + filename);

        return unrom;
    }

}
