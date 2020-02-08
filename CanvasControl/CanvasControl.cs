/// Контрол для отображения различных элементов
/// 
/// Все координаты являются мировыми координатами

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace CanvasControl
{
    public partial class CanvasControl: Control
    {
        private BufferedGraphics gfx = null;
        private BufferedGraphicsContext context;
        private List<CanvasItem> items = new List<CanvasItem>();

        /// <summary>
        /// Свойства контрола
        /// </summary>

        private int _zoom = 100;
        public int Zoom
        {
            get
            {
                return _zoom;
            }
            set
            {
                if (value < 20)
                    value = 20;

                if (value > 400)
                    value = 400;

                _zoom = value;
            }

        }

        public PointF Scroll = new PointF(0, 0);

        public bool ShowGrid { get; set; } = true;
        public int GridSize { get; set; } = 20;
        public Color GridColor { get; set; } = Color.Black;
        public bool ShowOrigin { get; set; } = true;
        public Color OriginColor { get; set; } = Color.Red;

        public CanvasControl()
        {
            SetStyle(ControlStyles.OptimizedDoubleBuffer, true);
        }

        public void AddItem (CanvasItem item)
        {
            item.SetParentControl(this);
            items.Add(item);
        }

        public void RemoveItem (CanvasItem item)
        {
            item.SetParentControl(null);
            items.Remove(item);
        }

        public void RemoveAllItems()
        {
            foreach (var item in items)
                item.SetParentControl(null);

            items.Clear();
        }

        public PointF ScreenToWorld (Point screen)
        {
            PointF point = new PointF();
            float zf = (float)Zoom / 100F;

            point.X = (float)screen.X / zf - Scroll.X;
            point.Y = (float)screen.Y / zf - Scroll.Y;

            return point;
        }

        public Point WorldToScreen(PointF point)
        {
            Point screen = new Point(0, 0);
            float zf = (float)Zoom / 100F;

            float x = (point.X + Scroll.X) * zf;
            float y = (point.Y + Scroll.Y) * zf;

            screen.X = (int)x;
            screen.Y = (int)y;

            return screen;
        }

        private void ReallocateGraphics()
        {
            context = BufferedGraphicsManager.Current;
            context.MaximumBuffer = new Size(Width + 1, Height + 1);

            gfx = context.Allocate(CreateGraphics(),
                 new Rectangle(0, 0, Width, Height));
        }

        private void DrawGrid (Graphics gr)
        {
            float x, y;

            if (Zoom <= 50)
                return;

#pragma warning disable IDE0068 // Use recommended dispose pattern
            var gridBrush = new SolidBrush(GridColor);
#pragma warning restore IDE0068 // Use recommended dispose pattern

            PointF topLeft = ScreenToWorld(new Point(0, 0));
            PointF bottomRight = ScreenToWorld(new Point(Width, Height));

            for (y = 0; y < bottomRight.Y; y += GridSize)
            {
                for (x = 0; x < bottomRight.X; x += GridSize)
                {
                    Point screen = WorldToScreen(new PointF(x, y));
                    gr.FillRectangle(gridBrush, screen.X, screen.Y, 1, 1);
                }
            }

            for (y = 0; y >= topLeft.Y; y -= GridSize)
            {
                for (x = 0; x < bottomRight.X; x += GridSize)
                {
                    Point screen = WorldToScreen(new PointF(x, y));
                    gr.FillRectangle(gridBrush, screen.X, screen.Y, 1, 1);
                }
            }

            for (y = 0; y >= topLeft.Y; y -= GridSize)
            {
                for (x = 0; x >= topLeft.X; x -= GridSize)
                {
                    Point screen = WorldToScreen(new PointF(x, y));
                    gr.FillRectangle(gridBrush, screen.X, screen.Y, 1, 1);
                }
            }

            for (y = 0; y < bottomRight.Y; y += GridSize)
            {
                for (x = 0; x >= topLeft.X; x -= GridSize)
                {
                    Point screen = WorldToScreen(new PointF(x, y));
                    gr.FillRectangle(gridBrush, screen.X, screen.Y, 1, 1);
                }
            }
        }

        private void DrawOrigin(Graphics gr)
        {
            float zf = (float)Zoom / 100.0F;
            Point point = WorldToScreen(new Point(0, 0));

            int centerX = point.X;
            int centerY = point.Y;
            int radius = (int)((float)3 * zf);

            gr.FillEllipse(new SolidBrush(OriginColor),
                            centerX - radius, centerY - radius,
                            radius + radius, radius + radius);
        }

        private void DrawScene(Graphics gr)
        {
            Region region = new Region(new Rectangle(0, 0, Width, Height));
            gr.FillRegion(new SolidBrush(BackColor), region);

            if (ShowGrid)
                DrawGrid(gr);

            if (ShowOrigin)
                DrawOrigin(gr);

            foreach (var item in items)
            {
                if (item.Visible)
                {
                    item.Draw(gr);
                    item.DrawText(gr);
                }
            }
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            if (gfx == null)
                ReallocateGraphics();

            DrawScene(gfx.Graphics);

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

        public List<CanvasItem> GetSelected()
        {
            List<CanvasItem> selected = new List<CanvasItem>();

            foreach (var item in items)
            {
                if (item.Selected)
                    selected.Add(item);
            }

            return selected;
        }

        public void UnselectAll ()
        {
            foreach (var item in items)
                item.Unselect();
        }

        public CanvasItem HitTest (PointF point)
        {
            foreach (var item in items)
            {
                if (item.Visible && item.HitTest(point))
                    return item;
            }

            return null;
        }

        public List<CanvasItem> BoxTest(RectangleF rect)
        {
            List<CanvasItem> list = new List<CanvasItem>();

            foreach (var item in items)
            {
                if (item.Visible && item.BoxTest(rect))
                    list.Add(item);
            }

            return list;
        }

        public Keys GetModifierKeys()
        {
            return ModifierKeys;
        }

    }
}
