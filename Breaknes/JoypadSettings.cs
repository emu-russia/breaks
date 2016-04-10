using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using SharpDX.DirectInput;

namespace Breaknes
{
    public partial class JoypadSettings : Form
    {
        public JoypadSettings()
        {
            InitializeComponent();
        }

        private void JoypadSettings_KeyUp(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Escape)
                Close();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            //
            // Enum DirectInput devices
            //

            var dinput = new DirectInput();

            foreach ( var di in dinput.GetDevices(DeviceType.Keyboard, DeviceEnumerationFlags.AllDevices))
            {
                Console.WriteLine(di.ProductName.ToString() + "GUID: " + di.ProductGuid.ToString());
            }

            foreach (var di in dinput.GetDevices(DeviceType.Gamepad, DeviceEnumerationFlags.AllDevices))
            {
                Console.WriteLine(di.ProductName.ToString() + "GUID: " + di.ProductGuid.ToString());
            }


            //foreach (DeviceInstance di in Manager.Devices)
            //{
            //}
        }
    }
}
