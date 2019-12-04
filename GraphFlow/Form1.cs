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
using System.IO;

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

        private Graph RootGraph;

        public Form1()
        {
            InitializeComponent();

            AllocConsole();
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Close();
        }

        /// <summary>
        /// Generate hardcoded sample graph
        /// </summary>
        private void GenerateNflag ()
        {
            int phi = 0;

            RootGraph = NFlagGeneratorClass.GenerateNFlag();

            Node dbn = RootGraph.GetNodeByName("DB/N");
            Node ndb7 = RootGraph.GetNodeByName("/DB7");
            Node phi1 = RootGraph.GetNodeByName("PHI1");
            Node phi2 = RootGraph.GetNodeByName("PHI2");

            dbn.Value = 1;
            ndb7.Value = 0;
            phi1.Value = phi != 0 ? 0 : 1;
            phi2.Value = phi != 0 ? 1 : 0;

            propertyGrid1.SelectedObject = RootGraph;

            //RootGraph.Dump();
        }

        private void generateAndDumpNFLAGCircuiteToolStripMenuItem_Click(object sender, EventArgs e)
        {
            GenerateNflag();
        }

        private void walkGraphToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (RootGraph == null)
            {
                MessageBox.Show("No graph!");
                return;
            }

            RootGraph.Walk();
            RootGraph.DumpNodeValues();
        }

        private void loadYedGraphMLToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if ( openFileDialog1.ShowDialog() == DialogResult.OK )
            {
                RootGraph = new Graph(openFileDialog1.FileName);
                RootGraph.FromGraphML(File.ReadAllText(openFileDialog1.FileName));
                propertyGrid1.SelectedObject = RootGraph;
            }
        }

        private void dumpGraphToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if ( RootGraph != null)
            {
                RootGraph.Dump();
            }
        }

        private void dumpGraphValuesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (RootGraph != null)
            {
                RootGraph.DumpNodeValues();
            }
        }
    }
}
