namespace GraphFlow
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
            this.loadYedGraphMLToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.generateAndDumpNFLAGCircuiteToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.walkGraphToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.propertyGrid1 = new System.Windows.Forms.PropertyGrid();
            this.menuStrip1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.SuspendLayout();
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(1150, 24);
            this.menuStrip1.TabIndex = 0;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // fileToolStripMenuItem
            // 
            this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.loadYedGraphMLToolStripMenuItem,
            this.generateAndDumpNFLAGCircuiteToolStripMenuItem,
            this.walkGraphToolStripMenuItem,
            this.exitToolStripMenuItem});
            this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            this.fileToolStripMenuItem.Size = new System.Drawing.Size(37, 20);
            this.fileToolStripMenuItem.Text = "File";
            // 
            // loadYedGraphMLToolStripMenuItem
            // 
            this.loadYedGraphMLToolStripMenuItem.Name = "loadYedGraphMLToolStripMenuItem";
            this.loadYedGraphMLToolStripMenuItem.Size = new System.Drawing.Size(204, 22);
            this.loadYedGraphMLToolStripMenuItem.Text = "Load Yed GraphML...";
            this.loadYedGraphMLToolStripMenuItem.Click += new System.EventHandler(this.loadYedGraphMLToolStripMenuItem_Click);
            // 
            // generateAndDumpNFLAGCircuiteToolStripMenuItem
            // 
            this.generateAndDumpNFLAGCircuiteToolStripMenuItem.Name = "generateAndDumpNFLAGCircuiteToolStripMenuItem";
            this.generateAndDumpNFLAGCircuiteToolStripMenuItem.Size = new System.Drawing.Size(204, 22);
            this.generateAndDumpNFLAGCircuiteToolStripMenuItem.Text = "Generate N-FLAG Circuit";
            this.generateAndDumpNFLAGCircuiteToolStripMenuItem.Click += new System.EventHandler(this.generateAndDumpNFLAGCircuiteToolStripMenuItem_Click);
            // 
            // walkGraphToolStripMenuItem
            // 
            this.walkGraphToolStripMenuItem.Name = "walkGraphToolStripMenuItem";
            this.walkGraphToolStripMenuItem.Size = new System.Drawing.Size(204, 22);
            this.walkGraphToolStripMenuItem.Text = "Walk Graph";
            this.walkGraphToolStripMenuItem.Click += new System.EventHandler(this.walkGraphToolStripMenuItem_Click);
            // 
            // exitToolStripMenuItem
            // 
            this.exitToolStripMenuItem.Name = "exitToolStripMenuItem";
            this.exitToolStripMenuItem.Size = new System.Drawing.Size(204, 22);
            this.exitToolStripMenuItem.Text = "Exit";
            this.exitToolStripMenuItem.Click += new System.EventHandler(this.exitToolStripMenuItem_Click);
            // 
            // openFileDialog1
            // 
            this.openFileDialog1.DefaultExt = "graphml";
            this.openFileDialog1.Filter = "yEd Graphml Files|*.graphml|All files|*.*";
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.Location = new System.Drawing.Point(0, 24);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.propertyGrid1);
            this.splitContainer1.Size = new System.Drawing.Size(1150, 542);
            this.splitContainer1.SplitterDistance = 475;
            this.splitContainer1.TabIndex = 1;
            // 
            // propertyGrid1
            // 
            this.propertyGrid1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.propertyGrid1.Location = new System.Drawing.Point(0, 0);
            this.propertyGrid1.Name = "propertyGrid1";
            this.propertyGrid1.Size = new System.Drawing.Size(475, 542);
            this.propertyGrid1.TabIndex = 0;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1150, 566);
            this.Controls.Add(this.splitContainer1);
            this.Controls.Add(this.menuStrip1);
            this.MainMenuStrip = this.menuStrip1;
            this.Name = "Form1";
            this.Text = "GraphFlow Demo";
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.splitContainer1.Panel1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem generateAndDumpNFLAGCircuiteToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem walkGraphToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem loadYedGraphMLToolStripMenuItem;
        private System.Windows.Forms.OpenFileDialog openFileDialog1;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.PropertyGrid propertyGrid1;
    }
}

