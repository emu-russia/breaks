using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Drawing.Printing;

namespace GraphLib
{
    public partial class PrintPreviewForm : Form
    {
        private PrintDocument printDoc = new PrintDocument();
        private PlotterGraphPaneEx gpane = null;
        private String strDefaultPrinter = String.Empty;
      
        private bool bBestScale = false;
        private bool bPageScale = false;
        private bool bUnscaled = false;
        private bool bLandscape = false;
        private int selPrinterIndex = -1;

        public PrintPreviewForm()
        {
            InitializeComponent();
            
            printPreviewCtrl.Zoom = 1;
            rb_BestFit.Checked = true;
            rb_Scale.Checked = false;
            rb_Unscaled.Checked = false;
            cb_Orientation.SelectedIndex = 0;
            printDoc.PrintPage += new PrintPageEventHandler(printDoc_PrintPage);
            this.VisibleChanged += new EventHandler(OnVisibleChanged);
            FormClosing += new FormClosingEventHandler(OnFormClosing);
        }

        void FillInInstalledPrinters()
        {
            strDefaultPrinter = printDoc.PrinterSettings.PrinterName;
            cb_Printer.Items.Clear();       
            foreach (String strPrinter in PrinterSettings.InstalledPrinters)
            {
                cb_Printer.Items.Add(strPrinter);

                if (strPrinter == strDefaultPrinter)
                {                   
                    cb_Printer.SelectedIndex = cb_Printer.Items.IndexOf(strPrinter);
                }
            }             
        }

        void OnVisibleChanged(object sender, EventArgs e)
        {
            if (this.Visible)
            {
                bLandscape = cb_Orientation.SelectedIndex == 1;

                FillInInstalledPrinters();

                FillInPaperSizes();

                UpdateScaleRadioButtons();
                 
                InvalidatePrintPreview();
            }
            else
            {
                
            }
        }

        void OnFormClosing(object sender, FormClosingEventArgs e)
        {
            this.Hide();
            e.Cancel = true;
        }
       
        void UpdateScaleRadioButtons()
        {
            bBestScale = rb_BestFit.Checked;
            bPageScale = rb_Scale.Checked;
            bUnscaled = rb_Unscaled.Checked;
        }

        double AutoZoomPreview()
        {
            float zoom = 1.0f;
            float step = 0.05f;

            float PaperWidth = printDoc.DefaultPageSettings.PaperSize.Width;
            float PaperHeight = printDoc.DefaultPageSettings.PaperSize.Height;
          
            if (bLandscape)
            {
                PaperHeight = printDoc.DefaultPageSettings.PaperSize.Width * zoom;
                PaperWidth = printDoc.DefaultPageSettings.PaperSize.Height * zoom;
            }

            while (zoom > 0.1f)
            {
                double CurW = PaperWidth * zoom;
                double CurH = PaperHeight * zoom;
                
                if (splitContainer1.Panel1.Width < (CurW+10) || splitContainer1.Panel1.Height < (CurH+10))
                {
                    zoom -= step;
                }
                else
                {
                    break;
                }
            }

            return zoom;
        }

        void FillInPaperSizes()
        {
            cb_PaperSize.Items.Clear();

            foreach (PaperSize s in printDoc.PrinterSettings.PaperSizes)
            {
                cb_PaperSize.Items.Add(s.PaperName.ToString());                
            }
             
            if (cb_PaperSize.SelectedIndex == -1 || cb_PaperSize.SelectedIndex >= cb_PaperSize.Items.Count)
            {                
                int idx = cb_PaperSize.Items.IndexOf(printDoc.DefaultPageSettings.PaperSize.PaperName); 
                
                if (idx >= 0 && idx < cb_PaperSize.Items.Count)
                {
                    cb_PaperSize.SelectedIndex = idx;
                }
                else
                {
                    cb_PaperSize.SelectedIndex = 0;
                }
            } 
        }

        void InvalidatePrintPreview()
        {
            printDoc.DefaultPageSettings.Landscape = bLandscape;            
            printPreviewCtrl.Document = printDoc;
            printPreviewCtrl.Document.DocumentName = "Preview";
            printPreviewCtrl.Zoom = AutoZoomPreview();
            printPreviewCtrl.InvalidatePreview();                  
        }

        
        public PlotterGraphPaneEx GraphPanel
        {
            set
            {
                gpane = value;                
            }
        }

        private void AutoScaleDocument(ref float w, ref float h, ref float x, ref float y)
        {           
            float CurGraphWidth = gpane.Width;
            float CurGraphHeight = gpane.Height;
            float CurPaperWidth = printDoc.DefaultPageSettings.PaperSize.Width;
            float CurPaperHeight = printDoc.DefaultPageSettings.PaperSize.Height;

            if (bLandscape)
            {
                CurPaperWidth = printDoc.DefaultPageSettings.PaperSize.Height;
                CurPaperHeight = printDoc.DefaultPageSettings.PaperSize.Width;
            }

            if (bUnscaled)
            {
                    // do nothing
            }

            if (bPageScale)         // scale to page
            {                
                CurGraphWidth = CurPaperWidth;
                CurGraphHeight = CurPaperHeight;                 
            }

            if (bBestScale)         // scale to best fit
            {
                float zoom = 1.0f;
                float step = 0.05f;

                if (CurGraphWidth > (CurPaperWidth ) || CurGraphHeight > (CurPaperHeight ))
                {
                    // scale down                   
                    while ((zoom * gpane.Width > CurPaperWidth || zoom * gpane.Height > CurPaperHeight) && zoom > step)
                    {                        
                        zoom -= step;
                    }
                    zoom -= step;
                    
                }
                else if (CurGraphWidth < CurPaperWidth && CurGraphHeight < CurPaperHeight)
                {
                    // scale up                   
                    while (((zoom+step) * gpane.Width < CurPaperWidth && (zoom+step) * gpane.Height < CurPaperHeight) && zoom > step)
                    {                        
                        zoom += step;
                    }                    
                   
                }
                CurGraphWidth = zoom * gpane.Width;
                CurGraphHeight = zoom * gpane.Height;
            }

            w = CurGraphWidth;
            h = CurGraphHeight;

            // center print
            x =   (CurPaperWidth - w) / 2.0f;
            y =   (CurPaperHeight - h) / 2.0f;
        }

        private void printDoc_PrintPage(object sender, PrintPageEventArgs e)
        {
            if (gpane != null)
            {
                float x=0, y=0, w=gpane.Width, h=gpane.Height;

                AutoScaleDocument(ref w, ref h, ref x, ref y);
                e.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
                //gpane.PaintControl(e.Graphics, w, h,x,y,cb_PrintBackground.Checked);
                gpane.PaintControl(e.Graphics, w, h, x, y, false);
            }
        }

        private void bt_print_Click(object sender, EventArgs e)
        {
            if (printDoc != null)
            {               
                printDoc.Print();
                this.Hide();
            }
        }

        private void bt_Cancel_Click(object sender, EventArgs e)
        {
            this.Hide();
        }

        private void cb_PaperSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (cb_PaperSize.SelectedIndex >= 0 && cb_PaperSize.SelectedIndex < cb_PaperSize.Items.Count)
            {
                
                foreach (PaperSize s in printDoc.PrinterSettings.PaperSizes)
                {
                    if (s.PaperName == (string)cb_PaperSize.Items[cb_PaperSize.SelectedIndex])
                    {
                        printDoc.DefaultPageSettings.PaperSize = s;
                        InvalidatePrintPreview();
                    }
                }
            }
        }

        
        private void rb_BestFit_CheckedChanged(object sender, EventArgs e)
        {
            if (rb_BestFit.Checked)
            {
                rb_Scale.Checked = !rb_BestFit.Checked;
                rb_Unscaled.Checked = !rb_BestFit.Checked;
            }

            UpdateScaleRadioButtons();
            InvalidatePrintPreview();
        }

        private void rb_Scale_CheckedChanged(object sender, EventArgs e)
        {
            if (rb_Scale.Checked)
            {
                rb_BestFit.Checked = !rb_Scale.Checked;
                rb_Unscaled.Checked = !rb_Scale.Checked;
            }

            UpdateScaleRadioButtons();
            InvalidatePrintPreview();
        }

        private void rb_Unscaled_CheckedChanged(object sender, EventArgs e)
        {
            if (rb_Unscaled.Checked)
            {
                rb_Scale.Checked = !rb_Unscaled.Checked;
                rb_BestFit.Checked = !rb_Unscaled.Checked;
            }

            UpdateScaleRadioButtons();
            InvalidatePrintPreview();
        }

        private void cb_Printer_SelectedIndexChanged(object sender, EventArgs e)
        {
            selPrinterIndex = cb_Printer.SelectedIndex;

            if (selPrinterIndex >= 0 && selPrinterIndex < cb_Printer.Items.Count)
            {
                printDoc.PrinterSettings.PrinterName = (string)cb_Printer.Items[selPrinterIndex];
                this.Text = "Print Preview - " + printDoc.PrinterSettings.PrinterName;
            }   

            FillInPaperSizes();

            InvalidatePrintPreview();
        }

        private void cb_Orientation_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (cb_Orientation.SelectedIndex == 0)
            {
                bLandscape = false;
            }
            else
            {
                bLandscape = true;
            }

            InvalidatePrintPreview();
        }

        private void cb_PrintBackground_CheckedChanged(object sender, EventArgs e)
        {
            InvalidatePrintPreview();
        }

        
    }
}