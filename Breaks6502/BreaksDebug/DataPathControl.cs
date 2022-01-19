// Control for visualizing the state of the data flows inside the bottom part of the processor.

using System;
using System.ComponentModel;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;
using System.Collections.Generic;
using System.Drawing.Imaging;

using System.IO;

namespace BreaksDebug
{
    public partial class DataPathView : Control
    {
        private BufferedGraphics gfx = null;
        private BufferedGraphicsContext context;
        GraphicsPath [] mapping = new GraphicsPath[(int)BogusSystem.ControlCommand.Max];
        GraphicsPath cpu_write = new GraphicsPath();
        GraphicsPath cpu_read = new GraphicsPath();
        GraphicsPath alu_add = new GraphicsPath();
        BogusSystem.CpuDebugInfo_Commands cur_info = null;
        bool SavedPHI1 = false;
        Pen path_pen = new Pen(new SolidBrush(Color.OrangeRed), 5);
        Font labelFont = new Font("Segoe UI", 10.0f, FontStyle.Bold);
        Brush labelBrush = new SolidBrush(Color.Black);

        public DataPathView()
        {
            SetStyle(ControlStyles.OptimizedDoubleBuffer, true);

            // Initialize the mapping to highlight the paths of each command.
            // The mapping is bound to the original image, so you have to reassign it each time you change the image.

            // Regs

            GraphicsPath ysb = new GraphicsPath();
            ysb.AddLines(new Point[] {
                new Point(119, 151),
                new Point(119, 216),
                new Point(111, 210),
                new Point(127, 210),
                new Point(119, 216)
            });
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
            xsb.AddLines(new Point[] {
                new Point(157, 151),
                new Point(157, 217),
                new Point(149, 210),
                new Point(164, 210),
                new Point(157, 217)
            });
            mapping[(int)BogusSystem.ControlCommand.X_SB] = xsb;

            GraphicsPath sbx = new GraphicsPath();
            sbx.AddLines(new Point[] {
                new Point(157, 217),
                new Point(157, 152),
                new Point(148, 158),
                new Point(165, 158),
                new Point(157, 152)
            });
            mapping[(int)BogusSystem.ControlCommand.SB_X] = sbx;

            GraphicsPath sadl = new GraphicsPath();
            sadl.AddLines(new Point[] {
                new Point(194, 81),
                new Point(194, 45),
                new Point(186, 52),
                new Point(202, 52),
                new Point(194, 45)
            });
            mapping[(int)BogusSystem.ControlCommand.S_ADL] = sadl;

            GraphicsPath ssb = new GraphicsPath();
            ssb.AddLines(new Point[] {
                new Point(195, 151),
                new Point(195, 217),
                new Point(187, 210),
                new Point(202, 210),
                new Point(195, 217)
            });
            mapping[(int)BogusSystem.ControlCommand.S_SB] = ssb;

            GraphicsPath sbs = new GraphicsPath();
            sbs.AddLines(new Point[] {
                new Point(194, 217),
                new Point(194, 151),
                new Point(186, 158),
                new Point(202, 158),
                new Point(194, 151)
            });
            mapping[(int)BogusSystem.ControlCommand.SB_S] = sbs;

            GraphicsPath ss = new GraphicsPath();
            ss.AddLines(new Point[] {
                new Point(210, 100),
                new Point(216, 100),
                new Point(216, 132),
                new Point(210, 132)
            });
            mapping[(int)BogusSystem.ControlCommand.S_S] = ss;

            // ALU

            GraphicsPath ndbadd = new GraphicsPath();
            ndbadd.AddLines(new Point[] {
                new Point(240, 187),
                new Point(240, 137),
                new Point(261, 137)
            });
            mapping[(int)BogusSystem.ControlCommand.NDB_ADD] = ndbadd;

            GraphicsPath dbadd = new GraphicsPath();
            dbadd.AddLines(new Point[] {
                new Point(247, 188),
                new Point(247, 148),
                new Point(261, 148)
            });
            mapping[(int)BogusSystem.ControlCommand.DB_ADD] = dbadd;

            GraphicsPath zadd = new GraphicsPath();
            zadd.AddLines(new Point[] {
                new Point(247, 94),
                new Point(261, 94)
            });
            mapping[(int)BogusSystem.ControlCommand.Z_ADD] = zadd;

            GraphicsPath sbadd = new GraphicsPath();
            sbadd.AddLines(new Point[] {
                new Point(232, 217),
                new Point(232, 83),
                new Point(261, 83)
            });
            mapping[(int)BogusSystem.ControlCommand.SB_ADD] = sbadd;

            GraphicsPath adladd = new GraphicsPath();
            adladd.AddLines(new Point[] {
                new Point(222, 46),
                new Point(222, 127),
                new Point(261, 127)
            });
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
            addsb7.AddLines(new Point[] {
                new Point(347, 135),
                new Point(347, 218),
                new Point(340, 210),
                new Point(354, 210),
                new Point(347, 218)
            });
            mapping[(int)BogusSystem.ControlCommand.ADD_SB7] = addsb7;

            GraphicsPath addsb06 = new GraphicsPath();
            addsb06.AddLines(new Point[] {
                new Point(327, 136),
                new Point(327, 217),
                new Point(320, 210),
                new Point(335, 210),
                new Point(327, 217)
            });
            mapping[(int)BogusSystem.ControlCommand.ADD_SB06] = addsb06;

            GraphicsPath addadl = new GraphicsPath();
            addadl.AddLines(new Point[] {
                new Point(335, 89),
                new Point(335, 45),
                new Point(328, 53),
                new Point(343, 52),
                new Point(335, 45)
            });
            mapping[(int)BogusSystem.ControlCommand.ADD_ADL] = addadl;

            GraphicsPath sbac = new GraphicsPath();
            sbac.AddLines(new Point[] {
                new Point(382, 217),
                new Point(382, 113),
                new Point(412, 113),
                new Point(404, 105),
                new Point(404, 120),
                new Point(412, 113)
            });
            mapping[(int)BogusSystem.ControlCommand.SB_AC] = sbac;

            GraphicsPath acsb = new GraphicsPath();
            acsb.AddLines(new Point[] {
                new Point(419, 151),
                new Point(419, 218),
                new Point(412, 211),
                new Point(427, 211),
                new Point(419, 218)
            });
            mapping[(int)BogusSystem.ControlCommand.AC_SB] = acsb;

            GraphicsPath acdb = new GraphicsPath();
            acdb.AddLines(new Point[] {
                new Point(434, 152),
                new Point(434, 188),
                new Point(427, 180),
                new Point(442, 180),
                new Point(434, 188)
            });
            mapping[(int)BogusSystem.ControlCommand.AC_DB] = acdb;

            // PC

            GraphicsPath adhpch = new GraphicsPath();
            adhpch.AddLines(new Point[] {
                new Point(614, 217),
                new Point(614, 151),
                new Point(606, 158),
                new Point(621, 158),
                new Point(614, 151)
            });
            mapping[(int)BogusSystem.ControlCommand.ADH_PCH] = adhpch;

            GraphicsPath pchpch = new GraphicsPath();
            pchpch.AddLines(new Point[] {
                new Point(606, 99),
                new Point(600, 99),
                new Point(600, 130),
                new Point(606, 130)
            });
            mapping[(int)BogusSystem.ControlCommand.PCH_PCH] = pchpch;

            GraphicsPath pchadh = new GraphicsPath();
            pchadh.AddLines(new Point[] {
                new Point(614, 151),
                new Point(614, 217),
                new Point(607, 210),
                new Point(620, 210),
                new Point(614, 217)
            });
            mapping[(int)BogusSystem.ControlCommand.PCH_ADH] = pchadh;

            GraphicsPath pchdb = new GraphicsPath();
            pchdb.AddLines(new Point[] {
                new Point(636, 151),
                new Point(636, 188),
                new Point(629, 180),
                new Point(644, 180),
                new Point(636, 188)
            });
            mapping[(int)BogusSystem.ControlCommand.PCH_DB] = pchdb;

            GraphicsPath adlpcl = new GraphicsPath();
            adlpcl.AddLines(new Point[] {
                new Point(670, 45),
                new Point(670, 82),
                new Point(663, 75),
                new Point(677, 75),
                new Point(670, 82)
            });
            mapping[(int)BogusSystem.ControlCommand.ADL_PCL] = adlpcl;

            GraphicsPath pclpcl = new GraphicsPath();
            pclpcl.AddLines(new Point[] {
                new Point(689, 99),
                new Point(695, 99),
                new Point(695, 131),
                new Point(689, 131)
            });
            mapping[(int)BogusSystem.ControlCommand.PCL_PCL] = pclpcl;

            GraphicsPath pcladl = new GraphicsPath();
            pcladl.AddLines(new Point[] {
                new Point(670, 82),
                new Point(670, 45),
                new Point(662, 52),
                new Point(677, 52),
                new Point(670, 45)
            });
            mapping[(int)BogusSystem.ControlCommand.PCL_ADL] = pcladl;

            GraphicsPath pcldb = new GraphicsPath();
            pcldb.AddLines(new Point[] {
                new Point(670, 151),
                new Point(670, 187),
                new Point(663, 180),
                new Point(678, 180),
                new Point(670, 187)
            });
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
            zadl0.AddLines(new Point[] {
                new Point(539, 64),
                new Point(584, 64),
                new Point(583, 45),
                new Point(576, 52),
                new Point(591, 52),
                new Point(583, 45)
            });
            mapping[(int)BogusSystem.ControlCommand.Z_ADL0] = zadl0;

            GraphicsPath zadl1 = new GraphicsPath();
            zadl1.AddLines(new Point[] {
                new Point(539, 75),
                new Point(584, 75),
                new Point(583, 45),
                new Point(576, 52),
                new Point(591, 52),
                new Point(583, 45)
            });
            mapping[(int)BogusSystem.ControlCommand.Z_ADL1] = zadl1;

            GraphicsPath zadl2 = new GraphicsPath();
            zadl2.AddLines(new Point[] {
                new Point(539, 86),
                new Point(584, 86),
                new Point(583, 45),
                new Point(576, 52),
                new Point(591, 52),
                new Point(583, 45)
            });
            mapping[(int)BogusSystem.ControlCommand.Z_ADL2] = zadl2;

            GraphicsPath zadh0 = new GraphicsPath();
            zadh0.AddLines(new Point[] {
                new Point(539, 113),
                new Point(583, 113),
                new Point(583, 217),
                new Point(576, 210),
                new Point(591, 210),
                new Point(583, 217)
            });
            mapping[(int)BogusSystem.ControlCommand.Z_ADH0] = zadh0;

            GraphicsPath zadh17 = new GraphicsPath();
            zadh17.AddLines(new Point[] {
                new Point(539, 122),
                new Point(583, 122),
                new Point(583, 217),
                new Point(576, 210),
                new Point(591, 210),
                new Point(583, 217)
            });
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
                new Point(767, 81),
                new Point(767, 45),
                new Point(759, 53),
                new Point(775, 53),
                new Point(767, 45)
            });
            mapping[(int)BogusSystem.ControlCommand.DL_ADL] = dladl;

            GraphicsPath dladh = new GraphicsPath();
            dladh.AddLines(new Point[] {
                new Point(756, 151),
                new Point(756, 217),
                new Point(749, 210),
                new Point(764, 210),
                new Point(756, 217)
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
            pdb.AddLines(new Point[] {
                new Point(719, 151),
                new Point(719, 188),
                new Point(712, 180),
                new Point(726, 180),
                new Point(719, 188)
            });
            mapping[(int)BogusSystem.ControlCommand.P_DB] = pdb;

            GraphicsPath dbp = new GraphicsPath();
            dbp.AddLines(new Point[] {
                new Point(719, 186),
                new Point(719, 152),
                new Point(711, 158),
                new Point(726, 158),
                new Point(719, 152)
            });
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

            // CPU R/W

            cpu_read.AddLines(new Point[] {
                new Point(769, 181),
                new Point(777, 187),
                new Point(783, 181)
            });

            cpu_write.AddLines(new Point[] {
                new Point(769, 157),
                new Point(777, 151),
                new Point(783, 157)
            });

            // ALU -> ADD

            alu_add.AddLines(new Point[] {
                new Point(305, 112),
                new Point(321, 112),
                new Point(317, 108),
                new Point(317, 116),
                new Point(321, 112)
            });
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
                    // ABH/ABL are only set during PHI1, even if commands are active, they are blocked.

                    if ((i == (int)BogusSystem.ControlCommand.ADL_ABL || i == (int)BogusSystem.ControlCommand.ADH_ABH) && !SavedPHI1)
                    {
                        continue;
                    }

                    gr.DrawPath(path_pen, mapping[i]);
                }
            }

            if (cur_info.cmd[(int)BogusSystem.ControlCommand.DL_DB] != 0)
            {
                if (cur_info.WR)
                {
                    gr.DrawPath(path_pen, cpu_write);
                }
                else
                {
                    gr.DrawPath(path_pen, cpu_read);
                }
            }
        }

        private void DrawLabels(Graphics gr)
        {
            if (cur_info == null)
                return;

            Point point = new Point(263, 59);

            // ALU operations are saved only during PHI2

            if (!SavedPHI1)
            {
                bool anyOp = false;

                if (cur_info.cmd[(int)BogusSystem.ControlCommand.ANDS] != 0)
                {
                    gr.DrawString("ANDS", labelFont, labelBrush, point);
                    anyOp = true;
                }

                if (cur_info.cmd[(int)BogusSystem.ControlCommand.EORS] != 0)
                {
                    gr.DrawString("EORS", labelFont, labelBrush, point);
                    anyOp = true;
                }

                if (cur_info.cmd[(int)BogusSystem.ControlCommand.ORS] != 0)
                {
                    gr.DrawString("ORS", labelFont, labelBrush, point);
                    anyOp = true;
                }

                if (cur_info.cmd[(int)BogusSystem.ControlCommand.SRS] != 0)
                {
                    gr.DrawString("SRS", labelFont, labelBrush, point);
                    anyOp = true;
                }

                if (cur_info.cmd[(int)BogusSystem.ControlCommand.SUMS] != 0)
                {
                    gr.DrawString("SUMS", labelFont, labelBrush, point);
                    anyOp = true;
                }

                if (cur_info.n_ACIN == 0 && anyOp)
                {
                    gr.DrawString("+C", labelFont, labelBrush, new Point(300, 70));
                }

                if (anyOp)
                {
                    gr.DrawPath(path_pen, alu_add);
                }
            }

            if (cur_info.n_DAA == 0)
            {
                gr.DrawString("DAA", labelFont, labelBrush, new Point(367, 52));
            }
            if (cur_info.n_DSA == 0)
            {
                gr.DrawString("DSA", labelFont, labelBrush, new Point(367, 72));
            }

            if (cur_info.n_1PC == 0)
            {
                gr.DrawString("+1", labelFont, labelBrush, new Point(635, 64));
            }
        }

        public void ShowCpuCommands(BogusSystem.CpuDebugInfo_Commands info, bool PHI1)
        {
            cur_info = info;
            SavedPHI1 = PHI1;
            Invalidate();
        }

        public void SaveSceneAsImage(string FileName)
        {
            ImageFormat imageFormat;
            string ext;

            if (BackgroundImage == null)
                return;

            int bitmapWidth = BackgroundImage.Width;
            int bitmapHeight = BackgroundImage.Height;

            Bitmap bitmap = new Bitmap(bitmapWidth, bitmapHeight, PixelFormat.Format16bppRgb565);

            Graphics gr = Graphics.FromImage(bitmap);

            DrawScene(gr, bitmapWidth, bitmapHeight);

            ext = Path.GetExtension(FileName);

            if (ext.ToLower() == ".jpg" || ext.ToLower() == ".jpeg")
                imageFormat = ImageFormat.Jpeg;
            else if (ext.ToLower() == ".png")
                imageFormat = ImageFormat.Png;
            else if (ext.ToLower() == ".bmp")
                imageFormat = ImageFormat.Bmp;
            else
                imageFormat = ImageFormat.Jpeg;

            bitmap.Save(FileName, imageFormat);

            bitmap.Dispose();
            gr.Dispose();
        }

    }
}
