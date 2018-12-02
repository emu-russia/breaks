// Форма для отображения и ручного управления контактами PPU

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using GraphLib;

namespace PpuTestSuite
{
    public partial class FormPads : Form
    {
        private Ppu ppu;
        private Image savedImage;

        // Карта соответствия вывода и прямоугольной области на картинке

        private Dictionary<string,Rectangle> padmap = new Dictionary<string, Rectangle>();

        // Карта соответствия вывода и контрола

        private Dictionary<string, TextBox> textBoxMap = new Dictionary<string, TextBox>();

        public FormPads(Ppu ppu)
        {
            InitializeComponent();

            this.ppu = ppu;

            ppu.AddListener(PpuListener);
        }

        private void FormPads_Load(object sender, EventArgs e)
        {
            savedImage = pictureBox1.Image;

            VideoOutInit();

            InitPadMap();

            InitTextBoxMap();
        }

        ~FormPads()
        {
            ppu.RemoveListener(PpuListener);
        }

        // Заполнить карту выводов
        private void InitPadMap ()
        {
            // Левая сторона
            padmap["R/W"] = new Rectangle(40, 42, 43, 17);
            padmap["D0"] = new Rectangle(41, 73, 43, 17);
            padmap["D1"] = new Rectangle(39, 100, 43, 17);
            padmap["D2"] = new Rectangle(38, 128, 43, 17);
            padmap["D3"] = new Rectangle(41, 162, 43, 17);
            padmap["D4"] = new Rectangle(40, 197, 43, 17);
            padmap["D5"] = new Rectangle(38, 221, 43, 17);
            padmap["D6"] = new Rectangle(38, 250, 43, 17);
            padmap["D7"] = new Rectangle(39, 280, 43, 17);

            padmap["RS2"] = new Rectangle(37, 311, 43, 17);
            padmap["RS1"] = new Rectangle(38, 340, 43, 17);
            padmap["RS0"] = new Rectangle(38, 371, 43, 17);

            padmap["/DBE"] = new Rectangle(38, 400, 43, 17);

            padmap["EXT0"] = new Rectangle(38, 431, 43, 17);
            padmap["EXT1"] = new Rectangle(38, 460, 43, 17);
            padmap["EXT2"] = new Rectangle(37, 490, 43, 17);
            padmap["EXT3"] = new Rectangle(38, 519, 43, 17);

            padmap["CLK"] = new Rectangle(38, 547, 43, 17);
            padmap["/INT"] = new Rectangle(38, 577, 43, 17);

            // Правая сторона
            padmap["ALE"] = new Rectangle(164, 74, 43, 17);

            padmap["AD0"] = new Rectangle(164, 101, 43, 17);
            padmap["AD1"] = new Rectangle(166, 131, 43, 17);
            padmap["AD2"] = new Rectangle(168, 161, 43, 17);
            padmap["AD3"] = new Rectangle(166, 195, 43, 17);
            padmap["AD4"] = new Rectangle(165, 223, 43, 17);
            padmap["AD5"] = new Rectangle(164, 250, 43, 17);
            padmap["AD6"] = new Rectangle(165, 282, 43, 17);
            padmap["AD7"] = new Rectangle(166, 312, 43, 17);

            padmap["A8"] = new Rectangle(164, 340, 43, 17);
            padmap["A9"] = new Rectangle(165, 370, 43, 17);
            padmap["A10"] = new Rectangle(165, 400, 43, 17);
            padmap["A11"] = new Rectangle(165, 430, 43, 17);
            padmap["A12"] = new Rectangle(163, 459, 43, 17);
            padmap["A13"] = new Rectangle(162, 488, 43, 17);

            padmap["/RD"] = new Rectangle(164, 517, 43, 17);
            padmap["/WR"] = new Rectangle(164, 549, 43, 17);
            padmap["/RES"] = new Rectangle(162, 578, 43, 17);
        }

        private void InitTextBoxMap ()
        {
            // Левая сторона
            textBoxMap["R/W"] = textBoxRnW;

            textBoxMap["D0"] = textBoxD0;
            textBoxMap["D1"] = textBoxD1;
            textBoxMap["D2"] = textBoxD2;
            textBoxMap["D3"] = textBoxD3;
            textBoxMap["D4"] = textBoxD4;
            textBoxMap["D5"] = textBoxD5;
            textBoxMap["D6"] = textBoxD6;
            textBoxMap["D7"] = textBoxD7;

            textBoxMap["RS2"] = textBoxRS2;
            textBoxMap["RS1"] = textBoxRS1;
            textBoxMap["RS0"] = textBoxRS0;

            textBoxMap["/DBE"] = textBoxnDBE;

            textBoxMap["EXT0"] = textBoxEXT0;
            textBoxMap["EXT1"] = textBoxEXT1;
            textBoxMap["EXT2"] = textBoxEXT2;
            textBoxMap["EXT3"] = textBoxEXT3;

            textBoxMap["CLK"] = textBoxCLK;
            textBoxMap["/INT"] = textBoxnINT;

            // Правая сторона
            textBoxMap["ALE"] = textBoxALE;

            textBoxMap["AD0"] = textBoxAD0;
            textBoxMap["AD1"] = textBoxAD1;
            textBoxMap["AD2"] = textBoxAD2;
            textBoxMap["AD3"] = textBoxAD3;
            textBoxMap["AD4"] = textBoxAD4;
            textBoxMap["AD5"] = textBoxAD5;
            textBoxMap["AD6"] = textBoxAD6;
            textBoxMap["AD7"] = textBoxAD7;

            textBoxMap["A8"] = textBoxA8;
            textBoxMap["A9"] = textBoxA9;
            textBoxMap["A10"] = textBoxA10;
            textBoxMap["A11"] = textBoxA11;
            textBoxMap["A12"] = textBoxA12;
            textBoxMap["A13"] = textBoxA13;

            textBoxMap["/RD"] = textBoxnRD;
            textBoxMap["/WR"] = textBoxnWR;
            textBoxMap["/RES"] = textBoxnRES;
        }

        private void VideoOutInit()
        {
            plotterVideoOut.DataSources.Clear();
            plotterVideoOut.SetDisplayRangeX(0, 400);

            plotterVideoOut.DataSources.Add(new DataSource());
            plotterVideoOut.DataSources[0].Name = "NTSC Video";
            plotterVideoOut.DataSources[0].OnRenderXAxisLabel += RenderXLabel;

            plotterVideoOut.DataSources[0].Length = 5800;
            plotterVideoOut.PanelLayout = PlotterGraphPaneEx.LayoutMode.NORMAL;
            plotterVideoOut.DataSources[0].AutoScaleY = false;
            plotterVideoOut.DataSources[0].SetDisplayRangeY(-300, 300);
            plotterVideoOut.DataSources[0].SetGridDistanceY(100);
            plotterVideoOut.DataSources[0].OnRenderYAxisLabel = RenderYLabel;
            CalcSinusFunction_2(plotterVideoOut.DataSources[0], 0);

            ResumeLayout();
            plotterVideoOut.Refresh();
        }

        private string RenderXLabel(DataSource s, int idx)
        {
            if (s.AutoScaleX)
            {
                //if (idx % 2 == 0)
                {
                    int Value = (int)(s.Samples[idx].x);
                    return "" + Value;
                }
                return "";
            }
            else
            {
                int Value = (int)(s.Samples[idx].x / 200);
                return "" + Value + "\"";
            }
        }

        private string RenderYLabel(DataSource s, float value)
        {
            return string.Format("{0:0.0}", value);
        }

        protected void CalcSinusFunction_2(DataSource src, int idx)
        {
            for (int i = 0; i < src.Length; i++)
            {
                src.Samples[i].x = i;

                src.Samples[i].y = (float)(((float)20 *
                                            Math.Sin(40 * (idx + 1) * (i + 1) * Math.PI / src.Length)) *
                                            Math.Sin(160 * (idx + 1) * (i + 1) * Math.PI / src.Length)) +
                                            (float)(((float)200 *
                                            Math.Sin(4 * (idx + 1) * (i + 1) * Math.PI / src.Length)));
            }
            src.OnRenderYAxisLabel = RenderYLabel;
        }

        /// <summary>
        /// Взывается при изменении внутреннего состояния PPU
        /// </summary>
        /// <param name="sender"></param>
        private void PpuListener(object sender)
        {
            UpdateControls();
        }

        private void UpdateControls()
        {
            foreach (var kvp in textBoxMap)
            {
                kvp.Value.Text = ppu.GetPad(kvp.Key).ToString();
            }

            UpdateImages();
        }

        private void UpdateImages()
        {
            List<Rectangle> rects = new List<Rectangle>();
            List<Color> colors = new List<Color>();

            Color colorRed = Color.FromArgb(127, 255, 0, 0);
            Color colorGreen = Color.FromArgb(127, 0, 255, 0);

            foreach (var kvp in padmap)
            {
                rects.Add(kvp.Value);
                colors.Add(ppu.GetPad(kvp.Key) != 0 ? colorRed : colorGreen );
            }

            pictureBox1.Image =  ImageHelper.HighlightRect(savedImage, rects.ToArray(), colors.ToArray());
        }

        private void FormPads_KeyDown(object sender, KeyEventArgs e)
        {
            if ( e.KeyCode == Keys.Escape)
            {
                Close();
            }
        }

        #region Переключатели контактов

        private void button2_Click(object sender, EventArgs e)
        {
            ppu.Pads.RnW = Base.Toggle((int)ppu.Pads.RnW);
            ppu.NotifyListeners();
        }

        private void button3_Click(object sender, EventArgs e)
        {
            ppu.Pads.D[0] = Base.Toggle((int)ppu.Pads.D[0]);
            ppu.NotifyListeners();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            ppu.Pads.D[1] = Base.Toggle((int)ppu.Pads.D[1]);
            ppu.NotifyListeners();
        }

        private void button5_Click(object sender, EventArgs e)
        {
            ppu.Pads.D[2] = Base.Toggle((int)ppu.Pads.D[2]);
            ppu.NotifyListeners();
        }

        private void button6_Click(object sender, EventArgs e)
        {
            ppu.Pads.D[3] = Base.Toggle((int)ppu.Pads.D[3]);
            ppu.NotifyListeners();
        }

        private void button7_Click(object sender, EventArgs e)
        {
            ppu.Pads.D[4] = Base.Toggle((int)ppu.Pads.D[4]);
            ppu.NotifyListeners();
        }

        private void button8_Click(object sender, EventArgs e)
        {
            ppu.Pads.D[5] = Base.Toggle((int)ppu.Pads.D[5]);
            ppu.NotifyListeners();
        }

        private void button9_Click(object sender, EventArgs e)
        {
            ppu.Pads.D[6] = Base.Toggle((int)ppu.Pads.D[6]);
            ppu.NotifyListeners();
        }

        private void button10_Click(object sender, EventArgs e)
        {
            ppu.Pads.D[7] = Base.Toggle((int)ppu.Pads.D[7]);
            ppu.NotifyListeners();
        }

        private void button11_Click(object sender, EventArgs e)
        {
            ppu.Pads.RS[0] = Base.Toggle((int)ppu.Pads.RS[0]);
            ppu.NotifyListeners();
        }

        private void button12_Click(object sender, EventArgs e)
        {
            ppu.Pads.RS[1] = Base.Toggle((int)ppu.Pads.RS[1]);
            ppu.NotifyListeners();
        }

        private void button13_Click(object sender, EventArgs e)
        {
            ppu.Pads.RS[2] = Base.Toggle((int)ppu.Pads.RS[2]);
            ppu.NotifyListeners();
        }

        private void button14_Click(object sender, EventArgs e)
        {
            ppu.Pads.nDBE = Base.Toggle((int)ppu.Pads.nDBE);
            ppu.NotifyListeners();
        }

        private void button15_Click(object sender, EventArgs e)
        {
            ppu.Pads.EXT[0] = Base.Toggle((int)ppu.Pads.EXT[0]);
            ppu.NotifyListeners();
        }

        private void button16_Click(object sender, EventArgs e)
        {
            ppu.Pads.EXT[1] = Base.Toggle((int)ppu.Pads.EXT[1]);
            ppu.NotifyListeners();
        }

        private void button17_Click(object sender, EventArgs e)
        {
            ppu.Pads.EXT[2] = Base.Toggle((int)ppu.Pads.EXT[2]);
            ppu.NotifyListeners();
        }

        private void button18_Click(object sender, EventArgs e)
        {
            ppu.Pads.EXT[3] = Base.Toggle((int)ppu.Pads.EXT[3]);
            ppu.NotifyListeners();
        }

        private void button19_Click(object sender, EventArgs e)
        {
            ppu.ToggleClock();
            ppu.NotifyListeners();
        }

        private void button20_Click(object sender, EventArgs e)
        {
            ppu.Pads.nINT = Base.Toggle((int)ppu.Pads.nINT);
            ppu.NotifyListeners();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            ppu.Pads.ALE = Base.Toggle((int)ppu.Pads.ALE);
            ppu.NotifyListeners();
        }

        private void button21_Click(object sender, EventArgs e)
        {
            ppu.Pads.AD[0] = Base.Toggle((int)ppu.Pads.AD[0]);
            ppu.NotifyListeners();
        }

        private void button22_Click(object sender, EventArgs e)
        {
            ppu.Pads.AD[1] = Base.Toggle((int)ppu.Pads.AD[1]);
            ppu.NotifyListeners();
        }

        private void button24_Click(object sender, EventArgs e)
        {
            ppu.Pads.AD[2] = Base.Toggle((int)ppu.Pads.AD[2]);
            ppu.NotifyListeners();
        }

        private void button23_Click(object sender, EventArgs e)
        {
            ppu.Pads.AD[3] = Base.Toggle((int)ppu.Pads.AD[3]);
            ppu.NotifyListeners();
        }

        private void button26_Click(object sender, EventArgs e)
        {
            ppu.Pads.AD[4] = Base.Toggle((int)ppu.Pads.AD[4]);
            ppu.NotifyListeners();
        }

        private void button25_Click(object sender, EventArgs e)
        {
            ppu.Pads.AD[5] = Base.Toggle((int)ppu.Pads.AD[5]);
            ppu.NotifyListeners();
        }

        private void button28_Click(object sender, EventArgs e)
        {
            ppu.Pads.AD[6] = Base.Toggle((int)ppu.Pads.AD[6]);
            ppu.NotifyListeners();
        }

        private void button27_Click(object sender, EventArgs e)
        {
            ppu.Pads.AD[7] = Base.Toggle((int)ppu.Pads.AD[7]);
            ppu.NotifyListeners();
        }

        private void button29_Click(object sender, EventArgs e)
        {
            ppu.Pads.A[8] = Base.Toggle((int)ppu.Pads.A[8]);
            ppu.NotifyListeners();
        }

        private void button30_Click(object sender, EventArgs e)
        {
            ppu.Pads.A[9] = Base.Toggle((int)ppu.Pads.A[9]);
            ppu.NotifyListeners();
        }

        private void button32_Click(object sender, EventArgs e)
        {
            ppu.Pads.A[10] = Base.Toggle((int)ppu.Pads.A[10]);
            ppu.NotifyListeners();
        }

        private void button31_Click(object sender, EventArgs e)
        {
            ppu.Pads.A[11] = Base.Toggle((int)ppu.Pads.A[11]);
            ppu.NotifyListeners();
        }

        private void button34_Click(object sender, EventArgs e)
        {
            ppu.Pads.A[12] = Base.Toggle((int)ppu.Pads.A[12]);
            ppu.NotifyListeners();
        }

        private void button33_Click(object sender, EventArgs e)
        {
            ppu.Pads.A[13] = Base.Toggle((int)ppu.Pads.A[13]);
            ppu.NotifyListeners();
        }

        private void button35_Click(object sender, EventArgs e)
        {
            ppu.Pads.nRD = Base.Toggle((int)ppu.Pads.nRD);
            ppu.NotifyListeners();
        }

        private void button36_Click(object sender, EventArgs e)
        {
            ppu.Pads.nWR = Base.Toggle((int)ppu.Pads.nWR);
            ppu.NotifyListeners();
        }

        private void button37_Click(object sender, EventArgs e)
        {
            ppu.Pads.nRES = Base.Toggle((int)ppu.Pads.nRES);

            ppu.ResetPadLogic();

            ppu.NotifyListeners();
        }

        #endregion
    }
}
