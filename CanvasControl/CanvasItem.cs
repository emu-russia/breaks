/// Базовый класс, определяющий элемент изображения
/// Вся сцена строится из элементов

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Drawing;

namespace CanvasControl
{
    public class CanvasItem
    {
        /// <summary>
        /// Топология (все координаты являются мировыми координатами)
        /// </summary>

        public PointF Pos { get; set; } = new PointF();
        public PointF PosEnd { get; set; } = new PointF();
        public List<PointF> Points { get; set; } = new List<PointF>();

        /// <summary>
        /// Метрика
        /// </summary>

        public float Width { get; set; } = 0;
        public float Height { get; set; } = 0;

        /// <summary>
        /// Стиль
        /// </summary>

        public Color FrontColor { get; set; } = new Color();
        public Color BorderColor { get; set; } = Color.Black;
        public bool RoundedEdges { get; set; } = false;
        public int BorderWidth { get; set; } = 1;
        public bool Visible { get; set; } = true;
        public bool Selected { get; set; } = false;
        public string Text { get; set; } = "";
        public Color TextColor { get; set; } = Color.Black;

        public object UserData = null;
        protected CanvasControl parentControl = null;

        public PointF SavedPos = new PointF();
        public PointF SavedPosEnd = new PointF();
        public List<PointF> SavedPoints = new List<PointF>();
        public virtual void Draw(Graphics gr)
        {
        }

        public void Select()
        {
            Selected = true;
        }

        public void Unselect()
        {
            Selected = false;
        }

        public void Show(bool show)
        {
            Visible = show;
        }

        public void SetParentControl(CanvasControl parent)
        {
            parentControl = parent;
        }

        public virtual bool HitTest (PointF point)
        {
            return false;
        }

        public virtual bool BoxTest(RectangleF rect)
        {
            return false;
        }

        public virtual void DrawText(Graphics gr)
        {
            Point topLeft = parentControl.WorldToScreen(Pos);

            SizeF textSize = gr.MeasureString(Text, parentControl.Font);

            float zf = (float)parentControl.Zoom / 100.0F;

            gr.DrawString(Text, parentControl.Font, new SolidBrush(TextColor), topLeft.X, topLeft.Y);
        }

        public CanvasItem Clone()
        {
            CanvasItem item = CreateInstanceForClone();

            item.Pos = new PointF(Pos.X, Pos.Y);
            item.PosEnd = new PointF(PosEnd.X, PosEnd.Y);
            
            item.Points = new List<PointF>();
            foreach (var p in Points)
            {
                item.Points.Add(new PointF(p.X, p.Y));
            }

            item.Width = Width;
            item.Height = Height;

            item.FrontColor = new Color();
            item.FrontColor = FrontColor;
            item.BorderColor = new Color();
            item.BorderColor = BorderColor;
            item.RoundedEdges = RoundedEdges;
            item.BorderWidth = BorderWidth;
            item.Visible = Visible;
            item.Selected = Selected;
            item.Text = Text;
            item.TextColor = new Color();
            item.TextColor = TextColor;

            item.parentControl = parentControl;

            return item;
        }

        public virtual CanvasItem CreateInstanceForClone()
        {
            return new CanvasItem();
        }

    }
}
