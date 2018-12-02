namespace GraphLib
{
    partial class PrintPreviewForm
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
            this.printPreviewCtrl = new System.Windows.Forms.PrintPreviewControl();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.rb_Unscaled = new System.Windows.Forms.RadioButton();
            this.rb_BestFit = new System.Windows.Forms.RadioButton();
            this.rb_Scale = new System.Windows.Forms.RadioButton();
            this.cb_PrintBackground = new System.Windows.Forms.CheckBox();
            this.label3 = new System.Windows.Forms.Label();
            this.cb_Printer = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.cb_Orientation = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.cb_PaperSize = new System.Windows.Forms.ComboBox();
            this.bt_Cancel = new System.Windows.Forms.Button();
            this.bt_print = new System.Windows.Forms.Button();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // printPreviewCtrl
            // 
            this.printPreviewCtrl.BackColor = System.Drawing.SystemColors.ControlLight;
            this.printPreviewCtrl.Dock = System.Windows.Forms.DockStyle.Fill;
            this.printPreviewCtrl.Location = new System.Drawing.Point(0, 0);
            this.printPreviewCtrl.Name = "printPreviewCtrl";
            this.printPreviewCtrl.Size = new System.Drawing.Size(453, 501);
            this.printPreviewCtrl.TabIndex = 1;
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.FixedPanel = System.Windows.Forms.FixedPanel.Panel1;
            this.splitContainer1.IsSplitterFixed = true;
            this.splitContainer1.Location = new System.Drawing.Point(0, 0);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.printPreviewCtrl);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.groupBox1);
            this.splitContainer1.Panel2.Controls.Add(this.cb_PrintBackground);
            this.splitContainer1.Panel2.Controls.Add(this.label3);
            this.splitContainer1.Panel2.Controls.Add(this.cb_Printer);
            this.splitContainer1.Panel2.Controls.Add(this.label2);
            this.splitContainer1.Panel2.Controls.Add(this.cb_Orientation);
            this.splitContainer1.Panel2.Controls.Add(this.label1);
            this.splitContainer1.Panel2.Controls.Add(this.cb_PaperSize);
            this.splitContainer1.Panel2.Controls.Add(this.bt_Cancel);
            this.splitContainer1.Panel2.Controls.Add(this.bt_print);
            this.splitContainer1.Size = new System.Drawing.Size(681, 501);
            this.splitContainer1.SplitterDistance = 453;
            this.splitContainer1.TabIndex = 2;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.rb_Unscaled);
            this.groupBox1.Controls.Add(this.rb_BestFit);
            this.groupBox1.Controls.Add(this.rb_Scale);
            this.groupBox1.Location = new System.Drawing.Point(18, 188);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(93, 93);
            this.groupBox1.TabIndex = 12;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Scaling";
            // 
            // rb_Unscaled
            // 
            this.rb_Unscaled.AutoSize = true;
            this.rb_Unscaled.Location = new System.Drawing.Point(13, 19);
            this.rb_Unscaled.Name = "rb_Unscaled";
            this.rb_Unscaled.Size = new System.Drawing.Size(70, 17);
            this.rb_Unscaled.TabIndex = 8;
            this.rb_Unscaled.TabStop = true;
            this.rb_Unscaled.Text = "Unscaled";
            this.rb_Unscaled.UseVisualStyleBackColor = true;
            this.rb_Unscaled.CheckedChanged += new System.EventHandler(this.rb_Unscaled_CheckedChanged);
            // 
            // rb_BestFit
            // 
            this.rb_BestFit.AutoSize = true;
            this.rb_BestFit.Location = new System.Drawing.Point(13, 65);
            this.rb_BestFit.Name = "rb_BestFit";
            this.rb_BestFit.Size = new System.Drawing.Size(60, 17);
            this.rb_BestFit.TabIndex = 6;
            this.rb_BestFit.TabStop = true;
            this.rb_BestFit.Text = "Best Fit";
            this.rb_BestFit.UseVisualStyleBackColor = true;
            this.rb_BestFit.CheckedChanged += new System.EventHandler(this.rb_BestFit_CheckedChanged);
            // 
            // rb_Scale
            // 
            this.rb_Scale.AutoSize = true;
            this.rb_Scale.Location = new System.Drawing.Point(13, 42);
            this.rb_Scale.Name = "rb_Scale";
            this.rb_Scale.Size = new System.Drawing.Size(52, 17);
            this.rb_Scale.TabIndex = 7;
            this.rb_Scale.TabStop = true;
            this.rb_Scale.Text = "Scale";
            this.rb_Scale.UseVisualStyleBackColor = true;
            this.rb_Scale.CheckedChanged += new System.EventHandler(this.rb_Scale_CheckedChanged);
            // 
            // cb_PrintBackground
            // 
            this.cb_PrintBackground.AutoSize = true;
            this.cb_PrintBackground.Location = new System.Drawing.Point(22, 321);
            this.cb_PrintBackground.Name = "cb_PrintBackground";
            this.cb_PrintBackground.Size = new System.Drawing.Size(108, 17);
            this.cb_PrintBackground.TabIndex = 11;
            this.cb_PrintBackground.Text = "Print Background";
            this.cb_PrintBackground.UseVisualStyleBackColor = true;
            this.cb_PrintBackground.Visible = false;
            this.cb_PrintBackground.CheckedChanged += new System.EventHandler(this.cb_PrintBackground_CheckedChanged);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(19, 29);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(37, 13);
            this.label3.TabIndex = 10;
            this.label3.Text = "Printer";
            // 
            // cb_Printer
            // 
            this.cb_Printer.FormattingEnabled = true;
            this.cb_Printer.Location = new System.Drawing.Point(18, 45);
            this.cb_Printer.Name = "cb_Printer";
            this.cb_Printer.Size = new System.Drawing.Size(195, 21);
            this.cb_Printer.TabIndex = 9;
            this.cb_Printer.SelectedIndexChanged += new System.EventHandler(this.cb_Printer_SelectedIndexChanged);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(19, 134);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(58, 13);
            this.label2.TabIndex = 5;
            this.label2.Text = "Orientation";
            // 
            // cb_Orientation
            // 
            this.cb_Orientation.FormattingEnabled = true;
            this.cb_Orientation.Items.AddRange(new object[] {
            "Portrait",
            "Landscape"});
            this.cb_Orientation.Location = new System.Drawing.Point(18, 150);
            this.cb_Orientation.Name = "cb_Orientation";
            this.cb_Orientation.Size = new System.Drawing.Size(93, 21);
            this.cb_Orientation.TabIndex = 4;
            this.cb_Orientation.SelectedIndexChanged += new System.EventHandler(this.cb_Orientation_SelectedIndexChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(19, 81);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(58, 13);
            this.label1.TabIndex = 3;
            this.label1.Text = "Paper Size";
            // 
            // cb_PaperSize
            // 
            this.cb_PaperSize.FormattingEnabled = true;
            this.cb_PaperSize.Location = new System.Drawing.Point(18, 97);
            this.cb_PaperSize.Name = "cb_PaperSize";
            this.cb_PaperSize.Size = new System.Drawing.Size(93, 21);
            this.cb_PaperSize.TabIndex = 2;
            this.cb_PaperSize.SelectedIndexChanged += new System.EventHandler(this.cb_PaperSize_SelectedIndexChanged);
            // 
            // bt_Cancel
            // 
            this.bt_Cancel.Location = new System.Drawing.Point(118, 450);
            this.bt_Cancel.Name = "bt_Cancel";
            this.bt_Cancel.Size = new System.Drawing.Size(69, 26);
            this.bt_Cancel.TabIndex = 1;
            this.bt_Cancel.Text = "Cancel";
            this.bt_Cancel.UseVisualStyleBackColor = true;
            this.bt_Cancel.Click += new System.EventHandler(this.bt_Cancel_Click);
            // 
            // bt_print
            // 
            this.bt_print.Location = new System.Drawing.Point(22, 450);
            this.bt_print.Name = "bt_print";
            this.bt_print.Size = new System.Drawing.Size(69, 26);
            this.bt_print.TabIndex = 0;
            this.bt_print.Text = "Print";
            this.bt_print.UseVisualStyleBackColor = true;
            this.bt_print.Click += new System.EventHandler(this.bt_print_Click);
            // 
            // PrintPreviewForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(681, 501);
            this.Controls.Add(this.splitContainer1);
            this.MaximumSize = new System.Drawing.Size(697, 537);
            this.MinimumSize = new System.Drawing.Size(697, 537);
            this.Name = "PrintPreviewForm";
            this.Text = "PrintPreviewForm";
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            this.splitContainer1.Panel2.PerformLayout();
            this.splitContainer1.ResumeLayout(false);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.PrintPreviewControl printPreviewCtrl;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.Button bt_Cancel;
        private System.Windows.Forms.Button bt_print;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox cb_PaperSize;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ComboBox cb_Orientation;
        private System.Windows.Forms.RadioButton rb_Scale;
        private System.Windows.Forms.RadioButton rb_BestFit;
        private System.Windows.Forms.RadioButton rb_Unscaled;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.ComboBox cb_Printer;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.CheckBox cb_PrintBackground;
    }
}