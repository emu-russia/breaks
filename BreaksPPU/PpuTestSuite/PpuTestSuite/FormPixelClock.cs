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
    public partial class FormPixelClock : Form
    {
        private Ppu ppu;
        private Image savedImage;

        public FormPixelClock(Ppu ppu)
        {
            InitializeComponent();

            this.ppu = ppu;

            ppu.AddListener(PpuListener);
        }

        private void FormPixelClock_Load(object sender, EventArgs e)
        {
            savedImage = pictureBox1.Image;
        }

        ~FormPixelClock()
        {
            ppu.RemoveListener(PpuListener);
        }

        /// <summary>
        /// Взывается при изменении внутреннего состояния PPU
        /// </summary>
        /// <param name="sender"></param>
        private void PpuListener(object sender)
        {
            ppu.PixelClockLogic();

            UpdateControls();
        }

        private void UpdateControls ()
        {
            textBoxPCLKLatch0.Text = ppu.PCLK_Latch[0].ToString();
            textBoxPCLKLatch1.Text = ppu.PCLK_Latch[1].ToString();
            textBoxPCLKLatch2.Text = ppu.PCLK_Latch[2].ToString();
            textBoxPCLKLatch3.Text = ppu.PCLK_Latch[3].ToString();

            textBoxPCLK.Text = ppu.PCLK.ToString();
            textBoxXPCLK.Text = ppu.nPCLK.ToString();

            textBoxPCLKCounter.Text = ppu.PCLK_Counter.ToString();

            textBoxRES.Text = ppu.RES.ToString();

            UpdateImages();

            if (ppu.RES != null)
            {
                labelWarning.Visible = ppu.RES != 0;
            }
        }

        private void UpdateImages()
        {
            List<Rectangle> rects = new List<Rectangle>();
            List<Color> colors = new List<Color>();

            Color colorRed = Color.FromArgb(127, 255, 0, 0);
            Color colorGreen = Color.FromArgb(127, 0, 255, 0);

            rects.Add (new Rectangle(420, 90, 20, 20));
            colors.Add(ppu.PCLK_Latch[0] != 0 ? colorRed : colorGreen );

            rects.Add(new Rectangle(320, 70, 20, 20));
            colors.Add(ppu.PCLK_Latch[1] != 0 ? colorRed : colorGreen );

            rects.Add(new Rectangle(250, 75, 20, 20));
            colors.Add(ppu.PCLK_Latch[2] != 0 ? colorRed : colorGreen );

            rects.Add(new Rectangle(228, 190, 20, 20));
            colors.Add(ppu.PCLK_Latch[3] != 0 ? colorRed : colorGreen );

            pictureBox1.Image = ImageHelper.HighlightRect(savedImage, rects.ToArray(), colors.ToArray());
        }

        private void FormPixelClock_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Escape)
            {
                Close();
            }
        }
    }
}
