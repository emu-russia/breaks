namespace GraphLib
{
    partial class PlotterGraphSelectCurvesForm
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
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lb_Graphs = new System.Windows.Forms.CheckedListBox();
            this.gB_SelectedGraph = new System.Windows.Forms.GroupBox();
            this.cb_X_AutoScale = new System.Windows.Forms.CheckBox();
            this.tb_GraphName = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.cbDownSampling = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.btn_GraphColor = new System.Windows.Forms.Button();
            this.cb_Y_AutoScale = new System.Windows.Forms.CheckBox();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.label7 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.bt_MinorGridColor = new System.Windows.Forms.Button();
            this.bt_bg_col_bot = new System.Windows.Forms.Button();
            this.label6 = new System.Windows.Forms.Label();
            this.bt_MajorGridColor = new System.Windows.Forms.Button();
            this.label4 = new System.Windows.Forms.Label();
            this.bt_bg_col_top = new System.Windows.Forms.Button();
            this.btn_AutoScaleAll = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.cb_Layout = new System.Windows.Forms.ComboBox();
            this.button1 = new System.Windows.Forms.Button();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.gB_SelectedGraph.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.FixedPanel = System.Windows.Forms.FixedPanel.Panel2;
            this.splitContainer1.Location = new System.Drawing.Point(0, 0);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.lb_Graphs);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.gB_SelectedGraph);
            this.splitContainer1.Panel2.Controls.Add(this.groupBox1);
            this.splitContainer1.Panel2.Controls.Add(this.button1);
            this.splitContainer1.Size = new System.Drawing.Size(395, 431);
            this.splitContainer1.SplitterDistance = 171;
            this.splitContainer1.TabIndex = 0;
            // 
            // lb_Graphs
            // 
            this.lb_Graphs.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lb_Graphs.FormattingEnabled = true;
            this.lb_Graphs.Location = new System.Drawing.Point(0, 0);
            this.lb_Graphs.Name = "lb_Graphs";
            this.lb_Graphs.Size = new System.Drawing.Size(171, 424);
            this.lb_Graphs.TabIndex = 0;
            this.lb_Graphs.SelectedIndexChanged += new System.EventHandler(this.checkedListBox1_SelectedIndexChanged_1);
            // 
            // gB_SelectedGraph
            // 
            this.gB_SelectedGraph.Controls.Add(this.cb_X_AutoScale);
            this.gB_SelectedGraph.Controls.Add(this.tb_GraphName);
            this.gB_SelectedGraph.Controls.Add(this.label3);
            this.gB_SelectedGraph.Controls.Add(this.cbDownSampling);
            this.gB_SelectedGraph.Controls.Add(this.label2);
            this.gB_SelectedGraph.Controls.Add(this.btn_GraphColor);
            this.gB_SelectedGraph.Controls.Add(this.cb_Y_AutoScale);
            this.gB_SelectedGraph.Location = new System.Drawing.Point(6, 232);
            this.gB_SelectedGraph.Name = "gB_SelectedGraph";
            this.gB_SelectedGraph.Size = new System.Drawing.Size(206, 158);
            this.gB_SelectedGraph.TabIndex = 6;
            this.gB_SelectedGraph.TabStop = false;
            this.gB_SelectedGraph.Text = "Selected Graph Options";
            this.gB_SelectedGraph.Visible = false;
            // 
            // cb_X_AutoScale
            // 
            this.cb_X_AutoScale.AutoSize = true;
            this.cb_X_AutoScale.Location = new System.Drawing.Point(12, 102);
            this.cb_X_AutoScale.Name = "cb_X_AutoScale";
            this.cb_X_AutoScale.Size = new System.Drawing.Size(93, 17);
            this.cb_X_AutoScale.TabIndex = 8;
            this.cb_X_AutoScale.Text = "X AutoScaling";
            this.cb_X_AutoScale.UseVisualStyleBackColor = true;
            this.cb_X_AutoScale.CheckedChanged += new System.EventHandler(this.cb_X_AutoScale_CheckedChanged);
            // 
            // tb_GraphName
            // 
            this.tb_GraphName.Location = new System.Drawing.Point(12, 24);
            this.tb_GraphName.Name = "tb_GraphName";
            this.tb_GraphName.Size = new System.Drawing.Size(167, 20);
            this.tb_GraphName.TabIndex = 7;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(52, 133);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(76, 13);
            this.label3.TabIndex = 6;
            this.label3.Text = "Downsampling";
            // 
            // cbDownSampling
            // 
            this.cbDownSampling.FormattingEnabled = true;
            this.cbDownSampling.Items.AddRange(new object[] {
            "1",
            "2",
            "3",
            "4",
            "5",
            "6"});
            this.cbDownSampling.Location = new System.Drawing.Point(7, 130);
            this.cbDownSampling.Name = "cbDownSampling";
            this.cbDownSampling.Size = new System.Drawing.Size(39, 21);
            this.cbDownSampling.TabIndex = 5;
            this.cbDownSampling.Text = "1";
            this.cbDownSampling.SelectedIndexChanged += new System.EventHandler(this.OnDownsamplingChanged);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(57, 55);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(63, 13);
            this.label2.TabIndex = 4;
            this.label2.Text = "Graph Color";
            // 
            // btn_GraphColor
            // 
            this.btn_GraphColor.Location = new System.Drawing.Point(11, 50);
            this.btn_GraphColor.Name = "btn_GraphColor";
            this.btn_GraphColor.Size = new System.Drawing.Size(26, 23);
            this.btn_GraphColor.TabIndex = 3;
            this.btn_GraphColor.UseVisualStyleBackColor = true;
            this.btn_GraphColor.Click += new System.EventHandler(this.btn_GraphColor_Click);
            // 
            // cb_Y_AutoScale
            // 
            this.cb_Y_AutoScale.AutoSize = true;
            this.cb_Y_AutoScale.Location = new System.Drawing.Point(12, 79);
            this.cb_Y_AutoScale.Name = "cb_Y_AutoScale";
            this.cb_Y_AutoScale.Size = new System.Drawing.Size(93, 17);
            this.cb_Y_AutoScale.TabIndex = 2;
            this.cb_Y_AutoScale.Text = "Y AutoScaling";
            this.cb_Y_AutoScale.UseVisualStyleBackColor = true;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.label7);
            this.groupBox1.Controls.Add(this.label5);
            this.groupBox1.Controls.Add(this.bt_MinorGridColor);
            this.groupBox1.Controls.Add(this.bt_bg_col_bot);
            this.groupBox1.Controls.Add(this.label6);
            this.groupBox1.Controls.Add(this.bt_MajorGridColor);
            this.groupBox1.Controls.Add(this.label4);
            this.groupBox1.Controls.Add(this.bt_bg_col_top);
            this.groupBox1.Controls.Add(this.btn_AutoScaleAll);
            this.groupBox1.Controls.Add(this.label1);
            this.groupBox1.Controls.Add(this.cb_Layout);
            this.groupBox1.Location = new System.Drawing.Point(6, 5);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(206, 221);
            this.groupBox1.TabIndex = 4;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "General Options";
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(57, 194);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(82, 13);
            this.label7.TabIndex = 10;
            this.label7.Text = "Minor Grid Color";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(57, 136);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(128, 13);
            this.label5.TabIndex = 8;
            this.label5.Text = "Background Color Bottom";
            // 
            // bt_MinorGridColor
            // 
            this.bt_MinorGridColor.Location = new System.Drawing.Point(11, 189);
            this.bt_MinorGridColor.Name = "bt_MinorGridColor";
            this.bt_MinorGridColor.Size = new System.Drawing.Size(26, 23);
            this.bt_MinorGridColor.TabIndex = 9;
            this.bt_MinorGridColor.UseVisualStyleBackColor = true;
            this.bt_MinorGridColor.Click += new System.EventHandler(this.bt_MinorGridColor_Click);
            // 
            // bt_bg_col_bot
            // 
            this.bt_bg_col_bot.Location = new System.Drawing.Point(11, 131);
            this.bt_bg_col_bot.Name = "bt_bg_col_bot";
            this.bt_bg_col_bot.Size = new System.Drawing.Size(26, 23);
            this.bt_bg_col_bot.TabIndex = 7;
            this.bt_bg_col_bot.UseVisualStyleBackColor = true;
            this.bt_bg_col_bot.Click += new System.EventHandler(this.bt_bg_col_bot_Click);
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(57, 165);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(82, 13);
            this.label6.TabIndex = 8;
            this.label6.Text = "Major Grid Color";
            // 
            // bt_MajorGridColor
            // 
            this.bt_MajorGridColor.Location = new System.Drawing.Point(11, 160);
            this.bt_MajorGridColor.Name = "bt_MajorGridColor";
            this.bt_MajorGridColor.Size = new System.Drawing.Size(26, 23);
            this.bt_MajorGridColor.TabIndex = 7;
            this.bt_MajorGridColor.UseVisualStyleBackColor = true;
            this.bt_MajorGridColor.Click += new System.EventHandler(this.bt_MajorGridColor_Click);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(57, 107);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(114, 13);
            this.label4.TabIndex = 6;
            this.label4.Text = "Background Color Top";
            // 
            // bt_bg_col_top
            // 
            this.bt_bg_col_top.Location = new System.Drawing.Point(11, 102);
            this.bt_bg_col_top.Name = "bt_bg_col_top";
            this.bt_bg_col_top.Size = new System.Drawing.Size(26, 23);
            this.bt_bg_col_top.TabIndex = 5;
            this.bt_bg_col_top.UseVisualStyleBackColor = true;
            this.bt_bg_col_top.Click += new System.EventHandler(this.bt_bg_col_top_Click);
            // 
            // btn_AutoScaleAll
            // 
            this.btn_AutoScaleAll.Location = new System.Drawing.Point(11, 69);
            this.btn_AutoScaleAll.Name = "btn_AutoScaleAll";
            this.btn_AutoScaleAll.Size = new System.Drawing.Size(167, 25);
            this.btn_AutoScaleAll.TabIndex = 4;
            this.btn_AutoScaleAll.Text = "Auto Scale All";
            this.btn_AutoScaleAll.UseVisualStyleBackColor = true;
            this.btn_AutoScaleAll.Click += new System.EventHandler(this.OnButtonAutoScallOnClicked);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(9, 26);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(39, 13);
            this.label1.TabIndex = 3;
            this.label1.Text = "Layout";
            // 
            // cb_Layout
            // 
            this.cb_Layout.FormattingEnabled = true;
            this.cb_Layout.Items.AddRange(new object[] {
            "Normal",
            "Stacked",
            "Tiles - Fill Vertical",
            "Tiles - Fill Horizontal",
            "Vertically"});
            this.cb_Layout.Location = new System.Drawing.Point(11, 42);
            this.cb_Layout.Name = "cb_Layout";
            this.cb_Layout.Size = new System.Drawing.Size(168, 21);
            this.cb_Layout.TabIndex = 2;
            this.cb_Layout.Text = "Select";
            this.cb_Layout.SelectedIndexChanged += new System.EventHandler(this.comboBox1_SelectedIndexChanged);
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(66, 396);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(68, 23);
            this.button1.TabIndex = 0;
            this.button1.Text = "Exit";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // PlotterGraphSelectCurvesForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(395, 431);
            this.Controls.Add(this.splitContainer1);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.MinimumSize = new System.Drawing.Size(16, 246);
            this.Name = "PlotterGraphSelectCurvesForm";
            this.Text = "Graph Properties";
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            this.splitContainer1.ResumeLayout(false);
            this.gB_SelectedGraph.ResumeLayout(false);
            this.gB_SelectedGraph.PerformLayout();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.CheckedListBox lb_Graphs;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox cb_Layout;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button btn_GraphColor;
        private System.Windows.Forms.CheckBox cb_Y_AutoScale;
        private System.Windows.Forms.Button btn_AutoScaleAll;
        private System.Windows.Forms.GroupBox gB_SelectedGraph;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.ComboBox cbDownSampling;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Button bt_bg_col_top;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Button bt_bg_col_bot;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Button bt_MinorGridColor;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Button bt_MajorGridColor;
        private System.Windows.Forms.TextBox tb_GraphName;
        private System.Windows.Forms.CheckBox cb_X_AutoScale;
    }
}