using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Text;
using System.Windows.Forms;
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
    public partial class PlotterGraphPaneEx : UserControl
    {
        #region MEMBERS

        public enum LayoutMode
        {
            NORMAL,
            STACKED,
            VERTICAL_ARRANGED,
            TILES_VER,
            TILES_HOR,
        }

        private BackBuffer memGraphics;        
        private int ActiveSources = 0;
     
        public LayoutMode layout = LayoutMode.NORMAL;
      
        public Color MajorGridColor = Color.DarkGray;
        public Color MinorGridColor = Color.DarkGray;
        public Color GraphColor = Color.DarkGreen;
        public Color BgndColorTop = Color.White;
        public Color BgndColorBot = Color.White;
        public Color LabelColor = Color.White;
        public Color GraphBoxColor = Color.White;
        public bool useDoubleBuffer = false;
        public Font legendFont = new Font(FontFamily.GenericSansSerif, 8.25f);
      
        private List<DataSource> sources = new List<DataSource>();

        public SmoothingMode smoothing = SmoothingMode.None;

        public bool hasMovingGrid = true;
        public bool hasBoundingBox = true;
      
        private Point mousePos = new Point();
        private bool mouseDown = false;

      
        public float starting_idx = 0;
        

        public float XD0 = -50;
        
        public float XD1 = 100;

        public float DX = 0;
        
        public float off_X = 0;

        public float CurXD0 = 0;
        
        public float CurXD1 = 0;

        public float grid_distance_x = 200;       // grid distance in samples ( draw a vertical line every 200 samples )
        public float grid_off_x = 0;
        public float GraphCaptionLineHeight = 28;

        public float pad_inter = 4;         // padding between graphs
        public float pad_left = 10;         // left padding
        public float pad_right = 10;        // right padding
        public float pad_top = 10;          // top
        public float pad_bot = 10;          // bottom padding

        public float graph_distance_x = 10; // distance between graphs, x direction
        public float graph_distance_y = 10; // distance between graphs, y direction

        public float yLabelAreaWidth = 40;       // y-label area width

        public float xLabelAreaheight = 8;        // x-label padding ( bottom area left and right were x labels are still visible )

        PointF graphCaptionOffset = new PointF(12, 2);

        public float[] MinorGridPattern = new float[] { 2,4 };
        public float[] MajorGridPattern = new float[] { 2,2  };

        DashStyle MinorGridDashStyle = DashStyle.Custom;
        DashStyle MajorGridDashStyle = DashStyle.Custom;
        public bool MoveMinorGrid = true;

        #endregion

        #region CONSTRUCTOR

        public PlotterGraphPaneEx()
        {
            memGraphics = new BackBuffer();

            InitializeComponent();

            this.Resize += new System.EventHandler(this.OnResizeForm);
            this.MouseDown += new MouseEventHandler(OnMouseDown);
            this.MouseUp += new MouseEventHandler(OnMouseUp);
            this.MouseMove += new MouseEventHandler(OnMouseMove);   
          
             
        }

        #endregion

        public List<DataSource> Sources
        {
            get
            {
                return sources;
            }
        }
        private void OnLoadControl(object sender, EventArgs e)
        {
            memGraphics.Init(this.CreateGraphics(), this.ClientRectangle.Width, this.ClientRectangle.Height);
        }

        protected override void OnPaintBackground(PaintEventArgs e)
        {
            if (ParentForm == null)
            {
                // paint background when control is used in editor
                base.OnPaintBackground(e);
               
            }
            else
            {
                // do not repaint background to avoid flickering
            }
        }
       
        private void OnResizeForm(object sender, System.EventArgs e)
        {
            memGraphics.Init(this.CreateGraphics(), ClientRectangle.Width, ClientRectangle.Height);
            Invalidate();
        }

        private void OnMouseUp(object sender, MouseEventArgs e)
        {
            if (mouseDown == true)
            {
                mouseDown = false;
                Cursor = Cursors.Default;
            }
        }

        private void OnMouseDown(object sender, MouseEventArgs e)
        {
            if (mouseDown == false)
            {
                mouseDown = true;
                mousePos = e.Location;
                Cursor = Cursors.Hand;
            }
        }

        private void OnMouseMove(object sender, MouseEventArgs e)
        {
            if (mouseDown)
            {                
                float dx = mousePos.X - e.Location.X;
                
                mousePos = e.Location;

                float DX = CurXD1 - CurXD0;

                float off_X = dx * DX / this.Width;

                if (Math.Abs(off_X) > 0)
                {
                    starting_idx += off_X;                       
                }
                
                Invalidate();
            }
        }

        public void PaintGraphs(Graphics CurGraphics, float CurWidth, float CurHeight, float OFFX, float OFFY)
        {                                 
            int CurGraphIdx = 0;
            int VertTileCount = 1;
            int HorTileCount = 1;

            float curOffY = 0;
            float CurOffX = 0;

            if ((layout == LayoutMode.TILES_VER || layout == LayoutMode.TILES_HOR) && ActiveSources >= 1)
            {
                // calculate number of tiles                                   
                if (layout == LayoutMode.TILES_VER)
                {
                    VertTileCount = 1;
                    HorTileCount = 1;
                    while (true)
                    {
                        if (VertTileCount * HorTileCount >= ActiveSources) break;
                        VertTileCount++;
                        if (VertTileCount * HorTileCount >= ActiveSources) break;
                        HorTileCount++;
                    }
                }
                else if (layout == LayoutMode.TILES_HOR)
                {
                    VertTileCount = 1;
                    HorTileCount = 1;
                    while (true)
                    {
                        if (VertTileCount * HorTileCount >= ActiveSources) break;
                        HorTileCount++;
                        if (VertTileCount * HorTileCount >= ActiveSources) break;
                        VertTileCount++;
                    }
                }
            }

            foreach (DataSource source in sources)
            {
                source.Cur_YD0 = source.YD0;
                source.Cur_YD1 = source.YD1;

                source.CurGraphHeight = CurHeight;
                source.CurGraphWidth = CurWidth - pad_left - yLabelAreaWidth - pad_right;

                if (source.yFlip)
                {
                    DX = XD1 - XD0;
                }
                else
                {
                    DX = XD1 - XD0;
                }

                CurXD0 = XD0;
                CurXD1 = XD1;

                if (source.AutoScaleX && source.Samples.Length > 0)
                {
                    CurXD0 = source.XMin - source.XAutoScaleOffset;
                    CurXD1 = source.XMax + source.XAutoScaleOffset;
                    DX = CurXD1 - CurXD0;
                }

                if (source.Active)
                {
                    if (source.AutoScaleY == true)
                    {
                        int idx_start = -1;
                        int idx_stop = -1;
                        float ymin = 0.0f;
                        float ymax = 0.0f;
                        float ymin_range = 0;
                        float ymax_range = 0;

                        int DownSample = source.Downsampling;
                        cPoint[] data = source.Samples;
                        float mult_y = source.CurGraphHeight / source.DY;
                        float mult_x = source.CurGraphWidth / DX;
                        float coff_x = off_X - starting_idx * mult_x;

                        if (source.AutoScaleX)
                        {
                            coff_x = off_X ;
                        }

                        for (int i = 0; i < data.Length - 1; i += DownSample)
                        {
                            float x = data[i].x * mult_x + coff_x;

                            if (data[i].y > ymax) ymax = data[i].y;
                            if (data[i].y < ymin) ymin = data[i].y;

                            if (x > 0 && x < (source.CurGraphWidth))
                            {
                                if (idx_start == -1) idx_start = i;
                                idx_stop = i;

                                if (data[i].y > ymax_range) ymax_range = data[i].y;
                                if (data[i].y < ymin_range) ymin_range = data[i].y;
                            }
                        }

                        if (idx_start >= 0 && idx_stop >= 0)
                        {
                            float data_range = ymax - ymin;              // this is range in the data
                            float delta_range = ymax_range - ymin_range; // this is the visible data range -> might be smaller

                            source.Cur_YD0 = ymin_range;
                            source.Cur_YD1 = ymax_range;
                        }
                    }

                    if (layout == LayoutMode.VERTICAL_ARRANGED && ActiveSources >= 1)
                    {
                        if (ActiveSources > 1)
                        {
                            source.CurGraphHeight = (float)(CurHeight - pad_top - pad_bot) / ActiveSources - GraphCaptionLineHeight;
                            float Diff = ((ActiveSources - 1) * pad_inter) / ActiveSources;
                            source.CurGraphHeight -= Diff;
                        }
                        else
                        {
                            source.CurGraphHeight = (float)(CurHeight - pad_top - pad_bot) - GraphCaptionLineHeight;
                        }
                    }
                    else if (layout == LayoutMode.STACKED && ActiveSources >= 1)
                    {
                        if (ActiveSources > 1)
                        {
                            source.CurGraphHeight = (float)(CurHeight - pad_top - pad_bot) / ActiveSources - GraphCaptionLineHeight;
                        }
                        else
                        {
                            source.CurGraphHeight = (float)(CurHeight - pad_top - pad_bot) - GraphCaptionLineHeight;
                        }
                    }
                    else if ((layout == LayoutMode.TILES_VER || layout == LayoutMode.TILES_HOR) && ActiveSources >= 1)
                    {
                        if (ActiveSources > 1)
                        {
                            source.CurGraphHeight = (float)(CurHeight - pad_top - pad_bot) / VertTileCount - GraphCaptionLineHeight;
                            float Diff = ((ActiveSources - 1) * pad_inter) / VertTileCount;
                            source.CurGraphHeight -= Diff;
                            source.CurGraphWidth = (float)(CurWidth - pad_left - pad_right) / HorTileCount - yLabelAreaWidth;
                        }
                        else
                        {
                            source.CurGraphHeight = (float)(CurHeight - pad_top - pad_bot) - GraphCaptionLineHeight;
                        }
                    }
                    else
                    {
                        source.CurGraphHeight = (float)(CurHeight - pad_top - pad_bot) - GraphCaptionLineHeight;
                        source.CurGraphWidth = CurWidth - pad_left - yLabelAreaWidth * ActiveSources - pad_right;

                    }

                    if (source.yFlip)
                    {
                        source.DY = source.Cur_YD0 - source.Cur_YD1;

                        if (DX != 0 && source.DY != 0)
                        {
                            source.off_Y = -source.Cur_YD1 * source.CurGraphHeight / source.DY;
                            off_X = -CurXD0 * source.CurGraphWidth / DX;
                        }
                    }
                    else
                    {
                        source.DY = source.Cur_YD1 - source.Cur_YD0;

                        if (DX != 0 && source.DY != 0)
                        {
                            source.off_Y = -source.Cur_YD0 * source.CurGraphHeight / source.DY;
                            off_X = -CurXD0 * source.CurGraphWidth / DX;
                        }
                    }

                    if ((layout == LayoutMode.TILES_VER || layout == LayoutMode.TILES_HOR))
                    {
                        if (ActiveSources > 1)
                        {
                            if (layout == LayoutMode.TILES_VER)
                            {
                                // TODO: calc curOffX and CurrOffY for CurGraphIdx!!
                                int CurIdxY = CurGraphIdx % VertTileCount;
                                int CurIdxX = CurGraphIdx / VertTileCount;

                                curOffY = OFFY + pad_top + CurIdxY * (source.CurGraphHeight + GraphCaptionLineHeight);
                                CurOffX = OFFX + yLabelAreaWidth + pad_left + CurIdxX * (yLabelAreaWidth + source.CurGraphWidth);
                            }
                            else
                            {
                                int CurIdxX = CurGraphIdx % HorTileCount;
                                int CurIdxY = CurGraphIdx / HorTileCount;

                                curOffY = OFFY + pad_top + CurIdxY * (source.CurGraphHeight + GraphCaptionLineHeight);
                                CurOffX = OFFX + yLabelAreaWidth + pad_left + CurIdxX * (yLabelAreaWidth + source.CurGraphWidth);
                            }

                        }
                        else
                        {
                            // one active source
                            curOffY = OFFY + pad_top + CurGraphIdx * (source.CurGraphHeight + GraphCaptionLineHeight);
                            CurOffX = OFFX + pad_left + yLabelAreaWidth;
                        }
                    }
                    else if (layout == LayoutMode.VERTICAL_ARRANGED)
                    {
                        if (ActiveSources > 1)
                        {
                            curOffY = OFFY + pad_top + CurGraphIdx * (source.CurGraphHeight + GraphCaptionLineHeight + pad_inter);
                        }
                        else
                        {
                            curOffY = OFFY + pad_top + CurGraphIdx * (source.CurGraphHeight + GraphCaptionLineHeight);
                        }

                        CurOffX = OFFX + pad_left + yLabelAreaWidth;
                    }
                    else if (layout == LayoutMode.STACKED)
                    {
                        if (ActiveSources > 1)
                        {
                            curOffY = OFFY + pad_top + CurGraphIdx * (source.CurGraphHeight);
                        }
                        else
                        {
                            curOffY = OFFY + pad_top + CurGraphIdx * (source.CurGraphHeight);
                        }

                        CurOffX = OFFX + pad_left + yLabelAreaWidth;
                    }
                    else
                    {
                        CurOffX = OFFX + pad_left + yLabelAreaWidth * ActiveSources;
                        curOffY = OFFY + pad_top;
                    }

                    DrawGrid(CurGraphics, source, CurOffX, curOffY + GraphCaptionLineHeight / 2);

                    if (hasBoundingBox)
                    {
                        float w = source.CurGraphWidth;
                        float h = source.CurGraphHeight + GraphCaptionLineHeight / 2;

                        DrawGraphBox(CurGraphics, CurOffX, curOffY, w, h);

                    }

                    List<int> marker_pos = DrawGraphCurve(CurGraphics, source, CurOffX, curOffY + GraphCaptionLineHeight / 2);
                    
                    if (layout == LayoutMode.NORMAL)
                    {
                        DrawGraphCaption(CurGraphics, source, marker_pos, CurOffX + CurGraphIdx * (10 + yLabelAreaWidth), curOffY);

                        if (CurGraphIdx == 0)
                        {
                            DrawXLabels(CurGraphics, source, marker_pos, CurOffX, curOffY);
                        }

                        DrawYLabels(CurGraphics, source, marker_pos, CurOffX + yLabelAreaWidth * (CurGraphIdx - ActiveSources + 1), curOffY);
                    }
                    else
                    {
                        DrawGraphCaption(CurGraphics, source, marker_pos, CurOffX, curOffY);

                        DrawXLabels(CurGraphics, source, marker_pos, CurOffX, curOffY);

                        DrawYLabels(CurGraphics, source, marker_pos, CurOffX, curOffY);
                    }

                    

                    CurGraphIdx++;
                }
            }
        }

        private void PaintStackedGraphs(Graphics CurGraphics,float CurWidth,float CurHeigth, float OFFX, float OFFY)
        {            
            int CurGraphIdx = 0;
            float curOffY = 0;
            float CurOffX = 0;

            foreach (DataSource source in sources)
            {
                source.Cur_YD0 = source.YD0;
                source.Cur_YD1 = source.YD1;

                source.CurGraphHeight = CurHeigth;
                source.CurGraphWidth = CurWidth - pad_left - yLabelAreaWidth - pad_right;

                DX = XD1 - XD0;

                if (source.AutoScaleX && source.Samples.Length > 0)
                {
                    DX = source.Samples[source.Samples.Length - 1].x;
                }

                CurXD0 = XD0;
                CurXD1 = XD1;

                if (source.Active)
                {
                    if (source.AutoScaleY == true)
                    {
                        int idx_start = -1;
                        int idx_stop = -1;
                        float ymin = 0.0f;
                        float ymax = 0.0f;
                        float ymin_range = 0;
                        float ymax_range = 0;

                        int DownSample = source.Downsampling;
                        cPoint[] data = source.Samples;
                        float mult_y = source.CurGraphHeight / source.DY;
                        float mult_x = source.CurGraphWidth / DX;
                        float coff_x = off_X - starting_idx * mult_x;

                        if (source.AutoScaleX)
                        {
                            coff_x = off_X;     // avoid dragging in x-autoscale mode
                        }

                        for (int i = 0; i < data.Length - 1; i += DownSample)
                        {
                            float x = data[i].x * mult_x + coff_x;

                            if (data[i].y > ymax) ymax = data[i].y;
                            if (data[i].y < ymin) ymin = data[i].y;

                            if (x > 0 && x < (source.CurGraphWidth))
                            {
                                if (idx_start == -1) idx_start = i;
                                idx_stop = i;

                                if (data[i].y > ymax_range) ymax_range = data[i].y;
                                if (data[i].y < ymin_range) ymin_range = data[i].y;
                            }
                        }

                        if (idx_start >= 0 && idx_stop >= 0)
                        {
                            float data_range = ymax - ymin;              // this is range in the data
                            float delta_range = ymax_range - ymin_range; // this is the visible data range -> might be smaller

                            source.Cur_YD0 = ymin_range;
                            source.Cur_YD1 = ymax_range;
                        }
                    }

                    if (ActiveSources > 1)
                    {
                        source.CurGraphHeight = (float)(CurHeigth - GraphCaptionLineHeight - pad_top - pad_bot) / ActiveSources;
                    }
                    else
                    {
                        source.CurGraphHeight = (float)(CurHeigth - GraphCaptionLineHeight - pad_top - pad_bot);
                    }
                    
                    if (source.yFlip)
                    {
                        source.DY = source.Cur_YD0 - source.Cur_YD1;

                        if (DX != 0 && source.DY != 0)
                        {
                            source.off_Y = -source.Cur_YD1 * source.CurGraphHeight / source.DY;
                            off_X = -CurXD0 * source.CurGraphWidth / DX;
                        }
                    }
                    else
                    {
                        source.DY = source.Cur_YD1 - source.Cur_YD0;

                        if (DX != 0 && source.DY != 0)
                        {
                            source.off_Y = -source.Cur_YD0 * source.CurGraphHeight / source.DY;
                            off_X = -CurXD0 * source.CurGraphWidth / DX;
                        }
                    }
                   
                    if (ActiveSources > 1)
                    {
                        curOffY = OFFY + pad_top + CurGraphIdx * (source.CurGraphHeight);
                    }
                    else
                    {
                        curOffY = OFFY + pad_top + CurGraphIdx * (source.CurGraphHeight);
                    }

                    CurOffX = OFFX + pad_left + yLabelAreaWidth;                     
                    
                    DrawGrid(CurGraphics, source, CurOffX, curOffY + GraphCaptionLineHeight / 2);

                    if (hasBoundingBox && CurGraphIdx == ActiveSources - 1)
                    {
                        DrawGraphBox(CurGraphics, pad_left + yLabelAreaWidth, pad_top, source.CurGraphWidth, CurHeigth - pad_top - GraphCaptionLineHeight);
                    }

                    List<int> marker_pos = DrawGraphCurve(CurGraphics, source, CurOffX, curOffY + GraphCaptionLineHeight / 2);

                    DrawGraphCaption(CurGraphics, source, marker_pos, CurOffX + CurGraphIdx * (10 + yLabelAreaWidth), pad_top);
                  
                    DrawYLabels(CurGraphics, source, marker_pos, CurOffX, curOffY);

                    if (CurGraphIdx == ActiveSources - 1)
                    {
                        DrawXLabels(CurGraphics, source, marker_pos, pad_left, Height - pad_top - GraphCaptionLineHeight - source.CurGraphHeight);
                    }

                    /*
                    if (hasBoundingBox && CurGraphIdx == ActiveSources - 1)
                    {
                        DrawGraphBox(CurGraphics, pad_left + yLabelAreaWidth, pad_top, source.CurGraphWidth, CurHeigth - pad_top - GraphCaptionLineHeight);
                    }
                     * */

                   

                    CurGraphIdx++;
                }

                
            }
        }

        public void PaintControl(Graphics CurGraphics, float CurWidth, float CurHeight, float OffX, float OffY, bool PaintBgnd)
        {
            if (PaintBgnd)
            {
                DrawBackground(CurGraphics,CurWidth,CurHeight,OffX,OffY);
            }

            ActiveSources = 0;

            foreach (DataSource source in sources)
            {
                if (source.Samples != null &&
                    source.Samples.Length > 0 &&
                    source.Active == true)
                {
                    ActiveSources++;
                }
            }

            switch (layout)
            {
                case LayoutMode.NORMAL:

                case LayoutMode.TILES_HOR:
                case LayoutMode.TILES_VER:
                case LayoutMode.VERTICAL_ARRANGED:

                    PaintGraphs(CurGraphics, CurWidth, CurHeight, OffX, OffY);
                
                    break;

                case LayoutMode.STACKED:

                    PaintStackedGraphs(CurGraphics, CurWidth, CurHeight, OffX, OffY);
                 
                    break;
            }
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            try
            {
                if (ParentForm != null)
                {
                    Graphics CurGraphics = e.Graphics;

                    if (memGraphics.g != null && useDoubleBuffer == true)
                    {
                        CurGraphics = memGraphics.g;
                    }

                    CurGraphics.SmoothingMode = smoothing;

                    PaintControl(CurGraphics,this.Width,this.Height,0,0,true);

                    if (memGraphics.g != null && useDoubleBuffer == true)
                    {
                        memGraphics.Render(e.Graphics);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.Write("exception : " + ex.Message);
            }

            base.OnPaint(e);
        }

        private void DrawBackground(Graphics g,float CurWidth, float CurHeight, float CurOFFX, float CurOFFY)
        {
            Rectangle rbgn = new Rectangle((int)CurOFFX, (int)CurOFFY, (int)CurWidth, (int)CurHeight);

            if (BgndColorTop != BgndColorBot)
            {
                using (LinearGradientBrush lb1 = new LinearGradientBrush(new Point((int)0, (int)0),
                                                                         new Point((int)0, (int)(CurHeight)),
                                                                         BgndColorTop,
                                                                         BgndColorBot))
                {
                    g.FillRectangle(lb1, rbgn);
                }
            }
            else
            {
                using (SolidBrush sb1 = new SolidBrush(BgndColorTop))
                {
                    g.FillRectangle(sb1, rbgn);
                }
            }
        }

        private void DrawGrid( Graphics g, DataSource source,  float CurrOffX, float CurOffY )
    {
        int Idx = 0;
        float mult_x = source.CurGraphWidth / DX;
        float coff_x = off_X - starting_idx * mult_x;

        if (source.AutoScaleX)
        {
            coff_x = off_X;     // avoid dragging in x-autoscale mode
        }

        Color CurGridColor = MajorGridColor;
        Color CurMinGridClor = MinorGridColor;

        if (layout == LayoutMode.NORMAL && source.AutoScaleY)
        {
            CurGridColor = source.GraphColor;
            CurMinGridClor = source.GraphColor;
        }

        using (Pen minorGridPen = new Pen(CurMinGridClor))
        {
           minorGridPen.DashPattern = MinorGridPattern;
           minorGridPen.DashStyle = MinorGridDashStyle;
          
           using (Pen p2 = new Pen(CurGridColor))
           {
                p2.DashPattern = MajorGridPattern;
                p2.DashStyle = MajorGridDashStyle;

                if (DX != 0)
                {
                    while (true)
                    {
                        float x = Idx * grid_distance_x * source.CurGraphWidth / DX + grid_off_x * source.CurGraphWidth / DX;

                        if (MoveMinorGrid)
                        {
                            x += coff_x;
                        }

                        if (x > 0 && x < source.CurGraphWidth)
                        {
                            g.DrawLine(minorGridPen, new Point((int)(x + CurrOffX - 0.5f), (int)(CurOffY)),
                                                     new Point((int)(x + CurrOffX - 0.5f), (int)(CurOffY + source.CurGraphHeight)));                                
                        }
                        if (x > source.CurGraphWidth)
                        {
                            break;
                        }

                        Idx++;
                    }
                }

                if (source.DY != 0)
                {
                    float y0 = (float)(source.grid_off_y * source.CurGraphHeight / source.DY + source.off_Y);

                    // draw horizontal zero grid lines
                    g.DrawLine(p2, new Point((int)CurrOffX, (int)(CurOffY + y0 + 0.5f)), new Point((int)(CurrOffX + source.CurGraphWidth + 0.5f), (int)(CurOffY + y0 + 0.5f)));

                    // draw horizontal grid lines
                    for (Idx = (int)(source.grid_off_y);Idx > (int)(source.YD0 ); Idx -= (int)source.grid_distance_y)
                    {
                        float y = (float)(Idx * source.CurGraphHeight) / source.DY + source.off_Y;

                        if (y >= 0 && y < source.CurGraphHeight)
                        {
                            g.DrawLine(minorGridPen, 
                                        new Point((int)CurrOffX, (int)(CurOffY + y + 0.5f)),
                                        new Point((int)(CurrOffX + source.CurGraphWidth + 0.5f), (int)(0.5f + CurOffY + y)));
                        }
                    }

                    // draw horizontal grid lines
                    for (Idx = (int)(source.grid_off_y); Idx < (int)(source.YD1  ); Idx += (int)source.grid_distance_y)
                    {
                        float y = (float)Idx * source.CurGraphHeight / source.DY + source.off_Y;

                        if (y >= 0 && y < source.CurGraphHeight)
                        {
                            g.DrawLine(minorGridPen, 
                                       new Point((int)CurrOffX, (int)(CurOffY + y + 0.5f)),
                                       new Point((int)(CurrOffX + source.CurGraphWidth + 0.5f), (int)(0.5f + CurOffY + y)));
                        }
                    }
                }
            }
        }
    }
      
        private List<int> DrawGraphCurve( Graphics g, DataSource source,  float offset_x, float offset_y )
        {
            List<int> marker_positions = new List<int>();

            if (DX != 0 && source.DY != 0)
            {
                List<Point> ps = new List<Point>();
               
                if (source.Samples != null && source.Samples.Length > 1)
                {
                   
                    int DownSample = source.Downsampling;
                    cPoint[] data = source.Samples;
                    float mult_y = source.CurGraphHeight / source.DY;
                    float mult_x = source.CurGraphWidth / DX;
                    float coff_x = off_X - starting_idx * mult_x;

                    if (source.AutoScaleX)
                    {
                        coff_x = off_X;     // avoid dragging in x-autoscale mode
                    }

                    for (int i = 0; i < data.Length - 1; i += DownSample)
                    {
                        float x = data[i].x  * mult_x   + coff_x;
                        float y = data[i].y  * mult_y + source.off_Y;

                        int xi = (int)(data[i].x);

                        if (xi % grid_distance_x == 0)
                        {
                            if (x >= (0 - xLabelAreaheight) && x <= (source.CurGraphWidth + xLabelAreaheight))
                            {
                                marker_positions.Add(i);
                            }
                        }

                        if (x > 0 && x < (source.CurGraphWidth))
                        {                           
                            ps.Add(new Point((int)(x + offset_x+0.5f), (int)(y  + offset_y  + 0.5f)));                             
                        }
                        else if (x > source.CurGraphWidth)
                        {                            
                            break;
                        }
                    }

                    using (Pen p = new Pen(source.GraphColor))
                    {
                        if (ps.Count > 0)
                        {
                            g.DrawLines(p, ps.ToArray());
                        }
                    }
                }
            }
            return marker_positions;
        }

        private void DrawGraphCaption(Graphics g, DataSource source, List<int> marker_pos, float offset_x, float offset_y)
        {
            using (Brush brush = new SolidBrush(source.GraphColor))
            {
                using (Pen pen = new Pen(brush))
                {
                    pen.DashPattern = MajorGridPattern;

                    g.DrawString(source.Name, legendFont, brush, new PointF(offset_x + graphCaptionOffset.X + 12, offset_y +graphCaptionOffset.Y+ 2));

                }
            }
        }
         
        /*
         * 
         * 
         **/
        private void DrawXLabels(Graphics g, DataSource source, List<int> marker_pos, float offset_x, float offset_y)
        {
            Color XLabColor = source.GraphColor;

            if (layout == LayoutMode.NORMAL || 
                layout == LayoutMode.STACKED)
            {
                XLabColor = GraphBoxColor;
            }

            using (Brush brush = new SolidBrush(XLabColor))
            {
                using (Pen pen = new Pen(brush))
                {
                    pen.DashPattern = MajorGridPattern;
                  
                    if (DX != 0 && source.DY != 0)
                    {
                        if (source.Samples != null && source.Samples.Length > 1)
                        {
                            cPoint[] data = source.Samples;

                            float mult_y = source.CurGraphHeight / source.DY;
                            float mult_x = source.CurGraphWidth / DX;

                            float coff_x = off_X - starting_idx * mult_x;

                            if (source.AutoScaleX)
                            {
                                coff_x = off_X;     // avoid dragging in x-autoscale mode
                            }

                            foreach (int i in marker_pos)
                            {
                                int xi = (int)(data[i].x);

                                if (xi % grid_distance_x == 0)
                                {
                                    float x = data[i].x * mult_x   + coff_x;

                                    String value = "" + data[i].x;

                                    if (source.OnRenderXAxisLabel != null)
                                    {
                                        value = source.OnRenderXAxisLabel(source, i);
                                    }

                                    /// TODO: find out how to calculate this offset. Must be padding + something else
                                    float unknownOffset = -14;// -14;

                                    if (MoveMinorGrid == false)
                                    {
                                        g.DrawLine(pen, x, offset_y +  GraphCaptionLineHeight  + source.CurGraphHeight + unknownOffset,
                                                        x, offset_y + GraphCaptionLineHeight + source.CurGraphHeight);

                                        g.DrawString(value, legendFont, brush, 
                                                        new PointF((int)(0.5f + x + offset_x + 4),
                                                        GraphCaptionLineHeight + offset_y + source.CurGraphHeight + unknownOffset));
                                    }
                                    else
                                    {
                                        SizeF dim = g.MeasureString(value, legendFont);
                                        g.DrawString(value, legendFont, brush, 
                                                            new PointF((int)(0.5f + x + offset_x + 4 - dim.Width / 2),
                                                            GraphCaptionLineHeight + offset_y + source.CurGraphHeight + unknownOffset));

                                    }
                                }
                            }
                        }
                    }

                   
                }
            }
        }

        private void DrawYLabels(Graphics g, DataSource source, List<int> marker_pos,  float offset_x,  float offset_y )
        {
            using (Brush b = new SolidBrush(source.GraphColor))
            {
                using (Pen pen = new Pen(b))
                {
                    pen.DashPattern = new float[] { 2, 2 };
                     
                    // draw labels for horizontal lines
                    if (source.DY != 0)
                    {
                        float Idx = 0;

                        float y0 = (float)(source.grid_off_y * source.CurGraphHeight / source.DY + source.off_Y);

                        String value = "" + Idx;

                        if (source.OnRenderYAxisLabel != null)
                        {
                            value = source.OnRenderYAxisLabel(source, Idx);
                        }

                        SizeF dim = g.MeasureString(value, legendFont);
                        g.DrawString(value, legendFont, b, new PointF((int)offset_x - dim.Width, (int)(offset_y + y0 + 0.5f + dim.Height / 2)));

                        float GridDistY = source.grid_distance_y;

                        if (source.AutoScaleY)
                        {
                            // calculate a matching grid distance                            
                            GridDistY = - Utilities.MostSignificantDigit(source.DY );

                            if (GridDistY == 0)
                            {
                                GridDistY =  source.grid_distance_y;
                                 
                            }
                        }

                        for (Idx =  (source.grid_off_y); Idx >  (source.Cur_YD0); Idx -=  GridDistY)
                        {
                            if (Idx != 0)
                            {
                                float y1 = (float)((Idx) * source.CurGraphHeight) / source.DY + source.off_Y;

                                value = "" + (Idx);

                                if (source.OnRenderYAxisLabel != null)
                                {
                                    value = source.OnRenderYAxisLabel(source, Idx);
                                }

                                dim = g.MeasureString(value, legendFont);
                                g.DrawString(value, legendFont, b, new PointF((int)offset_x - dim.Width, (int)(offset_y + y1 + 0.5f + dim.Height / 2)));                                
                            }
                        }

                        for (Idx =  (source.grid_off_y); Idx <  (source.Cur_YD1); Idx +=  GridDistY)
                        {
                            if (Idx != 0)
                            {
                                float y2 = (float)((Idx) * source.CurGraphHeight) / source.DY + source.off_Y;

                                value = "" + (Idx);

                                if (source.OnRenderYAxisLabel != null)
                                {
                                    value = source.OnRenderYAxisLabel(source, Idx);
                                }                               

                                dim = g.MeasureString(value, legendFont);
                                g.DrawString(value, legendFont, b, new PointF((int)offset_x - dim.Width, (int)(offset_y + y2 + 0.5f + dim.Height / 2)));
                            }
                        }                             
                    }
                }
            }
        }

        private void DrawGraphBox(Graphics g, float offset_x, float offset_y, float w, float h )
        {
            using (Pen p2 = new Pen(GraphBoxColor))
            {
                g.DrawLine(p2, new Point((int)(offset_x + 0.5f), (int)(offset_y + 0.5f)),
                              new Point((int)(offset_x + w - 0.5f), (int)(offset_y + 0.5f)));

                g.DrawLine(p2, new Point((int)(offset_x + w - 0.5f), (int)(offset_y + 0.5f)),
                             new Point((int)(offset_x + w - 0.5f), (int)(offset_y + h +   0.5f)));

                g.DrawLine(p2, new Point((int)(offset_x + w - 0.5f), (int)(offset_y + h +   0.5f)),
                           new Point((int)(offset_x + 0.5f), (int)(offset_y + h +   0.5f)));

                g.DrawLine(p2, new Point((int)(offset_x + 0.5f), (int)(offset_y + h +   0.5f)),
                          new Point((int)(offset_x + 0.5f), (int)(offset_y + 0.5f)));
            }
        }
          
    }
}
