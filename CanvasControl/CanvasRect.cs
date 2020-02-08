/// Прямоугольник

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Drawing;

namespace CanvasControl
{
    public class CanvasRect : CanvasItem
    {
        public CanvasRect(PointF pos, float width, float height)
        {
            Pos = pos;
            Width = width;
            Height = height;
        }

        public CanvasRect(PointF pos, float width, float height, Color color)
        {
            Pos = pos;
            Width = width;
            Height = height;
            FrontColor = color;
        }

        public override void Draw(Graphics gr)
        {
            float zf = (float)parentControl.Zoom / 100.0F;

            Point topLeft = parentControl.WorldToScreen(Pos);

            if (topLeft.X > parentControl.Width)
                return;
            if (topLeft.Y > parentControl.Height)
                return;

            Point bottomRight = parentControl.WorldToScreen( new PointF(Pos.X + Width, Pos.Y + Height));

            Point rectSize = new Point(bottomRight.X - topLeft.X,
                                       bottomRight.Y - topLeft.Y);

            gr.FillRectangle(new SolidBrush(FrontColor),
                topLeft.X,
                topLeft.Y,
                rectSize.X,
                rectSize.Y);

            gr.DrawRectangle(new Pen(BorderColor, BorderWidth * zf),
                topLeft.X,
                topLeft.Y,
                rectSize.X,
                rectSize.Y);

            if (Selected)
            {
                gr.DrawRectangle(new Pen(Color.Lime, BorderWidth * zf * 2),
                    topLeft.X,
                    topLeft.Y,
                    rectSize.X,
                    rectSize.Y);
            }
        }

        public override bool HitTest(PointF point)
        {
            PointF[] rect = new PointF[4];

            rect[0] = new PointF(Pos.X, Pos.Y);
            rect[1] = new PointF(Pos.X, Pos.Y + Height);
            rect[2] = new PointF(Pos.X + Width, Pos.Y + Height);
            rect[3] = new PointF(Pos.X + Width, Pos.Y);

            return CanvasMath.PointInPoly ( rect, point);
        }

        public override bool BoxTest(RectangleF rect)
        {
            RectangleF rect2 = new RectangleF( Pos.X, Pos.Y,
                                               Width, Height);
            return rect.IntersectsWith(rect2);
        }

        public override CanvasItem CreateInstanceForClone()
        {
            return new CanvasRect(Pos, Width, Height);
        }

    }
}
