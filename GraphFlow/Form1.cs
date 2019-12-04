using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using System.Runtime.InteropServices;

namespace GraphFlow
{
    public partial class Form1 : Form
    {
        [DllImport("kernel32.dll",
                    EntryPoint = "AllocConsole",
                    SetLastError = true,
                    CharSet = CharSet.Auto,
                    CallingConvention = CallingConvention.StdCall)]
        private static extern int AllocConsole();

        private Graph NFlag;

        public Form1()
        {
            InitializeComponent();

            AllocConsole();
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void generateAndDumpNFLAGCircuiteToolStripMenuItem_Click(object sender, EventArgs e)
        {
            NFlag = NFlagGeneratorClass.GenerateNFlag();

            //NFlag.Dump();
        }

        private void walkGraphToolStripMenuItem_Click(object sender, EventArgs e)
        {
            int phi = 0;

            if (NFlag == null)
            {
                NFlag = NFlagGeneratorClass.GenerateNFlag();
            }

            Node dbn = NFlag.GetNodeByName("DB/N");
            Node ndb7 = NFlag.GetNodeByName("/DB7");
            Node phi1 = NFlag.GetNodeByName("PHI1");
            Node phi2 = NFlag.GetNodeByName("PHI2");

            dbn.Value = 1;
            ndb7.Value = 0;
            phi1.Value = phi != 0 ? 0 : 1;
            phi2.Value = phi != 0 ? 1 : 0;

            NFlag.Walk();

            NFlag.DumpNodeValues();
        }
    }
}
