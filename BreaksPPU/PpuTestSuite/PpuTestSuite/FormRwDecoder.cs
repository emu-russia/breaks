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
    public partial class FormRwDecoder : Form
    {
        private Ppu ppu;
        private Image savedImage;

        public FormRwDecoder(Ppu ppu)
        {
            InitializeComponent();

            this.ppu = ppu;

            ppu.AddListener(PpuListener);
        }

        private void FormRwDecoder_Load(object sender, EventArgs e)
        {
            savedImage = pictureBox1.Image;
        }

        ~FormRwDecoder()
        {
            ppu.RemoveListener(PpuListener);
        }

        /// <summary>
        /// Взывается при изменении внутреннего состояния PPU
        /// </summary>
        /// <param name="sender"></param>
        private void PpuListener(object sender)
        {
            UpdateControls();
        }

        private void UpdateControls()
        {
            ppu.RwDecoder();

            textBoxRnW.Text = ppu.GetPad("R/W").ToString();
            textBoxnDBE.Text = ppu.GetPad("/DBE").ToString();

            textBoxXRDInt.Text = ppu.nRDInternal.ToString();
            textBoxXWRInt.Text = ppu.nWRInternal.ToString();

            UpdateImages();
        }

        private void UpdateImages()
        {
        }

        private void button2_Click(object sender, EventArgs e)
        {
            ppu.Pads.RnW = Base.Toggle((int)ppu.Pads.RnW);
            ppu.NotifyListeners();
        }

        private void button14_Click(object sender, EventArgs e)
        {
            ppu.Pads.nDBE = Base.Toggle((int)ppu.Pads.nDBE);
            ppu.NotifyListeners();
        }

        private void FormRwDecoder_KeyDown(object sender, KeyEventArgs e)
        {
            if ( e.KeyCode == Keys.Escape)
            {
                Close();
            }
        }

    }
}
