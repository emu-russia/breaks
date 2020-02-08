/// Линия

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Drawing;

namespace CanvasControl
{
    public class CanvasLine : CanvasItem
    {
        public CanvasLine(PointF start, PointF end)
        {
            Pos = start;
            PosEnd = end;
            Width = 1;
        }

        public CanvasLine(PointF start, PointF end, float width)
        {
            Pos = start;
            PosEnd = end;
            Width = width;
        }

        public CanvasLine(PointF start, PointF end, Color color)
        {
            Pos = start;
            PosEnd = end;
            Width = 1;
            FrontColor = color;
        }

        public CanvasLine(PointF start, PointF end, float width, Color color)
        {
            Pos = start;
            PosEnd = end;
            Width = width;
            FrontColor = color;
        }

        public override void Draw(Graphics gr)
        {
            if (Width <= 0)
                return;

            float zf = (float)parentControl.Zoom / 100.0F;

            Point start = parentControl.WorldToScreen(Pos);
            Point end = parentControl.WorldToScreen(PosEnd);

            if (Selected)
            {
                gr.DrawLine(new Pen(Color.Lime, Width * zf * 2), start, end);
            }

            gr.DrawLine(new Pen(FrontColor, Width * zf), start, end);
        }

        public override bool HitTest(PointF point)
        {
            return CanvasMath.PointOnLine(Pos, PosEnd, point, Width);
        }

        public override bool BoxTest(RectangleF rect)
        {
            return CanvasMath.LineIntersectsRect(Pos, PosEnd, rect);
        }

        public override CanvasItem CreateInstanceForClone()
        {
            return new CanvasLine(Pos, PosEnd);
        }

    }

}
