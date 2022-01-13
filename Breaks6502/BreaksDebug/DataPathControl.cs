// Control for visualizing the state of the data flows inside the bottom part of the processor.

using System;
using System.ComponentModel;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;
using System.Collections.Generic;
using System.Drawing.Imaging;

namespace BreaksDebug
{
    public partial class DataPathView : Control
    {
        private BufferedGraphics gfx = null;
        private BufferedGraphicsContext context;
        GraphicsPath [] mapping = new GraphicsPath[(int)BogusSystem.ControlCommand.Max];
        BogusSystem.CpuDebugInfo_Commands cur_info = null;
        Pen path_pen = new Pen(new SolidBrush(Color.OrangeRed), 5);
        Font labelFont = new Font("Segoe UI", 10.0f, FontStyle.Bold);

        public DataPathView()
        {
            SetStyle(ControlStyles.OptimizedDoubleBuffer, true);

            // Initialize the mapping to highlight the paths of each command.
            // The mapping is bound to the original image, so you have to reassign it each time you change the image.

            // Regs

            GraphicsPath ysb = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.Y_SB] = ysb;

            GraphicsPath sby = new GraphicsPath();
            sby.AddLines(new Point[] {
                new Point(120, 218),
                new Point(120, 152),
                new Point(128, 159),
                new Point(112, 159),
                new Point(120, 152)
            });
            mapping[(int)BogusSystem.ControlCommand.SB_Y] = sby;

            GraphicsPath xsb = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.X_SB] = xsb;

            GraphicsPath sbx = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.SB_X] = sbx;

            GraphicsPath sadl = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.S_ADL] = sadl;

            GraphicsPath ssb = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.S_SB] = ssb;

            GraphicsPath sbs = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.SB_S] = sbs;

            GraphicsPath ss = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.S_S] = ss;

            // ALU

            GraphicsPath ndbadd = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.NDB_ADD] = ndbadd;

            GraphicsPath dbadd = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.DB_ADD] = dbadd;

            GraphicsPath zadd = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.Z_ADD] = zadd;

            GraphicsPath sbadd = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.SB_ADD] = sbadd;

            GraphicsPath adladd = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.ADL_ADD] = adladd;

            GraphicsPath ands = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.ANDS] = ands;

            GraphicsPath eors = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.EORS] = eors;

            GraphicsPath ors = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.ORS] = ors;

            GraphicsPath srs = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.SRS] = srs;

            GraphicsPath sums = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.SUMS] = sums;

            GraphicsPath addsb7 = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.ADD_SB7] = addsb7;

            GraphicsPath addsb06 = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.ADD_SB06] = addsb06;

            GraphicsPath addadl = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.ADD_ADL] = addadl;

            GraphicsPath sbac = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.SB_AC] = sbac;

            GraphicsPath acsb = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.AC_SB] = acsb;

            GraphicsPath acdb = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.AC_DB] = acdb;

            // PC

            GraphicsPath adhpch = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.ADH_PCH] = adhpch;

            GraphicsPath pchpch = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.PCH_PCH] = pchpch;

            GraphicsPath pchadh = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.PCH_ADH] = pchadh;

            GraphicsPath pchdb = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.PCH_DB] = pchdb;

            GraphicsPath adlpcl = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.ADL_PCL] = adlpcl;

            GraphicsPath pclpcl = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.PCL_PCL] = pclpcl;

            GraphicsPath pcladl = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.PCL_ADL] = pcladl;

            GraphicsPath pcldb = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.PCL_DB] = pcldb;

            // Buses

            GraphicsPath adhabh = new GraphicsPath();
            adhabh.AddLines(new Point[] {
                new Point(585, 225),
                new Point(585, 247),
                new Point(577, 240),
                new Point(592, 241),
                new Point(585, 247)
            });
            mapping[(int)BogusSystem.ControlCommand.ADH_ABH] = adhabh;

            GraphicsPath adlabl = new GraphicsPath();
            adlabl.AddLines(new Point[] {
                new Point(105, 41),
                new Point(84, 41),
                new Point(90, 34),
                new Point(90, 50),
                new Point(84, 41)
            });
            mapping[(int)BogusSystem.ControlCommand.ADL_ABL] = adlabl;

            GraphicsPath zadl0 = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.Z_ADL0] = zadl0;

            GraphicsPath zadl1 = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.Z_ADL1] = zadl1;

            GraphicsPath zadl2 = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.Z_ADL2] = zadl2;

            GraphicsPath zadh0 = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.Z_ADH0] = zadh0;

            GraphicsPath zadh17 = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.Z_ADH17] = zadh17;

            GraphicsPath sbdb = new GraphicsPath();
            sbdb.AddLines(new Point[] {
                new Point(458, 218),
                new Point(458, 162),
                new Point(570, 162),
                new Point(570, 187)
            });
            mapping[(int)BogusSystem.ControlCommand.SB_DB] = sbdb;

            GraphicsPath sbadh = new GraphicsPath();
            sbadh.AddLines(new Point[] {
                new Point(467, 222),
                new Point(562, 222)
            });
            mapping[(int)BogusSystem.ControlCommand.SB_ADH] = sbadh;

            GraphicsPath dladl = new GraphicsPath();
            dladl.AddLines(new Point[] {
                new Point(769, 82),
                new Point(769, 46)
            });
            mapping[(int)BogusSystem.ControlCommand.DL_ADL] = dladl;

            GraphicsPath dladh = new GraphicsPath();
            dladh.AddLines(new Point[] {
                new Point(758, 152),
                new Point(758, 217)
            });
            mapping[(int)BogusSystem.ControlCommand.DL_ADH] = dladh;

            GraphicsPath dldb = new GraphicsPath();
            dldb.AddLines(new Point[] {
                new Point(777, 151),
                new Point(777, 188)
            });
            mapping[(int)BogusSystem.ControlCommand.DL_DB] = dldb;

            // Flags

            GraphicsPath pdb = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.P_DB] = pdb;

            GraphicsPath dbp = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.DB_P] = dbp;

            GraphicsPath dbzz = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.DBZ_Z] = dbzz;

            GraphicsPath dbn = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.DB_N] = dbn;

            GraphicsPath ir5c = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.IR5_C] = ir5c;

            GraphicsPath dbc = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.DB_C] = dbc;

            GraphicsPath acrc = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.ACR_C] = acrc;

            GraphicsPath ir5d = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.IR5_D] = ir5d;

            GraphicsPath ir5i = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.IR5_I] = ir5i;

            GraphicsPath dbv = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.DB_V] = dbv;

            GraphicsPath avrv = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.AVR_V] = avrv;

            GraphicsPath zv = new GraphicsPath();
            mapping[(int)BogusSystem.ControlCommand.Z_V] = zv;
        }

        private void ReallocateGraphics()
        {
            context = BufferedGraphicsManager.Current;
            context.MaximumBuffer = new Size(Width + 1, Height + 1);

            gfx = context.Allocate(CreateGraphics(),
                 new Rectangle(0, 0, Width, Height));
        }

        protected override void OnSizeChanged(EventArgs e)
        {
            if (gfx != null)
            {
                gfx.Dispose();
                ReallocateGraphics();
            }

            Invalidate();
            base.OnSizeChanged(e);
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            if (gfx == null)
            {
                ReallocateGraphics();
            }

            long beginTime = DateTime.Now.Ticks;

            DrawScene(gfx.Graphics, Width, Height);

            gfx.Render(e.Graphics);

            long endTime = DateTime.Now.Ticks;
        }

        private void DrawScene(Graphics gr, int width, int height)
        {
            gr.Clear(BackColor);

            DrawImage(gr);
            DrawPaths(gr);
            DrawLabels(gr);
        }

        private void DrawImage(Graphics gr)
        {
            if (BackgroundImage != null)
            {
                float imageWidth = (float)BackgroundImage.Width;
                float imageHeight = (float)BackgroundImage.Height;
                float sx = 0;
                float sy = 0;

                gr.DrawImage(BackgroundImage, sx, sy, imageWidth, imageHeight);
            }
        }

        private void DrawPaths(Graphics gr)
        {
            if (cur_info == null)
                return;

            for (int i=0; i< (int)BogusSystem.ControlCommand.Max; i++)
            {
                if (cur_info.cmd[i] != 0)
                {
                    gr.DrawPath(path_pen, mapping[i]);
                }
            }
        }

        private void DrawLabels(Graphics gr)
        {
            Point point = new Point(263, 59);

            if (cur_info.cmd[(int)BogusSystem.ControlCommand.ANDS] != 0)
            {
                gr.DrawString("ANDS", labelFont, new SolidBrush(Color.Black), point);
            }

            if (cur_info.cmd[(int)BogusSystem.ControlCommand.EORS] != 0)
            {
                gr.DrawString("EORS", labelFont, new SolidBrush(Color.Black), point);
            }

            if (cur_info.cmd[(int)BogusSystem.ControlCommand.ORS] != 0)
            {
                gr.DrawString("ORS", labelFont, new SolidBrush(Color.Black), point);
            }

            if (cur_info.cmd[(int)BogusSystem.ControlCommand.SRS] != 0)
            {
                gr.DrawString("SRS", labelFont, new SolidBrush(Color.Black), point);
            }

            if (cur_info.cmd[(int)BogusSystem.ControlCommand.SUMS] != 0)
            {
                gr.DrawString("SUMS", labelFont, new SolidBrush(Color.Black), point);
            }
        }

        public void ShowCpuCommands(BogusSystem.CpuDebugInfo_Commands info)
        {
            cur_info = info;
            Invalidate();
        }

    }
}
