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
    public partial class FormClk : Form
    {
        private Ppu ppu;

        public FormClk(Ppu ppu)
        {
            InitializeComponent();

            this.ppu = ppu;

            textBoxCLKPad.Text = ppu.Pads.CLK.ToString();
            textBoxToggleCounter.Text = ppu.ToggleCounter.ToString();

            ppu.AddListener(PpuListener);
        }

        ~FormClk()
        {
            ppu.RemoveListener(PpuListener);
        }

        /// <summary>
        /// Взывается при изменении внутреннего состояния PPU
        /// </summary>
        /// <param name="sender"></param>
        private void PpuListener(object sender)
        {
            textBoxCLKPad.Text = ppu.Pads.CLK.ToString();
            textBoxCLK.Text = ppu.CLKout.ToString();
            textBoxXCLK.Text = ppu.NotCLKout.ToString();
            textBoxToggleCounter.Text = ppu.ToggleCounter.ToString();
        }

        /// <summary>
        /// Toggle CLK
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button1_Click(object sender, EventArgs e)
        {
            ppu.ToggleClock();

            ppu.NotifyListeners();
        }

        private void FormClk_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Escape)
            {
                Close();
            }
        }
    }
}
