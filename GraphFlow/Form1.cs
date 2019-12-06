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
using CanvasControl;

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
        private List<Graph> graphs = new List<Graph>();
        private CanvasInputAdapter input;

        public Form1()
        {
            InitializeComponent();

            AllocConsole();

            input = new CanvasInputAdapter(canvasControl1);
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void loadYedGraphMLToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if ( openFileDialog1.ShowDialog() == DialogResult.OK )
            {
                string graphName = Path.GetFileNameWithoutExtension(openFileDialog1.FileName);

                // Check if alreay exists

                foreach (var g in graphs)
                {
                    if (g.name == graphName)
                    {
                        return;
                    }
                }

                // Load graph

                Graph graph = new Graph(Path.GetFileNameWithoutExtension(openFileDialog1.FileName));
                graph.FromGraphML(File.ReadAllText(openFileDialog1.FileName));

                // Add in collection

                ListViewItem item = new ListViewItem(graphName);

                item.SubItems.Add(graph.GetType().ToString());
                item.SubItems.Add(graph.nodes.Count.ToString());
                item.SubItems.Add(graph.edges.Count.ToString());

                item.Tag = graph;

                graphs.Add(graph);

                listView1.Items.Add(item);

                // TODO: Resolve Xrefs

                // Display is nothing yet shown

                if (RootGraph == null)
                {
                    RootGraph = graph;
                    VisualizeGraph(graph);
                }
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

        private void toolStripButton1_Click(object sender, EventArgs e)
        {
            if (RootGraph == null)
            {
                MessageBox.Show("No graph!");
                return;
            }

            RootGraph.Walk();
            RootGraph.DumpNodeValues();

            canvasControl1.Invalidate();
        }

        private void VisualizeGraph (Graph graph)
        {
            canvasControl1.RemoveAllItems();

            foreach (var node in graph.nodes)
            {
                if (node.Item != null)
                {
                    canvasControl1.AddItem(node.Item);
                }
            }

            foreach ( var edge in graph.edges)
            {
                if (edge.Item != null)
                {
                    canvasControl1.AddItem(edge.Item);
                }
            }

            canvasControl1.Invalidate();
        }

        private void toolStripButton2_Click(object sender, EventArgs e)
        {
            if (RootGraph != null)
            {
                RootGraph.Reset();
                canvasControl1.Invalidate();
            }
        }

        private void listView1_DoubleClick(object sender, EventArgs e)
        {
            if (listView1.SelectedItems.Count == 1)
            {
                Graph graph = listView1.SelectedItems[0].Tag as Graph;
                RootGraph = graph;
                VisualizeGraph(graph);
            }
        }
    }
}
