// 2C02 Ppu Model
//
// Пишу в промежутках между работой чтобы не зачахнуть.
// Комментарии смешанные, но скорее всего перейду полностью на русский

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

public class Ppu
{

    /// <summary>
    /// В клоке ничего интересного, просто дергается соотв. лапка
    /// </summary>

    #region CLK

    public int CLKin = 0;               // Pad
    public int CLKout;      // Inner CLK to pixel clock and phase shifter
    public int NotCLKout;       // Inner CLK# to pixel clock and phase shifter

    public long ToggleCounter = 0;

    public void ToggleClock ()
    {
        CLKin = Base.Toggle(CLKin);
        CLKout = CLKin;
        NotCLKout = Base.Not(CLKin);

        ToggleCounter++;
    }

    #endregion

    #region Reset

    public int nRES = 0;        // External Pad
    public int RES;         // internal reset
    public int RC;      // Internal register clear
    public int RESCL = 0;       // Internal Reset FF clear

    public int ResetFF = 0;     // Reset FF value


    /// <summary>
    /// После прихода внешнего сигнала /RES = 0 защелка устанавливается, чтобы "не потерять" сигнал сброса.
    /// Защелка остается установленной до тех пор, пока не будет очищена RESCL = 1
    /// 
    /// Выходное значение защелки подается на схему очистки регистров (сигнал RC - Register Clear)
    /// 
    /// При включении питания защелка Reset FF принимает значение 0
    /// </summary>

    public void ResetPadLogic ()
    {
        RES = Base.Not(nRES);

        ResetFF = Base.Nor(RESCL, Base.Nor(RES, ResetFF));

        RC = ResetFF;
    }

    #endregion

    ///
    /// PCLK = CLK / 4
    /// 

    #region Pixel Clock

    #endregion


}
