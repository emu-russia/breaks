namespace PpuTestSuite
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.viewToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.showPadsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.showClkToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.showResetToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.showPCLKToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.showAllToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.helpToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.aboutToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.showRWDecoderToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.menuStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem,
            this.viewToolStripMenuItem,
            this.helpToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(936, 24);
            this.menuStrip1.TabIndex = 0;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // fileToolStripMenuItem
            // 
            this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.exitToolStripMenuItem});
            this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            this.fileToolStripMenuItem.Size = new System.Drawing.Size(37, 20);
            this.fileToolStripMenuItem.Text = "File";
            // 
            // exitToolStripMenuItem
            // 
            this.exitToolStripMenuItem.Name = "exitToolStripMenuItem";
            this.exitToolStripMenuItem.Size = new System.Drawing.Size(92, 22);
            this.exitToolStripMenuItem.Text = "Exit";
            this.exitToolStripMenuItem.Click += new System.EventHandler(this.exitToolStripMenuItem_Click);
            // 
            // viewToolStripMenuItem
            // 
            this.viewToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.showPadsToolStripMenuItem,
            this.showClkToolStripMenuItem,
            this.showResetToolStripMenuItem,
            this.showPCLKToolStripMenuItem,
            this.showRWDecoderToolStripMenuItem,
            this.toolStripSeparator1,
            this.showAllToolStripMenuItem});
            this.viewToolStripMenuItem.Name = "viewToolStripMenuItem";
            this.viewToolStripMenuItem.Size = new System.Drawing.Size(44, 20);
            this.viewToolStripMenuItem.Text = "View";
            // 
            // showPadsToolStripMenuItem
            // 
            this.showPadsToolStripMenuItem.Name = "showPadsToolStripMenuItem";
            this.showPadsToolStripMenuItem.Size = new System.Drawing.Size(171, 22);
            this.showPadsToolStripMenuItem.Text = "Show Pads";
            this.showPadsToolStripMenuItem.Click += new System.EventHandler(this.showPadsToolStripMenuItem_Click);
            // 
            // showClkToolStripMenuItem
            // 
            this.showClkToolStripMenuItem.Name = "showClkToolStripMenuItem";
            this.showClkToolStripMenuItem.Size = new System.Drawing.Size(171, 22);
            this.showClkToolStripMenuItem.Text = "Show Clk";
            this.showClkToolStripMenuItem.Click += new System.EventHandler(this.showClkToolStripMenuItem_Click);
            // 
            // showResetToolStripMenuItem
            // 
            this.showResetToolStripMenuItem.Name = "showResetToolStripMenuItem";
            this.showResetToolStripMenuItem.Size = new System.Drawing.Size(171, 22);
            this.showResetToolStripMenuItem.Text = "Show Reset";
            this.showResetToolStripMenuItem.Click += new System.EventHandler(this.showResetToolStripMenuItem_Click);
            // 
            // showPCLKToolStripMenuItem
            // 
            this.showPCLKToolStripMenuItem.Name = "showPCLKToolStripMenuItem";
            this.showPCLKToolStripMenuItem.Size = new System.Drawing.Size(171, 22);
            this.showPCLKToolStripMenuItem.Text = "Show Pixel Clock";
            this.showPCLKToolStripMenuItem.Click += new System.EventHandler(this.showPCLKToolStripMenuItem_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(168, 6);
            // 
            // showAllToolStripMenuItem
            // 
            this.showAllToolStripMenuItem.Name = "showAllToolStripMenuItem";
            this.showAllToolStripMenuItem.Size = new System.Drawing.Size(171, 22);
            this.showAllToolStripMenuItem.Text = "Show All";
            this.showAllToolStripMenuItem.Click += new System.EventHandler(this.showAllToolStripMenuItem_Click);
            // 
            // helpToolStripMenuItem
            // 
            this.helpToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.aboutToolStripMenuItem});
            this.helpToolStripMenuItem.Name = "helpToolStripMenuItem";
            this.helpToolStripMenuItem.Size = new System.Drawing.Size(44, 20);
            this.helpToolStripMenuItem.Text = "Help";
            // 
            // aboutToolStripMenuItem
            // 
            this.aboutToolStripMenuItem.Name = "aboutToolStripMenuItem";
            this.aboutToolStripMenuItem.Size = new System.Drawing.Size(107, 22);
            this.aboutToolStripMenuItem.Text = "About";
            this.aboutToolStripMenuItem.Click += new System.EventHandler(this.aboutToolStripMenuItem_Click);
            // 
            // showRWDecoderToolStripMenuItem
            // 
            this.showRWDecoderToolStripMenuItem.Name = "showRWDecoderToolStripMenuItem";
            this.showRWDecoderToolStripMenuItem.Size = new System.Drawing.Size(171, 22);
            this.showRWDecoderToolStripMenuItem.Text = "Show RW Decoder";
            this.showRWDecoderToolStripMenuItem.Click += new System.EventHandler(this.showRWDecoderToolStripMenuItem_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(936, 727);
            this.Controls.Add(this.menuStrip1);
            this.IsMdiContainer = true;
            this.MainMenuStrip = this.menuStrip1;
            this.Name = "Form1";
            this.Text = "PPU Test Suite";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem helpToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem aboutToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem viewToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem showResetToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem showClkToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem showPCLKToolStripMenuItem;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolStripMenuItem showAllToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem showPadsToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem showRWDecoderToolStripMenuItem;
    }
}

