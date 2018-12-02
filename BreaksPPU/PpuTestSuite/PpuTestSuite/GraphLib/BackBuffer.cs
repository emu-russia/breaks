using System;
using System.Drawing;

 

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
    public class BackBuffer
    {
        private Graphics graphics;
        private Bitmap memoryBitmap;
        private int width;
        private int height;
        
        public BackBuffer()
        {
            width = 0;
            height = 0;
        }
       
        public bool Init(Graphics g, int width, int height)
        {
            if (memoryBitmap != null)
            {
                memoryBitmap.Dispose();
                memoryBitmap = null;
            }

            if (graphics != null)
            {
                graphics.Dispose();
                graphics = null;
            }

            if (width == 0 || height == 0)
                return false;

            if ((width != this.width) || 
                (height != this.height) || 
                graphics == null)
            {
                this.width = width;
                this.height = height;

                memoryBitmap = new Bitmap(width, height);
                graphics = Graphics.FromImage(memoryBitmap);
            }

            return true;
        }
        
        public void Render(Graphics g)
        {
            if (memoryBitmap != null)
            {
                g.DrawImage(memoryBitmap, 
                            new Rectangle(0, 0, width, height),
                            0, 0, width, height, 
                            GraphicsUnit.Pixel);
            }
        }
       
        public bool CanDoubleBuffer()
        {
            return graphics != null;
        }
        
        public Graphics g
        {
            get
            {
                return graphics;
            }
        }
    }
}
