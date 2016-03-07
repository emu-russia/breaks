//
// NTSC signal renderer
//

using System;
using System.ComponentModel;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;
using System.Collections.Generic;
using System.Drawing.Imaging;
using System.IO;
using System.Xml.Serialization;
using System.Linq;

namespace System.Windows.Forms
{
    public enum PixelGeometry
    {
        Stripes,
        Triangular
    }

    public struct ScreenElement
    {
        public int Red;
        public int Green;
        public int Blue;
    }

    public partial class TvScreen : Control
    {
        private BufferedGraphics gfx = null;
        private BufferedGraphicsContext context;

        private int _ScreenWidth = 682;
        private int _ScreenHeight = 512;
        private PixelGeometry _ScreenType = PixelGeometry.Stripes;
        private ScreenElement[] _screen;
        private Bitmap _screenBitmap;

        [Category("Screen Settings")]
        public int ScreenWidth
        {
            get { return _ScreenWidth; }
            set { _ScreenWidth = value; }
        }

        [Category("Screen Settings")]
        public int ScreenHeight
        {
            get { return _ScreenHeight; }
            set { _ScreenHeight = value; }
        }

        [Category("Screen Settings")]
        public PixelGeometry ScreenType
        {
            get { return _ScreenType; }
            set { _ScreenType = value; }
        }

        private void ReinitScreen ()
        {
            _screen = new ScreenElement[ScreenWidth * ScreenHeight];

            Noise();

            //FromImage(@"C:\Users\user\Pictures\ff7_demo4.png");

            _screenBitmap = new Bitmap(ScreenWidth * 6, ScreenHeight * 6);
        }

        private void Noise ()
        {
            Random rnd = new Random();

            for (int Line = 0; Line < ScreenHeight; Line++)
            {
                for (int Horz = 0; Horz < ScreenWidth; Horz++)
                {
                    _screen[Line * ScreenWidth + Horz].Red = 
                    _screen[Line * ScreenWidth + Horz].Green = 
                    _screen[Line * ScreenWidth + Horz].Blue = rnd.Next(256);
                }
            }
        }

        private void FromImage (string Filename)
        {
            Bitmap bitmap = new Bitmap(Filename);

            int MaxWidth = Math.Min(ScreenWidth, bitmap.Width);
            int MaxHeight = Math.Min(ScreenHeight, bitmap.Height);

            for (int Line = 0; Line < MaxHeight; Line++)
            {
                for (int Horz = 0; Horz < MaxWidth; Horz++)
                {
                    Color color = bitmap.GetPixel(Horz, Line);

                    _screen[Line * ScreenWidth + Horz].Red = color.R;
                    _screen[Line * ScreenWidth + Horz].Green = color.G;
                    _screen[Line * ScreenWidth + Horz].Blue = color.B;
                }
            }
        }

        public TvScreen()
        {
            ReinitScreen();
        }

        private void RefreshBitmap ()
        {
            BitmapData data = _screenBitmap.LockBits( new Rectangle(0, 0, _screenBitmap.Width, _screenBitmap.Height),
                                                      ImageLockMode.ReadWrite, PixelFormat.Format24bppRgb );

            for (int Line=0; Line<ScreenHeight; Line++)
            {
                for (int Horz=0; Horz<ScreenWidth; Horz++)
                {
                    ScreenElement currentPixel = _screen[Line * ScreenWidth + Horz];

                    unsafe
                    {
                        byte* ptr;

                        for (int n=0; n<6; n++)
                        {
                            ptr = (byte*)data.Scan0 +
                                  Line * data.Stride * 6 +  
                                  n * data.Stride +
                                  Horz * 3 * 6;

                            ptr[3 * 0 + 0] = (byte)currentPixel.Blue;
                            ptr[3 * 0 + 1] = 0;
                            ptr[3 * 0 + 2] = 0;
                            ptr[3 * 1 + 0] = (byte)currentPixel.Blue;
                            ptr[3 * 1 + 1] = 0;
                            ptr[3 * 1 + 2] = 0;

                            ptr[3 * 2 + 0] = 0;
                            ptr[3 * 2 + 1] = (byte)currentPixel.Green;
                            ptr[3 * 2 + 2] = 0;
                            ptr[3 * 3 + 0] = 0;
                            ptr[3 * 3 + 1] = (byte)currentPixel.Green;
                            ptr[3 * 3 + 2] = 0;

                            ptr[3 * 4 + 0] = 0;
                            ptr[3 * 4 + 1] = 0;
                            ptr[3 * 4 + 2] = (byte)currentPixel.Red;
                            ptr[3 * 5 + 0] = 0;
                            ptr[3 * 5 + 1] = 0;
                            ptr[3 * 5 + 2] = (byte)currentPixel.Red;
                        }

                    }
                }
            }

            _screenBitmap.UnlockBits(data);
        }

        private void ReallocateGraphics()
        {
            context = BufferedGraphicsManager.Current;
            context.MaximumBuffer = new Size(Width + 1, Height + 1);

            gfx = context.Allocate(CreateGraphics(),
                 new Rectangle(0, 0, Width, Height));
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            if (gfx == null)
                ReallocateGraphics();

            RefreshBitmap();

            gfx.Graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;

            float brightness = 1.1f;
            float contrast = 1.0f;
            float gamma = 1.0f; 

            float adjustedBrightness = brightness - 1.0f;
            // create matrix that will brighten and contrast the image
            float[][] ptsArray ={
            new float[] {contrast, 0, 0, 0, 0}, // scale red
            new float[] {0, contrast, 0, 0, 0}, // scale green
            new float[] {0, 0, contrast, 0, 0}, // scale blue
            new float[] {0, 0, 0, 1.0f, 0}, // don't scale alpha
            new float[] {adjustedBrightness, adjustedBrightness, adjustedBrightness, 0, 1}};

            ImageAttributes imageAttributes = new ImageAttributes();
            imageAttributes.ClearColorMatrix();
            imageAttributes.SetColorMatrix(new ColorMatrix(ptsArray), ColorMatrixFlag.Default, ColorAdjustType.Bitmap);
            imageAttributes.SetGamma(gamma, ColorAdjustType.Bitmap);

            Rectangle rect = new Rectangle(0, 0, Width, Height);

            gfx.Graphics.DrawImage( _screenBitmap, rect,
                                    0, 0, _screenBitmap.Width, _screenBitmap.Height,
                                    GraphicsUnit.Pixel, imageAttributes);

            gfx.Render(e.Graphics);
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
    }
}
