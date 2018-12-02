using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using System.Drawing.Drawing2D;
using System.Threading;

namespace PpuTestSuite
{
    public partial class FormAbout : Form
    {
        public FormAbout()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void FormAbout_KeyUp(object sender, KeyEventArgs e)
        {
            if ( e.KeyCode == Keys.Escape)
            {
                Close();
            }
        }

        private void pictureBox1_Click(object sender, EventArgs e)
        {
            backgroundWorker1.RunWorkerAsync();
        }



        private void backgroundWorker1_DoWork(object sender, DoWorkEventArgs e)
        {
            while (!backgroundWorker1.CancellationPending)
            {
                pictureBox1.Image = ImageHelper.RotateImage(pictureBox1.Image, 2.0F);

                Thread.Sleep(50);
            }
        }

    }
}
