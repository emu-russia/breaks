using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Breaknes
{
    public partial class Form1 : Form
    {
        private FamiBoard board = new FamiBoard();
        private Loader loader = new Loader();

        public Form1()
        {
            InitializeComponent();
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            FormAbout about = new FormAbout();
            about.Show();
        }

        private void showDebuggerToolStripMenuItem_Click(object sender, EventArgs e)
        {
            FormDebug debug = new FormDebug();

            debug.SetCpuContext(board.apu.core);

            debug.Show();
        }

        private void loadStateToolStripMenuItem_Click(object sender, EventArgs e)
        {

        }

        private void saveStateToolStripMenuItem_Click(object sender, EventArgs e)
        {

        }

        private void loadROMToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult result = openFileDialog1.ShowDialog();

            if ( result == DialogResult.OK )
            {
                board.cart = loader.LoadNes(openFileDialog1.FileName);

                toolStripStatusLabel1.Text = "Loaded: " + openFileDialog1.FileName;
            }

        }

        private void runToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (!backgroundWorker1.IsBusy)
            {
                backgroundWorker1.RunWorkerAsync();

                toolStripStatusLabel1.Text = "Running";
            }
        }

        private void stopToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (backgroundWorker1.IsBusy)
            {
                backgroundWorker1.CancelAsync();

                toolStripStatusLabel1.Text = "Idle";
            }
        }

        private void resetToolStripMenuItem_Click(object sender, EventArgs e)
        {
            //
            // Stop run
            //

            if (backgroundWorker1.IsBusy)
                backgroundWorker1.CancelAsync();

            
        }

        private void backgroundWorker1_DoWork(object sender, DoWorkEventArgs e)
        {
            while (true)
            {
                board.Clk = ~board.Clk & 1;
            }
        }

    }
}
