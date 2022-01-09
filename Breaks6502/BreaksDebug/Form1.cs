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
using System.IO;

namespace BreaksDebug
{
    public partial class Form1 : Form
    {
        [DllImport("kernel32")]
        static extern bool AllocConsole();

        BogusSystem sys = new BogusSystem();
        byte[] sram = new byte[0x10000];
        IByteProvider memProvider;
        string testAsmName = "Test.asm";

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
#if DEBUG
            AllocConsole();
#endif

            toolStripButton4.Checked = true;    // /NMI
            toolStripButton5.Checked = true;    // /IRQ
            toolStripButton6.Checked = false;   // /RES
            toolStripButton3.Checked = false;   // SO
            toolStripButton2.Checked = true;    // RES
            ButtonsToPads();

            memProvider = new DynamicByteProvider(sram);
            hexBox1.ByteProvider = memProvider;
            sys.AttatchMemory(memProvider);
            UpdateAll();

            if (File.Exists(testAsmName))
            {
                LoadAsm(testAsmName);
                Assemble();
            }
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

        void UpdateCpuPads()
        {
            propertyGrid1.SelectedObject = sys.cpu_pads;
        }

        void UpdateState()
        {
            if (sys.cpu_pads.PHI1 != 0)
            {
                label3.Text = "PHI1 (Talking)";
            }

            if (sys.cpu_pads.PHI2 != 0)
            {
                label3.Text = "PHI2 (Listening)";
            }
        }

        void UpdateCpuDebugInfo()
        {
            propertyGrid2.SelectedObject = sys.GetRegsBuses();
            //propertyGrid3.SelectedObject = TODO;
            propertyGrid4.SelectedObject = sys.GetDecoder();
            propertyGrid4.ExpandAllGridItems();
            propertyGrid5.SelectedObject = sys.GetCommands();
            propertyGrid5.ExpandAllGridItems();

            UpdateDisasm(0x00);
        }

        void UpdateDisasm(byte ir)
        {
            label9.Text = QuickDisasm.Disasm(ir);
        }

        void UpdateAll()
        {
            UpdateCycleStats();
            UpdateMemoryDump();
            UpdateCpuPads();
            UpdateState();
            UpdateCpuDebugInfo();
        }

        private void loadMemoryDumpToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult res = openFileDialog2.ShowDialog();
            if (res == DialogResult.OK)
            {
                byte[] dump = File.ReadAllBytes(openFileDialog2.FileName);

                for (int i=0; i<sram.Length; i++)
                {
                    memProvider.WriteByte(i, dump[i]);
                }

                hexBox1.Refresh();
            }
        }

        private void saveTheMemoryDumpToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult res = saveFileDialog1.ShowDialog();
            if (res == DialogResult.OK)
            {
                byte[] dump = new byte[sram.Length];

                for (int i = 0; i < sram.Length; i++)
                {
                    dump[i] = memProvider.ReadByte(i);
                }

                File.WriteAllBytes(saveFileDialog1.FileName, dump);
            }
        }

        private void loadAssemblySourceToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult res = openFileDialog1.ShowDialog();
            if (res == DialogResult.OK)
            {
                LoadAsm(openFileDialog1.FileName);
            }

            tabControl2.SelectTab(1);
        }

        void LoadAsm(string filename)
        {
            richTextBox1.Text = File.ReadAllText(filename);
            Console.WriteLine("Loaded " + filename);
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Assemble();
        }

        void Assemble()
        {
            byte[] buffer = new byte[sram.Length];

            int num_err = Assemble(richTextBox1.Text, buffer);
            if (num_err != 0)
            {
                MessageBox.Show(
                    "Errors occurred during the assembling process. Num erros: " + num_err.ToString(), 
                    "Assembling error", MessageBoxButtons.OK, MessageBoxIcon.Exclamation );
                return;
            }

            for (int i = 0; i < sram.Length; i++)
            {
                memProvider.WriteByte(i, buffer[i]);
            }

            hexBox1.Refresh();
        }

        [DllImport("BreakasmInterop.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern int Assemble(string text, byte [] buffer);

        void ButtonsToPads()
        {
            sys.cpu_pads.n_NMI = (byte)(toolStripButton4.Checked ? 1 : 0);
            sys.cpu_pads.n_IRQ = (byte)(toolStripButton5.Checked ? 1 : 0);
            sys.cpu_pads.n_RES = (byte)(toolStripButton6.Checked ? 1 : 0);
            sys.cpu_pads.SO = (byte)(toolStripButton3.Checked ? 1 : 0);
            sys.cpu_pads.RDY = (byte)(toolStripButton2.Checked ? 1 : 0);
        }

        private void toolStripButton4_CheckedChanged(object sender, EventArgs e)
        {
            ButtonsToPads();
            UpdateCpuPads();
        }

        private void toolStripButton5_CheckedChanged(object sender, EventArgs e)
        {
            ButtonsToPads();
            UpdateCpuPads();
        }

        private void toolStripButton6_CheckedChanged(object sender, EventArgs e)
        {
            ButtonsToPads();
            UpdateCpuPads();
        }

        private void toolStripButton3_CheckedChanged(object sender, EventArgs e)
        {
            ButtonsToPads();
            UpdateCpuPads();
        }

        private void toolStripButton2_CheckedChanged(object sender, EventArgs e)
        {
            ButtonsToPads();
            UpdateCpuPads();
        }

        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            FormAbout dlg = new FormAbout();
            dlg.ShowDialog();
        }
    }
}
