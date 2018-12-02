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
    public partial class FormReset : Form
    {
        private Ppu ppu;

        public FormReset(Ppu ppu)
        {
            InitializeComponent();

            this.ppu = ppu;

            textBoxXRES.Text = ppu.Pads.nRES.ToString();
            textBoxRESCL.Text = ppu.RESCL.ToString();
            textBoxResetFF.Text = ppu.ResetFF.ToString();

            ppu.AddListener(PpuListener);
        }

        ~FormReset()
        {
            ppu.RemoveListener(PpuListener);
        }

        /// <summary>
        /// Взывается при изменении внутреннего состояния PPU
        /// </summary>
        /// <param name="sender"></param>
        private void PpuListener(object sender)
        {
            textBoxXRES.Text = ppu.Pads.nRES.ToString();
            textBoxRESCL.Text = ppu.RESCL.ToString();

            textBoxRES.Text = ppu.RES.ToString();
            textBoxRC.Text = ppu.RC.ToString();
            textBoxResetFF.Text = ppu.ResetFF.ToString();
        }

        /// <summary>
        /// Toggle /RES
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button3_Click_1(object sender, EventArgs e)
        {
            ppu.Pads.nRES = Base.Toggle((int)ppu.Pads.nRES);

            ppu.ResetPadLogic();

            ppu.NotifyListeners();
        }

        /// <summary>
        /// Toggle RESCL
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button4_Click_1(object sender, EventArgs e)
        {
            ppu.RESCL = Base.Toggle((int)ppu.RESCL);

            ppu.ResetPadLogic();

            ppu.NotifyListeners();
        }

        private void FormReset_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Escape)
            {
                Close();
            }
        }
    }
}
