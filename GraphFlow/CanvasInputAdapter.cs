/// Вспомогательный код для взаимодействия пользователя и контрола Canvas

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Drawing;

using CanvasControl;

namespace GraphFlow
{
    public class CanvasInputAdapter
    {
        private CanvasControl.CanvasControl canvas;
        
        private bool scrollingBegin = false;
        private PointF savedScroll;
        private Point savedMouse;

        private bool selectionBegin = false;
        private CanvasPolyLine selectionBox;

        private bool draggingBegin = false;
        private List<CanvasItem> selectedDragItems = new List<CanvasItem>();

        public CanvasInputAdapter (CanvasControl.CanvasControl control)
        {
            canvas = control;

            canvas.MouseDown += Canvas_MouseDown;
            canvas.MouseUp += Canvas_MouseUp;
            canvas.MouseMove += Canvas_MouseMove;
            canvas.MouseWheel += Canvas_MouseWheel;

            canvas.KeyUp += Canvas_KeyUp;
        }

        private void Canvas_MouseDown(object sender, MouseEventArgs e)
        {
            if ( e.Button == MouseButtons.Left && !selectionBegin)
            {
                PointF pos = canvas.ScreenToWorld(new Point(e.X, e.Y));

                CanvasItem item = canvas.HitTest(pos);

                if (item != null)
                {
                    // Нажали внутри итема

                    // Циклические меняем значение ассоциированного с итемом узла графа

                    if ( item.UserData != null)
                    {
                        if ( item.UserData is GraphFlow.Node )
                        {
                            Node node = item.UserData as GraphFlow.Node;

                            if (node.Value != null)
                            {
                                if (node.Value == 0)
                                {
                                    node.Value = 1;
                                }
                                else
                                {
                                    node.Value = null;
                                }
                            }
                            else
                            {
                                node.Value = 0;
                            }

                            canvas.Invalidate();
                        }
                    }

                }
                else
                {
                    // Рамка выделения

                    List<PointF> points = new List<PointF>();

                    points.Add(pos);
                    points.Add(pos);
                    points.Add(pos);
                    points.Add(pos);
                    points.Add(pos);

                    selectionBox = new CanvasPolyLine(points);

                    selectionBox.FrontColor = Color.Black;

                    canvas.AddItem(selectionBox);

                    selectionBegin = true;
                }
            }

            else if ( e.Button == MouseButtons.Right && !scrollingBegin)
            {
                savedScroll = new PointF(canvas.Scroll.X, canvas.Scroll.Y);
                savedMouse = new Point(e.X, e.Y);

                canvas.Cursor = Cursors.SizeAll;

                scrollingBegin = true;
            }
        }

        private void Canvas_MouseUp(object sender, MouseEventArgs e)
        {
            canvas.Focus();

            if (e.Button == MouseButtons.Left && selectionBegin)
            {
                canvas.UnselectAll();

                PointF selectionStart = selectionBox.Points[0];
                PointF selectionEnd = selectionBox.Points[2];

                PointF selectionOrigin = new PointF();
                SizeF selectionSize = new SizeF();

                selectionSize.Width = Math.Abs(selectionEnd.X - selectionStart.X);
                selectionSize.Height = Math.Abs(selectionEnd.Y - selectionStart.Y);

                if (selectionEnd.X > selectionStart.X)
                {
                    if (selectionEnd.Y > selectionStart.Y)
                    {
                        selectionOrigin.X = selectionStart.X;
                        selectionOrigin.Y = selectionStart.Y;
                    }
                    else
                    {
                        selectionOrigin.X = selectionStart.X;
                        selectionOrigin.Y = selectionEnd.Y;
                    }
                }
                else
                {
                    if (selectionEnd.Y > selectionStart.Y)
                    {
                        selectionOrigin.X = selectionEnd.X;
                        selectionOrigin.Y = selectionStart.Y;
                    }
                    else
                    {
                        selectionOrigin.X = selectionEnd.X;
                        selectionOrigin.Y = selectionEnd.Y;
                    }
                }

                RectangleF rect = new RectangleF(selectionOrigin.X,
                                                  selectionOrigin.Y,
                                                  selectionSize.Width,
                                                  selectionSize.Height);

                float square = selectionSize.Width * selectionSize.Height;

                if (square >= 4.0F)
                {
                    List<CanvasItem> items = canvas.BoxTest(rect);

                    if (items.Count != 0)
                    {
                        foreach (var item in items)
                            item.Select();

                        canvas.Invalidate();
                    }
                }

                canvas.RemoveItem(selectionBox);
                selectionBox = null;

                selectionBegin = false;
                canvas.Invalidate();
            }

            else if (e.Button == MouseButtons.Left && draggingBegin )
            {
                draggingBegin = false;
                canvas.Cursor = Cursors.Default;
            }

            else if (e.Button == MouseButtons.Right && scrollingBegin)
            {
                scrollingBegin = false;
                canvas.Cursor = Cursors.Default;
            }
        }

        private void Canvas_MouseMove(object sender, MouseEventArgs e)
        {
            if (selectionBegin)
            {
                PointF mouse = canvas.ScreenToWorld(new Point(e.X, e.Y));
                PointF origin = selectionBox.Points[0];

                selectionBox.Points[1] = new PointF(mouse.X, origin.Y);
                selectionBox.Points[2] = new PointF(mouse.X, mouse.Y);
                selectionBox.Points[3] = new PointF(origin.X, mouse.Y);

                canvas.Invalidate();
            }

            else if (scrollingBegin)
            {
                Point screenCoord = canvas.WorldToScreen(savedScroll);

                PointF worldCoord = canvas.ScreenToWorld(
                    new Point(
                        screenCoord.X + e.X - savedMouse.X,
                        screenCoord.Y + e.Y - savedMouse.Y));

                canvas.Scroll.X = worldCoord.X;
                canvas.Scroll.Y = worldCoord.Y;
                canvas.Invalidate();
            }

            else if (draggingBegin)
            {
                foreach(var item in selectedDragItems)
                {
                    Point screenPos = canvas.WorldToScreen(item.SavedPos);
                    screenPos.X += e.X - savedMouse.X;
                    screenPos.Y += e.Y - savedMouse.Y;
                    item.Pos = canvas.ScreenToWorld(screenPos);

                    Point screenPosEnd = canvas.WorldToScreen(item.SavedPosEnd);
                    screenPosEnd.X += e.X - savedMouse.X;
                    screenPosEnd.Y += e.Y - savedMouse.Y;
                    item.PosEnd = canvas.ScreenToWorld(screenPosEnd);

                    for (int i = 0; i < item.Points.Count; i++)
                    {
                        Point screenPoint = canvas.WorldToScreen(item.SavedPoints[i]);
                        screenPoint.X += e.X - savedMouse.X;
                        screenPoint.Y += e.Y - savedMouse.Y;
                        item.Points[i] = canvas.ScreenToWorld(screenPoint);
                    }
                }

                canvas.Invalidate();
            }

            else
            {
                PointF mouse = canvas.ScreenToWorld(new Point(e.X, e.Y));

                var item = canvas.HitTest(mouse);

                if (item != null)
                {
                    if (item.Selected)
                    {
                        canvas.Cursor = Cursors.SizeAll;
                        return;
                    }
                }

                canvas.Cursor = Cursors.Default;
            }
        }

        private void Canvas_MouseWheel(object sender, MouseEventArgs e)
        {
            int delta;

            if (e.Delta > 0)
                delta = +10;
            else
                delta = -10;

            PointF oldMouse = canvas.ScreenToWorld(new Point(e.X, e.Y));

            canvas.Zoom += delta;

            PointF mousePos = canvas.ScreenToWorld(new Point(e.X, e.Y));

            canvas.Scroll.X += (mousePos.X - oldMouse.X);
            canvas.Scroll.Y += (mousePos.Y - oldMouse.Y);

            canvas.Invalidate();
        }

        private void Canvas_KeyUp(object sender, KeyEventArgs e)
        {
            switch (e.KeyCode)
            {
                case Keys.Left:
                    canvas.Scroll.X += 10F;
                    canvas.Invalidate();
                    break;
                case Keys.Right:
                    canvas.Scroll.X -= 10F;
                    canvas.Invalidate();
                    break;
                case Keys.Up:
                    canvas.Scroll.Y += 10F;
                    canvas.Invalidate();
                    break;
                case Keys.Down:
                    canvas.Scroll.Y -= 10F;
                    canvas.Invalidate();
                    break;
            }
        }

    }
}
