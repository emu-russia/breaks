/// "Точка" (на самом деле может быть маленьким кружочком)

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Drawing;

namespace CanvasControl
{
    public class CanvasPoint : CanvasItem
    {
        public CanvasPoint(PointF pos)
        {
            Pos = pos;
        }

        public CanvasPoint(PointF pos, float width)
        {
            Pos = pos;
            Width = width;
            Height = width;
        }

        public CanvasPoint(PointF pos, float width, Color color)
        {
            Pos = pos;
            Width = width;
            Height = width;
            FrontColor = color;
        }

        public override void Draw(Graphics gr)
        {
            float zf = (float)parentControl.Zoom / 100.0F;

            Point screen = parentControl.WorldToScreen(Pos);
            int radius = (int)((float)Width * zf) / 2;

            gr.FillEllipse(new SolidBrush(FrontColor),
                screen.X - radius,
                screen.Y - radius,
                radius + radius,
                radius + radius);

            gr.DrawEllipse(new Pen(BorderColor, BorderWidth * zf),
                screen.X - radius,
                screen.Y - radius,
                radius + radius,
                radius + radius);

            if ( Selected)
            {
                gr.DrawEllipse(new Pen(Color.Lime, BorderWidth * zf * 2),
                    screen.X - radius,
                    screen.Y - radius,
                    radius + radius,
                    radius + radius);
            }
        }

        public override bool HitTest(PointF point)
        {
            PointF[] rect = new PointF[4];
            float radius = Width / 2;

            rect[0].X = Pos.X - radius;
            rect[0].Y = Pos.Y - radius;

            rect[1].X = Pos.X + radius;
            rect[1].Y = Pos.Y - radius;

            rect[2].X = Pos.X + radius;
            rect[2].Y = Pos.Y + radius;

            rect[3].X = Pos.X - radius;
            rect[3].Y = Pos.Y + radius;
            
            return CanvasMath.PointInPoly(rect, point);
        }

        public override bool BoxTest(RectangleF rect)
        {
            RectangleF rect2 = new RectangleF(Pos.X - Width / 2, Pos.Y - Width / 2,
                Width, Width);
            return rect.IntersectsWith(rect2);
        }

        public override CanvasItem CreateInstanceForClone()
        {
            return new CanvasPoint(Pos);
        }

    }
}
