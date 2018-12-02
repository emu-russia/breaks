namespace PpuTestSuite
{
    partial class FormClk
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FormClk));
            this.button1 = new System.Windows.Forms.Button();
            this.textBoxXCLK = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.textBoxCLK = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.textBoxCLKPad = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.textBoxToggleCounter = new System.Windows.Forms.TextBox();
            this.label4 = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.SuspendLayout();
            // 
            // button1
            // 
            this.button1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.button1.Image = ((System.Drawing.Image)(resources.GetObject("button1.Image")));
            this.button1.Location = new System.Drawing.Point(16, 224);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(75, 30);
            this.button1.TabIndex = 15;
            this.button1.Text = "Toggle";
            this.button1.TextImageRelation = System.Windows.Forms.TextImageRelation.ImageBeforeText;
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // textBoxXCLK
            // 
            this.textBoxXCLK.BackColor = System.Drawing.Color.LightCoral;
            this.textBoxXCLK.Location = new System.Drawing.Point(593, 57);
            this.textBoxXCLK.Name = "textBoxXCLK";
            this.textBoxXCLK.ReadOnly = true;
            this.textBoxXCLK.Size = new System.Drawing.Size(100, 20);
            this.textBoxXCLK.TabIndex = 14;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(537, 60);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(50, 13);
            this.label3.TabIndex = 13;
            this.label3.Text = "/CLK out";
            // 
            // textBoxCLK
            // 
            this.textBoxCLK.BackColor = System.Drawing.Color.LightCoral;
            this.textBoxCLK.Location = new System.Drawing.Point(593, 16);
            this.textBoxCLK.Name = "textBoxCLK";
            this.textBoxCLK.ReadOnly = true;
            this.textBoxCLK.Size = new System.Drawing.Size(100, 20);
            this.textBoxCLK.TabIndex = 12;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(542, 19);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(45, 13);
            this.label2.TabIndex = 11;
            this.label2.Text = "CLK out";
            // 
            // textBoxCLKPad
            // 
            this.textBoxCLKPad.BackColor = System.Drawing.Color.GreenYellow;
            this.textBoxCLKPad.Location = new System.Drawing.Point(16, 198);
            this.textBoxCLKPad.Name = "textBoxCLKPad";
            this.textBoxCLKPad.ReadOnly = true;
            this.textBoxCLKPad.Size = new System.Drawing.Size(78, 20);
            this.textBoxCLKPad.TabIndex = 10;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.label1.Location = new System.Drawing.Point(12, 168);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(157, 24);
            this.label1.TabIndex = 9;
            this.label1.Text = "External CLK Pad";
            // 
            // pictureBox1
            // 
            this.pictureBox1.Image = ((System.Drawing.Image)(resources.GetObject("pictureBox1.Image")));
            this.pictureBox1.Location = new System.Drawing.Point(12, 12);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(510, 180);
            this.pictureBox1.TabIndex = 8;
            this.pictureBox1.TabStop = false;
            // 
            // textBoxToggleCounter
            // 
            this.textBoxToggleCounter.BackColor = System.Drawing.SystemColors.ControlLight;
            this.textBoxToggleCounter.Location = new System.Drawing.Point(402, 198);
            this.textBoxToggleCounter.Name = "textBoxToggleCounter";
            this.textBoxToggleCounter.ReadOnly = true;
            this.textBoxToggleCounter.Size = new System.Drawing.Size(100, 20);
            this.textBoxToggleCounter.TabIndex = 17;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(293, 201);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(103, 13);
            this.label4.TabIndex = 16;
            this.label4.Text = "CLK Toggle Counter";
            // 
            // FormClk
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(703, 266);
            this.Controls.Add(this.textBoxToggleCounter);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.button1);
            this.Controls.Add(this.textBoxXCLK);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.textBoxCLK);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.textBoxCLKPad);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.pictureBox1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.SizableToolWindow;
            this.KeyPreview = true;
            this.Name = "FormClk";
            this.Text = "Clk Pad";
            this.KeyDown += new System.Windows.Forms.KeyEventHandler(this.FormClk_KeyDown);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.TextBox textBoxXCLK;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.TextBox textBoxCLK;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox textBoxCLKPad;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.TextBox textBoxToggleCounter;
        private System.Windows.Forms.Label label4;
    }
}