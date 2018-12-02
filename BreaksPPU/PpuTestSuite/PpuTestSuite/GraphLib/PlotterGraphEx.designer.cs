namespace GraphLib
{
    partial class PlotterDisplayEx
    {
       
        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

      

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(PlotterDisplayEx));
            this.tb1 = new System.Windows.Forms.ToolBar();
            this.tbbSave = new System.Windows.Forms.ToolBarButton();
            this.tbbOpen = new System.Windows.Forms.ToolBarButton();
            this.tbbSeparator3 = new System.Windows.Forms.ToolBarButton();
            this.tbbPrint = new System.Windows.Forms.ToolBarButton();
            this.toolBarButton2 = new System.Windows.Forms.ToolBarButton();
            this.imgList1 = new System.Windows.Forms.ImageList(this.components);
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lb_Position = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.hScrollBar2 = new System.Windows.Forms.HScrollBar();
            this.hScrollBar1 = new System.Windows.Forms.HScrollBar();
            this.contextMenuStrip1 = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.selectGraphsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.panel1 = new System.Windows.Forms.Panel();
            this.gPane = new GraphLib.PlotterGraphPaneEx();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.contextMenuStrip1.SuspendLayout();
            this.panel1.SuspendLayout();
            this.SuspendLayout();
            // 
            // tb1
            // 
            this.tb1.Appearance = System.Windows.Forms.ToolBarAppearance.Flat;
            this.tb1.Buttons.AddRange(new System.Windows.Forms.ToolBarButton[] {
            this.tbbSave,
            this.tbbOpen,
            this.tbbSeparator3,
            this.tbbPrint,
            this.toolBarButton2});
            this.tb1.ButtonSize = new System.Drawing.Size(16, 16);
            this.tb1.Divider = false;
            this.tb1.Dock = System.Windows.Forms.DockStyle.None;
            this.tb1.DropDownArrows = true;
            this.tb1.ImageList = this.imgList1;
            this.tb1.Location = new System.Drawing.Point(11, 5);
            this.tb1.Name = "tb1";
            this.tb1.ShowToolTips = true;
            this.tb1.Size = new System.Drawing.Size(80, 26);
            this.tb1.TabIndex = 1;
            this.tb1.ButtonClick += new System.Windows.Forms.ToolBarButtonClickEventHandler(this.tb1_ButtonClick);
            // 
            // tbbSave
            // 
            this.tbbSave.ImageIndex = 0;
            this.tbbSave.Name = "tbbSave";
            this.tbbSave.Tag = "play";
            // 
            // tbbOpen
            // 
            this.tbbOpen.ImageIndex = 1;
            this.tbbOpen.Name = "tbbOpen";
            this.tbbOpen.Tag = "stop";
            // 
            // tbbSeparator3
            // 
            this.tbbSeparator3.Name = "tbbSeparator3";
            this.tbbSeparator3.Style = System.Windows.Forms.ToolBarButtonStyle.Separator;
            // 
            // tbbPrint
            // 
            this.tbbPrint.ImageIndex = 3;
            this.tbbPrint.Name = "tbbPrint";
            this.tbbPrint.Tag = "print";
            // 
            // toolBarButton2
            // 
            this.toolBarButton2.Name = "toolBarButton2";
            this.toolBarButton2.Style = System.Windows.Forms.ToolBarButtonStyle.Separator;
            // 
            // imgList1
            // 
            this.imgList1.ImageStream = ((System.Windows.Forms.ImageListStreamer)(resources.GetObject("imgList1.ImageStream")));
            this.imgList1.TransparentColor = System.Drawing.Color.Transparent;
            this.imgList1.Images.SetKeyName(0, "media-playback-start.png");
            this.imgList1.Images.SetKeyName(1, "media-playback-stop.png");
            this.imgList1.Images.SetKeyName(2, "media-playback-pause.png");
            this.imgList1.Images.SetKeyName(3, "printer.png");
            // 
            // splitContainer1
            // 
            this.splitContainer1.BackColor = System.Drawing.SystemColors.Control;
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.FixedPanel = System.Windows.Forms.FixedPanel.Panel1;
            this.splitContainer1.IsSplitterFixed = true;
            this.splitContainer1.Location = new System.Drawing.Point(0, 0);
            this.splitContainer1.Name = "splitContainer1";
            this.splitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.BackColor = System.Drawing.SystemColors.ControlDarkDark;
            this.splitContainer1.Panel1.Controls.Add(this.tb1);
            this.splitContainer1.Panel1.Controls.Add(this.panel1);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.BackColor = System.Drawing.Color.Transparent;
            this.splitContainer1.Panel2.Controls.Add(this.gPane);
            this.splitContainer1.Size = new System.Drawing.Size(598, 339);
            this.splitContainer1.SplitterDistance = 34;
            this.splitContainer1.TabIndex = 2;
            this.splitContainer1.TabStop = false;
            // 
            // lb_Position
            // 
            this.lb_Position.AutoSize = true;
            this.lb_Position.ForeColor = System.Drawing.SystemColors.ControlLightLight;
            this.lb_Position.Location = new System.Drawing.Point(6, 8);
            this.lb_Position.Name = "lb_Position";
            this.lb_Position.Size = new System.Drawing.Size(44, 13);
            this.lb_Position.TabIndex = 3;
            this.lb_Position.Text = "Position";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.ForeColor = System.Drawing.SystemColors.ControlLightLight;
            this.label1.Location = new System.Drawing.Point(180, 8);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(85, 13);
            this.label1.TabIndex = 2;
            this.label1.Text = "Playback Speed";
            // 
            // hScrollBar2
            // 
            this.hScrollBar2.Location = new System.Drawing.Point(268, 10);
            this.hScrollBar2.Maximum = 10000;
            this.hScrollBar2.Name = "hScrollBar2";
            this.hScrollBar2.Size = new System.Drawing.Size(111, 10);
            this.hScrollBar2.TabIndex = 6;
            this.hScrollBar2.Value = 1;
            this.hScrollBar2.Scroll += new System.Windows.Forms.ScrollEventHandler(this.OnScrollBarSpeedScroll);
            // 
            // hScrollBar1
            // 
            this.hScrollBar1.Location = new System.Drawing.Point(57, 10);
            this.hScrollBar1.Maximum = 10000;
            this.hScrollBar1.Name = "hScrollBar1";
            this.hScrollBar1.Size = new System.Drawing.Size(118, 10);
            this.hScrollBar1.TabIndex = 4;
            this.hScrollBar1.Scroll += new System.Windows.Forms.ScrollEventHandler(this.OnScrollbarScroll);
            // 
            // contextMenuStrip1
            // 
            this.contextMenuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.selectGraphsToolStripMenuItem,
            this.toolStripSeparator1});
            this.contextMenuStrip1.Name = "contextMenuStrip1";
            this.contextMenuStrip1.Size = new System.Drawing.Size(117, 32);
            // 
            // selectGraphsToolStripMenuItem
            // 
            this.selectGraphsToolStripMenuItem.Name = "selectGraphsToolStripMenuItem";
            this.selectGraphsToolStripMenuItem.Size = new System.Drawing.Size(116, 22);
            this.selectGraphsToolStripMenuItem.Text = "Options";
            this.selectGraphsToolStripMenuItem.Click += new System.EventHandler(this.selectGraphsToolStripMenuItem_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(113, 6);
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.lb_Position);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Controls.Add(this.hScrollBar1);
            this.panel1.Controls.Add(this.hScrollBar2);
            this.panel1.Location = new System.Drawing.Point(99, 3);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(496, 28);
            this.panel1.TabIndex = 7;
            // 
            // gPane
            // 
            this.gPane.Dock = System.Windows.Forms.DockStyle.Fill;
            this.gPane.Location = new System.Drawing.Point(0, 0);
            this.gPane.Name = "gPane";
            this.gPane.Size = new System.Drawing.Size(598, 301);
            this.gPane.TabIndex = 1;
            // 
            // PlotterDisplayEx
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Transparent;
            this.ContextMenuStrip = this.contextMenuStrip1;
            this.Controls.Add(this.splitContainer1);
            this.Name = "PlotterDisplayEx";
            this.Size = new System.Drawing.Size(598, 339);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel1.PerformLayout();
            this.splitContainer1.Panel2.ResumeLayout(false);
            this.splitContainer1.ResumeLayout(false);
            this.contextMenuStrip1.ResumeLayout(false);
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ToolBar tb1;
        private System.Windows.Forms.ToolBarButton tbbSeparator3;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.ToolBarButton tbbSave;
        private System.Windows.Forms.ToolBarButton tbbOpen;
        private System.Windows.Forms.HScrollBar hScrollBar1;
        private PlotterGraphPaneEx gPane;
        private System.Windows.Forms.HScrollBar hScrollBar2;
        private System.Windows.Forms.Label lb_Position;
        private System.Windows.Forms.Label label1;
        public System.Windows.Forms.ContextMenuStrip contextMenuStrip1;
        private System.Windows.Forms.ToolStripMenuItem selectGraphsToolStripMenuItem;
        private System.Windows.Forms.ImageList imgList1;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolBarButton tbbPrint;
        private System.Windows.Forms.ToolBarButton toolBarButton2;
        private System.Windows.Forms.Panel panel1;

    }
}
