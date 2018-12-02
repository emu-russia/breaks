using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using System.Drawing.Drawing2D;
using System.Threading;

public class ImageHelper
{

    // https://stackoverflow.com/questions/2163829/how-do-i-rotate-a-picture-in-winforms

    public static Image RotateImage(Image img, float rotationAngle)
    {
        //create an empty Bitmap image
        Bitmap bmp = new Bitmap(img.Width, img.Height);

        //turn the Bitmap into a Graphics object
        Graphics gfx = Graphics.FromImage(bmp);

        //now we set the rotation point to the center of our image
        gfx.TranslateTransform((float)bmp.Width / 2, (float)bmp.Height / 2);

        //now rotate the image
        gfx.RotateTransform(rotationAngle);

        gfx.TranslateTransform(-(float)bmp.Width / 2, -(float)bmp.Height / 2);

        //set the InterpolationMode to HighQualityBicubic so to ensure a high
        //quality image once it is transformed to the specified size
        gfx.InterpolationMode = InterpolationMode.HighQualityBicubic;

        //now draw our new image onto the graphics object
        gfx.DrawImage(img, new Point(0, 0));

        //dispose of our Graphics object
        gfx.Dispose();

        //return the image
        return bmp;
    }

    public static Image HighlightRect (Image img, Rectangle [] rect, Color [] color)
    {
        //create an empty Bitmap image
        Bitmap bmp = new Bitmap(img.Width, img.Height);

        //turn the Bitmap into a Graphics object
        Graphics gfx = Graphics.FromImage(bmp);

        //draw our old image onto the graphics object
        gfx.DrawImage(img, new Point(0, 0));

        //highlight rects
        for (int i = 0; i < rect.Length; i++)
        {
            Brush brush = new SolidBrush(color[i]);
            gfx.FillRectangle(brush, rect[i]);
        }

        //dispose of our Graphics object
        gfx.Dispose();

        //return the image
        return bmp;
    }
}
