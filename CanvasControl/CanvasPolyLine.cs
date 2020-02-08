/// Ломаная линия

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Drawing;

namespace CanvasControl
{
    public class CanvasPolyLine : CanvasItem
    {
        public CanvasPolyLine()
        {
            Width = 1;
        }

        public CanvasPolyLine(List<PointF> points)
        {
            Points = points;
            Width = 1;
        }

        public CanvasPolyLine(List<PointF> points, float width)
        {
            Points = points;
            Width = width;
        }

        public CanvasPolyLine(List<PointF> points, float width, Color color)
        {
            Points = points;
            Width = width;
            FrontColor = color;
        }

        public override void Draw(Graphics gr)
        {
            if (Points.Count < 2)
                return;

            float zf = (float)parentControl.Zoom / 100.0F;

            List<Point> translated = new List<Point>();

            foreach (var p in Points)
            {
                translated.Add(parentControl.WorldToScreen(p));
            }

            gr.DrawLines(new Pen(FrontColor, Width * zf), translated.ToArray());

            if (Selected)
            {
                gr.DrawLines(new Pen(Color.Lime, Width * zf * 2), translated.ToArray());
            }
        }

        public override void DrawText(Graphics gr)
        {
            List<Point> translated = new List<Point>();

            foreach (var p in Points)
            {
                translated.Add(parentControl.WorldToScreen(p));
            }

            if (translated.Count < 2)
                return;

            float zf = (float)parentControl.Zoom / 100.0F;

            gr.DrawString(Text, parentControl.Font, new SolidBrush(TextColor), 
                translated[translated.Count - 2].X, translated[translated.Count - 2].Y);
        }

        public override bool HitTest(PointF point)
        {
            if (Points.Count < 2)
                return false;

            for (int i=0; i<Points.Count; i++)
            {
                if (i == 0)
                    continue;

                if (CanvasMath.PointOnLine(Points[i], Points[i - 1], point, Width))
                    return true;
            }

            return false;
        }

        public override bool BoxTest(RectangleF rect)
        {
            if (Points.Count < 2)
                return false;

            for (int i = 0; i < Points.Count; i++)
            {
                if (i == 0)
                    continue;

                if (CanvasMath.LineIntersectsRect(Points[i], Points[i-1], rect))
                    return true;
            }

            return false;
        }

        public override CanvasItem CreateInstanceForClone()
        {
            return new CanvasPolyLine();
        }

    }
}
