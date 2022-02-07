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
using Newtonsoft.Json;

namespace BreaksDebug
{
    public partial class Form1 : Form
    {
        [DllImport("kernel32")]
        static extern bool AllocConsole();

        BogusSystem sys = new BogusSystem();
        byte[] mem = new byte[0x10000];
        IByteProvider memProvider;
        string testAsmName = "Test.asm";
        string MarkdownDir = "WikiMarkdown";        // To dump the state as Markdown text, you need to create this directory.
        string MarkdownImgDir = "imgstore/ops";
        string WikiRoot = "/BreakingNESWiki/";
        bool MarkdownOutput = false;

        class UnitTestParam
        {
            public bool CompileFromSource = true;
            public string MemDumpInput = "mem.bin";
            public string AsmSource = "Test.asm";
            public string RamStart = "0";
            public string RamSize = "0x800";
            public string RomStart = "0xc000";
            public string RomSize = "0x4000";
            public bool RunUntilBrk = true;
            public bool RunCycleAmount = true;
            public int CycleMax = 10000;
            public bool RunUntilPC = false;
            public string PC = "0x0";
            public bool TraceMemOps = true;
            public bool TraceCLK = true;
            public bool DumpMem = true;
            public string JsonResult = "res.json";
            public string MemDumpOutput = "mem2.bin";
        }

        class UnitTestResult
        {
            public string A { get; set; } = "0x00";
            public string X { get; set; } = "0x00";
            public string Y { get; set; } = "0x00";
            public string S { get; set; } = "0x00";
            public string PC { get; set; } = "0x0000";
            public int C { get; set; } = 0;
            public int Z { get; set; } = 0;
            public int I { get; set; } = 0;
            public int D { get; set; } = 0;
            public int V { get; set; } = 0;
            public int N { get; set; } = 0;
            public UInt64 CLK { get; set; } = 0;
        }

        bool UnitTestMode = false;
        string TestInputJson;
        UnitTestParam testParam;
        UInt64 UnitTestPhiCounter = 0;
        UInt64 UnitTestPhiTraceCounter = 0;

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
#if DEBUG
            AllocConsole();
#endif
            
            SetStyle(ControlStyles.OptimizedDoubleBuffer, true);

            toolStripButton4.Checked = true;    // /NMI
            toolStripButton5.Checked = true;    // /IRQ
            toolStripButton6.Checked = false;   // /RES
            toolStripButton3.Checked = false;   // SO
            toolStripButton2.Checked = true;    // RES
            ButtonsToPads();

            memProvider = new DynamicByteProvider(mem);
            hexBox1.ByteProvider = memProvider;
            sys.AttatchMemory(memProvider);
            UpdateAll();

            // Select the operating mode - manual or automatic unit test.

            string[] args = Environment.GetCommandLineArgs();

            UnitTestMode = args.Length > 1;
            if (UnitTestMode)
            {
                TestInputJson = args[1];
                Console.WriteLine("Running UnitTest from " + TestInputJson);

                string json = File.ReadAllText(TestInputJson);

                testParam = JsonConvert.DeserializeObject<UnitTestParam>(json);

                if (InitUnitTest() == 0)
                {
                    StartUnitTest();
                }
            }
            else
            {
                if (File.Exists(testAsmName))
                {
                    LoadAsm(testAsmName);
                    Assemble();
                }
            }

            MarkdownOutput = Directory.Exists(MarkdownDir);
            if (MarkdownOutput && !UnitTestMode)
            {
                Directory.CreateDirectory(MarkdownDir + "/" + MarkdownImgDir);
            }
        }

        int Strtol(string str)
        {
            str = str.Trim();

            return (str.Contains("0x") || str.Contains("0X")) ?
                Convert.ToInt32(str, 16) :
                    str[0] == '0' ? Convert.ToInt32(str, 8) : Convert.ToInt32(str, 10);
        }

        int InitUnitTest()
        {
            BogusSystem.MemoryMapping map = new BogusSystem.MemoryMapping();

            map.RamStart = Strtol(testParam.RamStart);
            map.RamSize = Strtol(testParam.RamSize);
            map.RomStart = Strtol(testParam.RomStart);
            map.RomSize = Strtol(testParam.RomSize);

            sys.SetMemoryMapping(map);

            if (testParam.CompileFromSource)
            {
                LoadAsm(testParam.AsmSource);
                Assemble();
            }
            else
            {
                LoadMemDump(testParam.MemDumpInput);
            }

            // Perform the PreBRK PowerUP sequence

            for (int i=0; i<8; i++)
            {
                Step();
            }

            // Cancel Reset and wait for Reset BRK to complete

            toolStripButton6.Checked = true;

            int timeout = 0x100;

            while (timeout-- != 0)
            {
                Step();

                var regsBuses = sys.GetRegsBuses();
                if (regsBuses.IRForDisasm != 0x00)
                {
                    break;
                }
            }

            if (timeout == 0)
            {
                Console.WriteLine("The operation of the simulator is broken. BRK-sequence is not completed.");
                return -1;
            }

            return 0;
        }

        void StartUnitTest()
        {
            ushort BreakOnPC = (ushort)Strtol(testParam.PC);

            while (true)
            {
                Step();
                UnitTestPhiCounter++;
                UnitTestPhiTraceCounter++;
                if (UnitTestPhiTraceCounter > 1000000 * 2)
                {
                    // Output statistics every million cycles
                    if (testParam.TraceCLK)
                    {
                        Console.WriteLine("CLK: " + (UnitTestPhiCounter / 2).ToString());
                    }
                    UnitTestPhiTraceCounter = 0;
                }

                if (sys.Cycle >= testParam.CycleMax && testParam.RunCycleAmount)
                {
                    break;
                }

                var regsBuses = sys.GetRegsBuses();
                if (regsBuses.IRForDisasm == 0x00 && testParam.RunUntilBrk)
                {
                    break;
                }
                if (regsBuses.PCForUnitTest == BreakOnPC && testParam.RunUntilPC)
                {
                    break;
                }
            }

            SaveUnitTestResults();
        }

        void SaveUnitTestResults()
        {
            if (testParam.DumpMem)
            {
                SaveMemDump(testParam.MemDumpOutput);
            }

            UnitTestResult res = new UnitTestResult();

            var regsBuses = sys.GetRegsBuses();

            res.A = regsBuses.AC;
            res.X = regsBuses.X;
            res.Y = regsBuses.Y;
            res.S = regsBuses.S;
            res.PC = "0x" + regsBuses.PCForUnitTest.ToString("X4");
            res.C = regsBuses.C_OUT;
            res.Z = regsBuses.Z_OUT;
            res.I = regsBuses.I_OUT;
            res.D = regsBuses.D_OUT;
            res.V = regsBuses.V_OUT;
            res.N = regsBuses.N_OUT;
            res.CLK = UnitTestPhiCounter / 2;

            string json = JsonConvert.SerializeObject(res);

            File.WriteAllText(testParam.JsonResult, json);

            Close();
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void toolStripButton1_Click(object sender, EventArgs e)
        {
            if (!UnitTestMode)
            {
                Step();
            }
        }

        private void Form1_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.F11 && !UnitTestMode)
            {
                Step();
            }
        }

        void Step()
        {
            bool trace = true;

            if (UnitTestMode)
            {
                trace = testParam.TraceMemOps;
            }

            sys.Step(trace);
            if (!UnitTestMode)
            {
                UpdateAll();
            }
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
                label3.Text = "PHI1 (Set Address + R/W Mode)";
            }

            if (sys.cpu_pads.PHI2 != 0)
            {
                label3.Text = "PHI2 (Read/Write Mem)";
            }
        }

        void UpdateCpuDebugInfo()
        {
            var regsBuses = sys.GetRegsBuses();
            propertyGrid2.SelectedObject = regsBuses;
            var internals = sys.GetInternals();
            propertyGrid3.SelectedObject = internals;
            var decoderOut = sys.GetDecoder();
            propertyGrid4.SelectedObject = decoderOut;
            propertyGrid4.ExpandAllGridItems();
            var commands = sys.GetCommands();
            propertyGrid5.SelectedObject = commands;
            propertyGrid5.ExpandAllGridItems();

            dataPathView1.ShowCpuCommands(commands, sys.cpu_pads.PHI1 != 0);

            UpdateDisasm(regsBuses.IRForDisasm, regsBuses.PDForDisasm, internals.FETCH != 0);

            // Dump the state of the processor in a representative form for the wiki.

            if (MarkdownOutput)
            {
                MarkdownDump.ExportStepMarkdown(regsBuses, internals, decoderOut, commands, 
                    sys.cpu_pads.PHI1, sys.cpu_pads.PHI2, dataPathView1, MarkdownDir, MarkdownImgDir, WikiRoot);
            }
        }

        void UpdateDisasm(byte ir, byte pd, bool fetch)
        {
            label9.Text = QuickDisasm.Disasm(ir) + " (current)" ;
            if (fetch)
            {
                label9.Text += ", " + QuickDisasm.Disasm(pd) + " (fetched)";
            }
        }

        void UpdateAll()
        {
            UpdateCycleStats();
            UpdateMemoryDump();
            UpdateCpuPads();
            UpdateState();
            UpdateCpuDebugInfo();
        }

        void LoadMemDump(string file)
        {
            byte[] dump = File.ReadAllBytes(file);

            for (int i = 0; i < mem.Length; i++)
            {
                memProvider.WriteByte(i, dump[i]);
            }

            hexBox1.Refresh();
            Console.WriteLine("Loaded memory dump: " + file);
        }

        void SaveMemDump(string file)
        {
            byte[] dump = new byte[mem.Length];

            for (int i = 0; i < mem.Length; i++)
            {
                dump[i] = memProvider.ReadByte(i);
            }

            File.WriteAllBytes(file, dump);
            Console.WriteLine("Saved memory dump: " + file);
        }

        private void loadMemoryDumpToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult res = openFileDialog2.ShowDialog();
            if (res == DialogResult.OK)
            {
                LoadMemDump(openFileDialog2.FileName);
            }
        }

        private void saveTheMemoryDumpToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult res = saveFileDialog1.ShowDialog();
            if (res == DialogResult.OK)
            {
                SaveMemDump(saveFileDialog1.FileName);
            }
        }

        private void loadAssemblySourceToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult res = openFileDialog1.ShowDialog();
            if (res == DialogResult.OK)
            {
                LoadAsm(openFileDialog1.FileName);
                tabControl2.SelectTab(1);
            }
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
            Console.WriteLine("Assemble");

            byte[] buffer = new byte[mem.Length];

            int num_err = Assemble(richTextBox1.Text, buffer);
            if (num_err != 0)
            {
                MessageBox.Show(
                    "Errors occurred during the assembling process. Num erros: " + num_err.ToString(), 
                    "Assembling error", MessageBoxButtons.OK, MessageBoxIcon.Exclamation );
                return;
            }

            for (int i = 0; i < mem.Length; i++)
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
            Console.WriteLine("/NMI changed");
            ButtonsToPads();
            UpdateCpuPads();
        }

        private void toolStripButton5_CheckedChanged(object sender, EventArgs e)
        {
            Console.WriteLine("/IRQ changed");
            ButtonsToPads();
            UpdateCpuPads();
        }

        private void toolStripButton6_CheckedChanged(object sender, EventArgs e)
        {
            Console.WriteLine("/RES changed");
            ButtonsToPads();
            UpdateCpuPads();
        }

        private void toolStripButton3_CheckedChanged(object sender, EventArgs e)
        {
            Console.WriteLine("SO changed");
            ButtonsToPads();
            UpdateCpuPads();
        }

        private void toolStripButton2_CheckedChanged(object sender, EventArgs e)
        {
            Console.WriteLine("RDY changed");
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
