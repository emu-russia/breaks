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

            textBox1.Text = ppu.CLKin.ToString();
            
            textBox4.Text = ppu.nRES.ToString();
            textBox5.Text = ppu.RESCL.ToString();
            textBox6.Text = ppu.ResetFF.ToString();
        }

        /// <summary>
        /// Toggle CLK
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button1_Click(object sender, EventArgs e)
        {
            ppu.CLKin = Convert.ToInt32(textBox1.Text) & 1;

            ppu.ToggleClock();

            textBox1.Text = ppu.CLKin.ToString();
            textBox2.Text = ppu.CLKout.ToString();
            textBox3.Text = ppu.NotCLKout.ToString();
        }

        /// <summary>
        /// Reset Logic
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button2_Click(object sender, EventArgs e)
        {
            ppu.nRES = Convert.ToInt32(textBox4.Text) & 1;
            ppu.RESCL = Convert.ToInt32(textBox5.Text) & 1;

            ppu.ResetPadLogic();

            textBox8.Text = ppu.RES.ToString();
            textBox7.Text = ppu.RC.ToString();
            textBox6.Text = ppu.ResetFF.ToString();
        }

        /// <summary>
        /// Toggle /RES
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>

        private void button3_Click(object sender, EventArgs e)
        {
            ppu.nRES = Base.Toggle(ppu.nRES);

            textBox4.Text = ppu.nRES.ToString();
        }

        /// <summary>
        /// Toggle RESCL
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button4_Click(object sender, EventArgs e)
        {
            ppu.RESCL = Base.Toggle(ppu.RESCL);

            textBox5.Text = ppu.RESCL.ToString();
        }

        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            FormAbout about = new FormAbout();
            about.ShowDialog();
        }


    }
}
