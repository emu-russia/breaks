// Эксперименты с PPU 2C02

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace PpuTestSuite
{
    public partial class Form1 : Form
    {
        private Ppu ppu;

        public Form1()
        {
            InitializeComponent();
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            ppu = new Ppu();
            ShowAll();
        }

        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            FormAbout about = new FormAbout();
            about.MdiParent = this;
            about.Show();
        }

        private void showPadsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ShowPads();
        }

        private void showResetToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ShowReset();
        }

        private void showClkToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ShowClk();
        }

        private void showPCLKToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ShowPixelClock();
        }

        private void showRWDecoderToolStripMenuItem_Click(object sender, EventArgs e)
        {

        }

        private void showAllToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ShowAll();
        }

        private void ShowPads()
        {
            FormPads dlg = new FormPads(ppu);
            dlg.MdiParent = this;
            dlg.Show();
        }

        private void ShowReset()
        {
            FormReset dlg = new FormReset(ppu);
            dlg.MdiParent = this;
            dlg.Show();
        }

        private void ShowClk()
        {
            FormClk dlg = new FormClk(ppu);
            dlg.MdiParent = this;
            dlg.Show();
        }

        private void ShowPixelClock()
        {
            FormPixelClock dlg = new FormPixelClock(ppu);
            dlg.MdiParent = this;
            dlg.Show();
        }

        private void ShowRWDecoder()
        {
            FormRwDecoder dlg = new FormRwDecoder(ppu);
            dlg.MdiParent = this;
            dlg.Show();
        }

        private void ShowAll()
        {
            ShowPads();
            ShowReset();
            ShowClk();
            ShowPixelClock();
            ShowRWDecoder();
        }


    }
}
