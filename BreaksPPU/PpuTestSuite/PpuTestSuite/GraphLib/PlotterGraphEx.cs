using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Text;
using System.Windows.Forms;
using System.Threading;
using System.ComponentModel.Design;
using System.Drawing.Drawing2D;

 
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
    public partial class PlotterDisplayEx : UserControl
    {         
        #region MEMBERS

        delegate void InvokeVoidFuncDelegate();

        PlotterGraphSelectCurvesForm GraphPropertiesForm = null;
        PrintPreviewForm printPreviewForm = null;

        private PrecisionTimer.Timer mTimer = null;
        private float play_speed = 0.5f;
        private float play_speed_max = 10f;
        private float play_speed_min = 0.5f;

        private bool paused = false;
        private bool isRunning = false;

        #endregion

        #region CONSTRUCTOR

        public PlotterDisplayEx()
        {
            InitializeComponent();
            mTimer = new PrecisionTimer.Timer();
            mTimer.Period = 50;                         // 20 fps
            mTimer.Tick += new EventHandler(OnTimerTick);
            play_speed = 0.5f; // 20x10 = 200 values per second == sample frequency     
            mTimer.Start();
            isRunning = false;
        }
       
        void contextMenuStrip1_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {
            String text = e.ClickedItem.Text;
            foreach (DataSource s in gPane.Sources)
            {
                if (s.Name == text)
                {
                    s.Active ^= true;
                    gPane.Invalidate();
                    break;
                }
            }
        }
         
        #endregion

        #region PROPERTIES

        [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
        [Editor(typeof(System.ComponentModel.Design.CollectionEditor),
               typeof(System.Drawing.Design.UITypeEditor))]
        public List<DataSource> DataSources
        {
            get { return gPane.Sources; }
        }

        [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
        [Editor(typeof(System.ComponentModel.Design.CollectionEditor),
               typeof(System.Drawing.Design.UITypeEditor))]
        public PlotterGraphPaneEx.LayoutMode PanelLayout
        {
            get { return gPane.layout; }
            set { gPane.layout = value; }
        }

        [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
        [Editor(typeof(System.ComponentModel.Design.CollectionEditor),
               typeof(System.Drawing.Design.UITypeEditor))]
        public SmoothingMode Smoothing
        {
            get { return gPane.smoothing; }
            set { gPane.smoothing = value; }
        }

        [Category("Playback")]
        [DefaultValue(typeof(float), "2")]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public float PlaySpeed
        {
            get { return play_speed; }
            set { play_speed = value; }
        }

        [Category("Playback")]
        [DefaultValue(typeof(bool), "true")]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public bool ShowMovingGrid
        {
            get { return gPane.hasMovingGrid; }
            set { gPane.hasMovingGrid = value; }
        }


        [Category("Properties")]   
        [DefaultValue(typeof(Color), "")]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public Color BackgroundColorTop
        {
            get { return gPane.BgndColorTop; }
            set { gPane.BgndColorTop = value; }
        }

        [Category("Properties")]  
        [DefaultValue(typeof(Color), "")]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public Color BackgroundColorBot
        {
            get { return gPane.BgndColorBot; }
            set { gPane.BgndColorBot = value; }
        }

        [Category("Properties")]  
        [DefaultValue(typeof(Color), "")]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public Color DashedGridColor
        {
            get { return gPane.MinorGridColor; }
            set { gPane.MinorGridColor = value; }
        }

        [Category("Properties")]
        [DefaultValue(typeof(Color), "")]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public Color SolidGridColor
        {
            get { return gPane.MajorGridColor; }
            set { gPane.MajorGridColor = value; }
        }
                
      
        public bool DoubleBuffering
        {
            get { return gPane.useDoubleBuffer; }
            set { gPane.useDoubleBuffer = value; }
        }

        #endregion

        #region PUBLIC METHODS

        public void SetDisplayRangeX(float x_start, float x_end )
        {
            gPane.XD0 = x_start;
            gPane.XD1 = x_end;
            gPane.CurXD0 = gPane.XD0;
            gPane.CurXD1 = gPane.XD1;
        }
       
        public void SetGridDistanceX(float grid_dist_x_samples)
        {
            gPane.grid_distance_x = grid_dist_x_samples;           
        }
      
        public void SetGridOriginX(float off_x)
        {
            gPane.grid_off_x = off_x;          
        }

        
        #endregion

        #region PRIVATE METHODS

        protected override void Dispose(bool disposing)
        {
            paused = true;

            if (mTimer.IsRunning)
            {
                mTimer.Stop();
                mTimer.Dispose();
            }
            
            base.Dispose(disposing);
        }

        public void Start()
        {
            if (isRunning == false && paused == false)
            {
                gPane.starting_idx = 0;
                paused = false;
                isRunning = true;
               // mTimer.Start();                
                tb1.Buttons[0].ImageIndex = 2;                
            }
            else
            {
                if (paused == false)
                {
                    //mTimer.Stop();
                    paused = true;
                }
                else
                {
                   // mTimer.Start();
                    paused = false;
                }

                if (paused)
                {
                    
                    tb1.Buttons[0].ImageIndex = 0;  
                }
                else
                {
                   
                    tb1.Buttons[0].ImageIndex = 2;  
                }
            }
        }

        public void Stop()
        {
            if (isRunning)
            {
               // mTimer.Stop();
                isRunning = false;
                paused = false;
                hScrollBar1.Value = 0;
                tb1.Buttons[0].ImageIndex = 0;
            }
        }

       
        private void tb1_ButtonClick(object sender, ToolBarButtonClickEventArgs e)
        {
            bool pushed = e.Button.Pushed;
            switch (e.Button.Tag.ToString().ToLower())
            {
                case "play":

                    Start();
                      
                    break;

                case "stop":

                    Stop();
                   
                    break;       
              
                case "print":

                    // // todo implement print preview
                    ShowPrintPreview();

                    break;
            }
        }

        private void SetPlayPanelVisible()
        {
            panel1.Visible = true;          
            tb1.Buttons[0].Visible = true;
            tb1.Buttons[1].Visible = true;
        }

        private void SetPlayPanelInvisible()
        {
            panel1.Visible = false;
            tb1.Buttons[0].Visible = false;
            tb1.Buttons[1].Visible = false;
            
        }

        private void UpdateControl()
        {
            try
            {
                bool AllAutoscaled = true;

                foreach (DataSource s in gPane.Sources)
                {
                    AllAutoscaled &= s.AutoScaleX;
                }

           
                if (AllAutoscaled == true)
                {
                    if (panel1.Visible == true)
                    {
                        this.Invoke(new MethodInvoker(SetPlayPanelInvisible));
                    }
                }
                else
                {
                    if (panel1.Visible == false)
                    {
                        this.Invoke(new MethodInvoker(SetPlayPanelVisible));
                    }
                }
            }
            catch
            {
            }
        }

        private void UpdatePlayback()
        {
            if (!paused && isRunning == true)
            {
                try
                {
                    gPane.starting_idx += play_speed;
                    UpdateScrollBar();
                    gPane.Invalidate();
                }
                catch { }
            }
        }

        private void OnTimerTick(object sender, EventArgs e)
        {
            UpdateControl();

            UpdatePlayback();
        }
        
        private void UpdateScrollBar()
        {
            if (InvokeRequired)
            {
                Invoke(new MethodInvoker(UpdateScrollBar));
            }
            else
            {
                if (gPane.Sources.Count > 0)
                {
                    if (gPane.starting_idx > gPane.Sources[0].Length)
                    {
                        hScrollBar1.Value = 10000;
                    }
                    else if (gPane.starting_idx >= 0)
                    {
                        hScrollBar1.Value = 10000 * (int)gPane.starting_idx / gPane.Sources[0].Length;
                    }
                    else
                    {
                        hScrollBar1.Value = 0;
                    }
                }
                else
                {
                    hScrollBar1.Value = 0;
                }
            }
        }
         
        private void OnScrollbarScroll(object sender, ScrollEventArgs e)
        {
            if (gPane.Sources.Count > 0)
            {
                int val = hScrollBar1.Value;
                gPane.starting_idx = (int)(gPane.Sources[0].Length * (float)val / 10000.0f);
                gPane.Invalidate();
            }
        }

        private void OnScrollBarSpeedScroll(object sender, ScrollEventArgs e)
        {
            float Percentage = hScrollBar2.Value / 10000.0f;
            float delta = play_speed_max - play_speed_min;
            play_speed = play_speed_min + Percentage * delta;
        }

        #endregion

        private void ShowPrintPreview()
        {
            if (printPreviewForm == null)
            {
                printPreviewForm = new PrintPreviewForm();
            }

            printPreviewForm.GraphPanel = this.gPane;
            printPreviewForm.Show();
            printPreviewForm.TopMost = true;
            printPreviewForm.Invalidate();
        }

        private void selectGraphsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (GraphPropertiesForm == null)
            {
                GraphPropertiesForm = new PlotterGraphSelectCurvesForm();              
            }
                      
            GraphPropertiesForm.GraphPanel = this.gPane;            
            GraphPropertiesForm.Show();            
          //  GraphPropertiesForm.BringToFront();

        }

       

       

    }
}
