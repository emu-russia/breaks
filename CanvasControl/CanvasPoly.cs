/// Регион

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Drawing;
using System.Drawing.Drawing2D;

namespace CanvasControl
{
    public class CanvasPoly : CanvasItem
    {
        public CanvasPoly(List<PointF> points)
        {
            Points = points;
            Width = 1;
        }

        public CanvasPoly(List<PointF> points, float width)
        {
            Points = points;
            Width = width;
        }

        public CanvasPoly(List<PointF> points, float width, Color color)
        {
            Points = points;
            Width = width;
            FrontColor = color;
        }

        public override void Draw(Graphics gr)
        {
            if (Points.Count < 3)
                return;

            float zf = (float)parentControl.Zoom / 100.0F;

            GraphicsPath gp = new GraphicsPath();

            PointF prev = parentControl.WorldToScreen(Points[0]);
            PointF first = prev;

            foreach (PointF pathPoint in Points)
            {
                PointF translated = parentControl.WorldToScreen(pathPoint);
                gp.AddLine(prev, translated);
                prev = translated;
            }

            gp.AddLine(prev, first);

            gr.FillPath(new SolidBrush(FrontColor), gp);

            gr.DrawPath(new Pen(FrontColor, BorderWidth * zf), gp);

            if ( Selected)
            {
                gr.DrawPath(new Pen(Color.Lime, BorderWidth * zf * 2), gp);
            }
        }

        public override bool HitTest(PointF point)
        {
            PointF[] poly = new PointF[Points.Count];

            int idx = 0;
            foreach (PointF pathPoint in Points)
            {
                poly[idx++] = new PointF(pathPoint.X, pathPoint.Y);
            }

            return CanvasMath.PointInPoly(poly, point);
        }

        public override bool BoxTest(RectangleF rect)
        {
            foreach (PointF point in Points)
            {
                if (rect.Contains(point))
                {
                    return true;
                }
            }
            return false;
        }

        public override CanvasItem CreateInstanceForClone()
        {
            return new CanvasPoly(Points);
        }

    }
}
