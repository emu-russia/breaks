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
    public partial class FormDebug : Form
    {
        public FormDebug()
        {
            InitializeComponent();
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void bogusWindowToolStripMenuItem_Click(object sender, EventArgs e)
        {
            FormDebugBogusWindow bogusWindow = new FormDebugBogusWindow();
            bogusWindow.MdiParent = this;
            bogusWindow.Show();
        }
    }
}
