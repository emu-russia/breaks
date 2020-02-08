using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Drawing;

namespace CanvasControl
{
    public class CanvasMath
    {
        // Detect intersection of various objects

        public static bool LineIntersectsRect(PointF p1, PointF p2, RectangleF r)
        {
            return LineIntersectsLine(p1, p2, new PointF(r.X, r.Y), new PointF(r.X + r.Width, r.Y)) ||
                   LineIntersectsLine(p1, p2, new PointF(r.X + r.Width, r.Y), new PointF(r.X + r.Width, r.Y + r.Height)) ||
                   LineIntersectsLine(p1, p2, new PointF(r.X + r.Width, r.Y + r.Height), new PointF(r.X, r.Y + r.Height)) ||
                   LineIntersectsLine(p1, p2, new PointF(r.X, r.Y + r.Height), new PointF(r.X, r.Y)) ||
                   (r.Contains(p1) && r.Contains(p2));
        }

        public static bool LineIntersectsLine(PointF l1p1, PointF l1p2, PointF l2p1, PointF l2p2)
        {
            float q = (l1p1.Y - l2p1.Y) * (l2p2.X - l2p1.X) - (l1p1.X - l2p1.X) * (l2p2.Y - l2p1.Y);
            float d = (l1p2.X - l1p1.X) * (l2p2.Y - l2p1.Y) - (l1p2.Y - l1p1.Y) * (l2p2.X - l2p1.X);

            if (d == 0)
            {
                return false;
            }

            float r = q / d;

            q = (l1p1.Y - l2p1.Y) * (l1p2.X - l1p1.X) - (l1p1.X - l2p1.X) * (l1p2.Y - l1p1.Y);
            float s = q / d;

            if (r < 0 || r > 1 || s < 0 || s > 1)
            {
                return false;
            }

            return true;
        }

        public static bool PointInPoly(PointF[] poly, PointF point)
        {
            int max_point = poly.Length - 1;
            float total_angle = GetAngle(
                poly[max_point].X, poly[max_point].Y,
                point.X, point.Y,
                poly[0].X, poly[0].Y);

            for (int i = 0; i < max_point; i++)
            {
                total_angle += GetAngle(
                    poly[i].X, poly[i].Y,
                    point.X, point.Y,
                    poly[i + 1].X, poly[i + 1].Y);
            }

            return (Math.Abs(total_angle) > 0.000001);
        }

        public static float GetAngle(float Ax, float Ay,
            float Bx, float By, float Cx, float Cy)
        {
            float dot_product = DotProduct(Ax, Ay, Bx, By, Cx, Cy);

            float cross_product = CrossProductLength(Ax, Ay, Bx, By, Cx, Cy);

            return (float)Math.Atan2(cross_product, dot_product);
        }

        public static float DotProduct(float Ax, float Ay,
            float Bx, float By, float Cx, float Cy)
        {
            float BAx = Ax - Bx;
            float BAy = Ay - By;
            float BCx = Cx - Bx;
            float BCy = Cy - By;

            return (BAx * BCx + BAy * BCy);
        }

        public static float CrossProductLength(float Ax, float Ay,
            float Bx, float By, float Cx, float Cy)
        {
            float BAx = Ax - Bx;
            float BAy = Ay - By;
            float BCx = Cx - Bx;
            float BCy = Cy - By;

            return (BAx * BCy - BAy * BCx);
        }

        // Transformations

        public static PointF RotatePoint(PointF point, double angle)
        {
            PointF rotated_point = new Point();
            double rad = angle * Math.PI / 180.0F;
            rotated_point.X = point.X * (float)Math.Cos(rad) - point.Y * (float)Math.Sin(rad);
            rotated_point.Y = point.X * (float)Math.Sin(rad) + point.Y * (float)Math.Cos(rad);
            return rotated_point;
        }

        public static bool PointOnLine (PointF start, PointF end, PointF point, float lineWidth)
        {
            PointF[] rect = new PointF[4];

            if (lineWidth <= 0)
                return false;

            if (end.X < start.X)
            {
                PointF temp = start;
                start = end;
                end = temp;
            }

            if (point.X < start.X || point.X > end.X)
                return false;

            PointF ortho = new PointF(end.X - start.X, end.Y - start.Y);

            float len = (float)Math.Sqrt(Math.Pow(ortho.X, 2) +
                                          Math.Pow(ortho.Y, 2));
            len = Math.Max(1.0F, len);

            PointF rot = CanvasMath.RotatePoint(ortho, -90);
            PointF normalized = new PointF(rot.X / len, rot.Y / len);
            PointF baseVect = new PointF(normalized.X * (lineWidth / 2),
                                          normalized.Y * (lineWidth / 2));

            rect[0].X = baseVect.X + start.X;
            rect[0].Y = baseVect.Y + start.Y;
            rect[3].X = baseVect.X + end.X;
            rect[3].Y = baseVect.Y + end.Y;

            rot = CanvasMath.RotatePoint(ortho, +90);
            normalized = new PointF(rot.X / len, rot.Y / len);
            baseVect = new PointF(normalized.X * (lineWidth / 2),
                                   normalized.Y * (lineWidth / 2));

            rect[1].X = baseVect.X + start.X;
            rect[1].Y = baseVect.Y + start.Y;
            rect[2].X = baseVect.X + end.X;
            rect[2].Y = baseVect.Y + end.Y;

            return CanvasMath.PointInPoly(rect, point);
        }

    }
}
