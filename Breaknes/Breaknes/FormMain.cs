namespace Breaknes
{
    public partial class FormMain : Form
    {
        public FormMain()
        {
            InitializeComponent();
        }

        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            FormAbout about = new FormAbout();
            about.ShowDialog();
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void breaksDebuggerToolStripMenuItem_Click(object sender, EventArgs e)
        {
            FormDebug formDebug = new FormDebug();
            formDebug.Show();
        }
    }
}