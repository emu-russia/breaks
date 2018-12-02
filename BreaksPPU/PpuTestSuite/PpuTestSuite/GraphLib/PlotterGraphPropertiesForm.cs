using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

 
/* Copyright (c) 2008-2014 DI Zimmermann Stephan (stefan.zimmermann@tele2.at)
 *   
 * Permission is hereby granted, free of charge, to any person obtaining a copy 
 * of this software and associated documentation files (the "Software"), to 
 * deal in the Software without restriction, including without limitation the 
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
 * sell copies of the Software, and to permit persons to whom the Software is 
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in 
 * all copies or substantial portions of the Software. 
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
 * THE SOFTWARE.
 */

 
namespace GraphLib
{
    public partial class PlotterGraphSelectCurvesForm : Form
    {
        private int selectetGraphIndex = -1;

        private PlotterGraphPaneEx gpane = null;

        public PlotterGraphSelectCurvesForm()
        {
            InitializeComponent();
            FormClosing += new FormClosingEventHandler(OnFormClosing);
            lb_Graphs.SelectedIndexChanged += new EventHandler(OnSelectedGraphIndexChanged);
            VisibleChanged += new EventHandler(OnVisibleChanged);
            tb_GraphName.TextChanged += new EventHandler(tb_GraphName_TextChanged);
        }

        void tb_GraphName_TextChanged(object sender, EventArgs e)
        {
            if (selectetGraphIndex >= 0 && selectetGraphIndex < gpane.Sources.Count)
            {
                DataSource src = gpane.Sources[selectetGraphIndex];
                String Text = tb_GraphName.Text;

                if (String.IsNullOrEmpty(Text) == false)
                {
                    src.Name = Text;
                    gpane.Invalidate();
                }
            }
        }

        public PlotterGraphPaneEx GraphPanel
        {
            set
            {
                gpane = value;
                if (gpane != null)
                {
                    this.lb_Graphs.Items.Clear();

                    foreach (DataSource s in gpane.Sources)
                    {
                        if (s.Active)
                        {
                            this.lb_Graphs.Items.Add(s.Name, CheckState.Checked);
                        }
                        else
                        {
                            this.lb_Graphs.Items.Add(s.Name, CheckState.Unchecked);
                        }
                    }

                    UpdateAllCheckedState();
                }
            }
        }

        void UpdateAllCheckedState()
        {
            int AutoScaleOn = 0;

            foreach (DataSource src in gpane.Sources)
            {
                if (src.AutoScaleY)
                {
                    AutoScaleOn++;
                }
            }

            if (AutoScaleOn == 0)
            {
                btn_AutoScaleAll.Visible = true;
                btn_AutoScaleAll.Text = "Auto Y-Scale all Graphs";
            }            
            else
            {
                btn_AutoScaleAll.Visible = true;
                btn_AutoScaleAll.Text = "Normal Y-Scale all Graphs";
            }


        }

        void OnVisibleChanged(object sender, EventArgs e)
        {
            if (this.Visible == true)
            {
                selectetGraphIndex = -1;
                gB_SelectedGraph.Visible = false;

                if (gpane != null)
                {
                    UpdateAllCheckedState();                     

                    if (gpane.layout == PlotterGraphPaneEx.LayoutMode.NORMAL)
                    {
                        cb_Layout.SelectedIndex = 0;
                    }
                    else if (gpane.layout == PlotterGraphPaneEx.LayoutMode.STACKED)
                    {
                        cb_Layout.SelectedIndex = 1;
                    }
                    else if (gpane.layout == PlotterGraphPaneEx.LayoutMode.TILES_HOR)
                    {
                        cb_Layout.SelectedIndex = 2;
                    }
                    else if (gpane.layout == PlotterGraphPaneEx.LayoutMode.TILES_VER)
                    {
                        cb_Layout.SelectedIndex = 3;
                    }
                    else if (gpane.layout == PlotterGraphPaneEx.LayoutMode.VERTICAL_ARRANGED)
                    {
                        cb_Layout.SelectedIndex = 4;
                    }

                    bt_bg_col_top.BackColor = gpane.BgndColorTop;
                    bt_bg_col_bot.BackColor = gpane.BgndColorBot;
                    bt_MajorGridColor.BackColor = gpane.MajorGridColor;
                    bt_MinorGridColor.BackColor = gpane.MinorGridColor;

                }
            }
        }

            
        void OnSelectedGraphIndexChanged(object sender, EventArgs e)
        {
            if (gpane != null)
            {
                for (int i = 0; i < gpane.Sources.Count; i++)
                {
                    if (lb_Graphs.CheckedIndices.Contains(i))
                    {
                        gpane.Sources[i].Active = true;
                    }
                    else
                    {
                        gpane.Sources[i].Active = false;
                    }
                }
                gpane.Invalidate();
            }
        }

        void OnFormClosing(object sender, FormClosingEventArgs e)
        {
            this.Hide();
            e.Cancel = true;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            this.Hide();
        }
      
        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (cb_Layout.SelectedIndex == 0)
            {
                gpane.layout = PlotterGraphPaneEx.LayoutMode.NORMAL;
            }
            if (cb_Layout.SelectedIndex == 1)
            {
                gpane.layout = PlotterGraphPaneEx.LayoutMode.STACKED;
            }
          
            if (cb_Layout.SelectedIndex == 2)
            {
                gpane.layout = PlotterGraphPaneEx.LayoutMode.TILES_VER;
            }
            if (cb_Layout.SelectedIndex == 3)
            {
                gpane.layout = PlotterGraphPaneEx.LayoutMode.TILES_HOR;
            }
            if (cb_Layout.SelectedIndex == 4)
            {
                gpane.layout = PlotterGraphPaneEx.LayoutMode.VERTICAL_ARRANGED;
            }
            gpane.Invalidate();
        }
       
        private void checkedListBox1_SelectedIndexChanged_1(object sender, EventArgs e)
        {
            selectetGraphIndex = lb_Graphs.SelectedIndex;

            UpdateSelectedGraphInfo();
            gB_SelectedGraph.Visible = true;
        }

        private void UpdateSelectedGraphInfo()
        {
            if (selectetGraphIndex >= 0 && selectetGraphIndex < gpane.Sources.Count)
            {
                DataSource src = gpane.Sources[selectetGraphIndex];
                btn_GraphColor.BackColor = src.GraphColor;

                cb_Y_AutoScale.Checked = src.AutoScaleY;
                cb_X_AutoScale.Checked = src.AutoScaleX;

                cbDownSampling.SelectedIndex = (src.Downsampling - 1);
                tb_GraphName.Text = src.Name;
            }
        }

        private void btn_GraphColor_Click(object sender, EventArgs e)
        {
            if (selectetGraphIndex >= 0 && selectetGraphIndex < gpane.Sources.Count)
            {
                DataSource src = gpane.Sources[selectetGraphIndex];
                ColorDialog d = new ColorDialog();
                if (d.ShowDialog() == DialogResult.OK)
                {
                    btn_GraphColor.BackColor = d.Color;
                    src.GraphColor = d.Color;
                    gpane.Invalidate();
                }                
            }
        }

      

        private void OnButtonAutoScallOnClicked(object sender, EventArgs e)
        {
            int AutoScaleOn = 0;

            foreach (DataSource src in gpane.Sources)
            {
                if (src.AutoScaleY)
                {
                    AutoScaleOn++;
                }
            }

            if (AutoScaleOn == 0)
            {
                btn_AutoScaleAll.Text = "Normal scale for all graphs";
                foreach (DataSource src in gpane.Sources)
                {
                    src.AutoScaleY = true;
                }                
            }
            else
            {
                btn_AutoScaleAll.Text = "Auto scale for all graphs";
                foreach (DataSource src in gpane.Sources)
                {
                    src.AutoScaleY = false;
                }
            }
            UpdateSelectedGraphInfo();
            gpane.Invalidate();
        }

        private void OnDownsamplingChanged(object sender, EventArgs e)
        {
            if (selectetGraphIndex >= 0 && selectetGraphIndex < gpane.Sources.Count)
            {
                DataSource src = gpane.Sources[selectetGraphIndex];

                src.Downsampling = (cbDownSampling.SelectedIndex + 1);
            }

            gpane.Invalidate();
        }

        private void bt_bg_col_top_Click(object sender, EventArgs e)
        {
             ColorDialog d = new ColorDialog();
             if (d.ShowDialog() == DialogResult.OK)
             {
                 bt_bg_col_top.BackColor = d.Color;
                 gpane.BgndColorTop = d.Color;
                 
                 gpane.Invalidate();
             }
        }

        private void bt_bg_col_bot_Click(object sender, EventArgs e)
        {
            ColorDialog d = new ColorDialog();
            if (d.ShowDialog() == DialogResult.OK)
            {
                bt_bg_col_bot.BackColor = d.Color;
                gpane.BgndColorBot = d.Color;
                gpane.Invalidate();
            }
        }

        private void bt_MajorGridColor_Click(object sender, EventArgs e)
        {
            ColorDialog d = new ColorDialog();
            if (d.ShowDialog() == DialogResult.OK)
            {
                bt_MajorGridColor.BackColor = d.Color;
                gpane.MajorGridColor = d.Color;
                gpane.Invalidate();
            }
        }

        private void bt_MinorGridColor_Click(object sender, EventArgs e)
        {
            ColorDialog d = new ColorDialog();
            if (d.ShowDialog() == DialogResult.OK)
            {
                bt_MinorGridColor.BackColor = d.Color;
                gpane.MinorGridColor = d.Color;
                gpane.Invalidate();
            }
        }

        private void cb_Y_AutoScale_CheckedChanged(object sender, EventArgs e)
        {
            if (selectetGraphIndex >= 0 && selectetGraphIndex < gpane.Sources.Count)
            {
                DataSource src = gpane.Sources[selectetGraphIndex];

                src.AutoScaleY = cb_Y_AutoScale.Checked;

                UpdateAllCheckedState();

                gpane.Invalidate();

            }
        }

        private void cb_X_AutoScale_CheckedChanged(object sender, EventArgs e)
        {
            if (selectetGraphIndex >= 0 && selectetGraphIndex < gpane.Sources.Count)
            {
                DataSource src = gpane.Sources[selectetGraphIndex];

                src.AutoScaleX = cb_X_AutoScale.Checked;

                UpdateAllCheckedState();

                gpane.Invalidate();

            }
        }
         

       
    }
}