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
using Be.Windows.Forms;

namespace BreaksDebug
{
    public partial class Form1 : Form
    {
        [DllImport("kernel32")]
        static extern bool AllocConsole();

        BogusSystem sys = new BogusSystem();
        byte[] sram = new byte[0x10000];
        IByteProvider memProvider;

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            memProvider = new DynamicByteProvider(sram);
            hexBox1.ByteProvider = memProvider;
            sys.AttatchMemory(memProvider);
            UpdateAll();

#if DEBUG
            AllocConsole();
#endif
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void toolStripButton1_Click(object sender, EventArgs e)
        {
            Step();
        }

        private void Form1_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.F11)
            {
                Step();
            }
        }

        void Step()
        {
            sys.Step();
            UpdateAll();
        }

        void UpdateCycleStats()
        {
            toolStripStatusLabel1.Text = "Cycle: " + sys.Cycle.ToString();
        }

        void UpdateMemoryDump()
        {
            hexBox1.Refresh();
        }

        void UpdateAll()
        {
            UpdateCycleStats();
            UpdateMemoryDump();
        }

    }
}
