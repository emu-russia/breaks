// 2C02 Ppu Model
//

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

/// <summary>
/// Контекст PPU хранится в "размазанном" виде между основными логическими блоками
/// Весь контекст доступен потребитялм (public)
/// Там где переменные устанавливаются явно в 0, это значит что при включении питания они соединены с землей.
/// Там где нет явных присваиваний, это значит что значение переменных не определено (x)
/// </summary>

public class Ppu
{

    /// <summary>
    /// Реактивные связи
    /// Внешние потребители могут инициировать процесс обновления друг друга, путем регистрации "слушателей" изменения контекста PPU
    /// </summary>

    #region "Реактивные связи"

    public delegate void PpuListener(object sender);

    private List<PpuListener> listeners = new List<PpuListener>();

    /// <summary>
    /// Добавить слушателя
    /// </summary>
    /// <param name="cb"></param>
    public void AddListener (PpuListener cb)
    {
        listeners.Add(cb);
    }

    /// <summary>
    /// Удалить слушателя
    /// </summary>
    /// <param name="cb"></param>
    public void RemoveListener (PpuListener cb)
    {
        listeners.Remove(cb);
    }

    /// <summary>
    /// Уведомить слушателей при изменении контекста
    /// Внутри Ppu этот метод никогда не должен вызываться, чтобы не было Race condition
    /// </summary>
    public void NotifyListeners ()
    {
        foreach ( PpuListener cb in listeners)
        {
            cb(this);
        }
    }

    #endregion "Реактивные связи"

    /// <summary>
    /// Контакты
    /// </summary>

    #region "Pads"

    public class PpuPads
    {
        public int? nDBE = Base.GetUndefined();     // Контакт /DBE (in)
        public int?[] RS = new int?[3] {
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined() };                  // Контакты RS0-RS2 (Register Select) (in)
        public int?[] D = new int?[8] {
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined() };                  // Контакты D0-D7 (in/out)
        public int? RnW = Base.GetUndefined();      // Контакт R/W (in)
        public int? ALE = Base.GetUndefined();      // Контакт ALE (out)
        public int?[] AD = new int?[8] {
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined() };                  // Контакты AD0-AD7 (in/out)
        public int?[] A = new int?[14] {
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),

            Base.GetUndefined(),                    // используются только начиная с 8
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            };                                      // Контакты A8-A13 (out)
        public int? nRD = Base.GetUndefined();      // Контакт /RD (out)
        public int? nWR = Base.GetUndefined();      // Контакт /WR (out)
        public int? nRES = Base.GetUndefined();     // Контакт /RES (in)
        public float VID;                           // Аналоговый сигнал VID (out)
        public int? nINT = Base.GetUndefined();     // Контакт /INT (out)
        public int? CLK = Base.GetUndefined();      // Контакт CLK (in)
        public int?[] EXT = new int?[4] {
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined(),
            Base.GetUndefined() };                  // Контакты EXT0-EXT3 (in/out)
    }

    public PpuPads Pads = new PpuPads();

    public int? GetPad(string name)
    {
        switch (name)
        {
            case "R/W": return Pads.RnW;
            case "D0": return Pads.D[0];
            case "D1": return Pads.D[1];
            case "D2": return Pads.D[2];
            case "D3": return Pads.D[3];
            case "D4": return Pads.D[4];
            case "D5": return Pads.D[5];
            case "D6": return Pads.D[6];
            case "D7": return Pads.D[7];
            case "RS0": return Pads.RS[0];
            case "RS1": return Pads.RS[1];
            case "RS2": return Pads.RS[2];
            case "/DBE": return Pads.nDBE;
            case "EXT0": return Pads.EXT[0];
            case "EXT1": return Pads.EXT[1];
            case "EXT2": return Pads.EXT[2];
            case "EXT3": return Pads.EXT[3];
            case "CLK": return Pads.CLK;
            case "/INT": return Pads.nINT;

            case "ALE": return Pads.ALE;
            case "AD0": return Pads.AD[0];
            case "AD1": return Pads.AD[1];
            case "AD2": return Pads.AD[2];
            case "AD3": return Pads.AD[3];
            case "AD4": return Pads.AD[4];
            case "AD5": return Pads.AD[5];
            case "AD6": return Pads.AD[6];
            case "AD7": return Pads.AD[7];
            case "A8": return Pads.A[8];
            case "A9": return Pads.A[9];
            case "A10": return Pads.A[10];
            case "A11": return Pads.A[11];
            case "A12": return Pads.A[12];
            case "A13": return Pads.A[13];
            case "/RD": return Pads.nRD;
            case "/WR": return Pads.nWR;
            case "/RES": return Pads.nRES;
        }

        throw new Exception("Unknown pad name");
    }

    public void SetPad(string name, int value)
    {
        switch (name)
        {
            case "R/W": Pads.RnW = value; break;
            case "D0": Pads.D[0] = value; break;
            case "D1": Pads.D[1] = value; break;
            case "D2": Pads.D[2] = value; break;
            case "D3": Pads.D[3] = value; break;
            case "D4": Pads.D[4] = value; break;
            case "D5": Pads.D[5] = value; break;
            case "D6": Pads.D[6] = value; break;
            case "D7": Pads.D[7] = value; break;
            case "RS0": Pads.RS[0] = value; break;
            case "RS1": Pads.RS[1] = value; break;
            case "RS2": Pads.RS[2] = value; break;
            case "/DBE": Pads.nDBE = value; break;
            case "EXT0": Pads.EXT[0] = value; break;
            case "EXT1": Pads.EXT[1] = value; break;
            case "EXT2": Pads.EXT[2] = value; break;
            case "EXT3": Pads.EXT[3] = value; break;
            case "CLK": Pads.CLK = value; break;
            case "/INT": Pads.nINT = value; break;

            case "ALE": Pads.ALE = value; break;
            case "AD0": Pads.AD[0] = value; break;
            case "AD1": Pads.AD[1] = value; break;
            case "AD2": Pads.AD[2] = value; break;
            case "AD3": Pads.AD[3] = value; break;
            case "AD4": Pads.AD[4] = value; break;
            case "AD5": Pads.AD[5] = value; break;
            case "AD6": Pads.AD[6] = value; break;
            case "AD7": Pads.AD[7] = value; break;
            case "A8": Pads.A[8] = value; break;
            case "A9": Pads.A[9] = value; break;
            case "A10": Pads.A[10] = value; break;
            case "A11": Pads.A[11] = value; break;
            case "A12": Pads.A[12] = value; break;
            case "A13": Pads.A[13] = value; break;
            case "/RD": Pads.nRD = value; break;
            case "/WR": Pads.nWR = value; break;
            case "/RES": Pads.nRES = value; break;

            default:
                throw new Exception("Unknown pad name");
        }
    }

    #endregion "Pads"

    /// <summary>
    /// В клоке ничего интересного, просто дергается соотв. лапка
    /// </summary>

    #region "CLK"

    public int? CLKout;                  // Inner CLK to pixel clock and phase shifter
    public int? NotCLKout;               // Inner CLK# to pixel clock and phase shifter

    public long ToggleCounter = 0;      // Счетчик переключений CLK. 
                                        // Из этого счетчика можно получить количество тактов (нужно поделить значение на 2)

    public void ToggleClock ()
    {
        if (Pads.CLK == null)
        {
            throw new Exception("CLK is not assigned!");
        }

        Pads.CLK = Base.Toggle((int)Pads.CLK);
        CLKout = Pads.CLK;
        NotCLKout = Base.Not((int)Pads.CLK);

        ToggleCounter++;
    }

    #endregion "CLK"

    /// <summary>
    /// Сброс PPU
    /// </summary>

    #region "Reset"

    public int? RES;            // Внутренний сигнал сброса
    public int? RC;             // Внутренний сигнал очистки регистров (register clear)
    public int? RESCL = 0;      // Внутренний сигнал очистки защелки Reset FF
                                // TODO: пока нет схемы генерации сигнала будем считать что он не определен

    public int? ResetFF = Base.GetUndefined();    // Значение защелки Reset FF

    /// После прихода внешнего сигнала /RES = 0 защелка устанавливается, чтобы "не потерять" сигнал сброса.
    /// Защелка остается установленной до тех пор, пока не будет очищена RESCL = 1
    /// 
    /// Выходное значение защелки подается на схему очистки регистров (сигнал RC - Register Clear)
    /// 
    /// Схема полностью асинхронная и не зависит от CLK

    public void ResetPadLogic ()
    {
        if ( Pads.nRES == null)
        {
            throw new Exception("/RES not assigned!");
        }

        RES = Base.Not((int)Pads.nRES);

        ResetFF = Base.Nor((int)RESCL, Base.Nor((int)RES, (int)ResetFF));

        RC = ResetFF;

        // Обновим внетруенние счетчики циклов

        if ((int)RES != 0)
        {
            ToggleCounter = 0;
            PCLK_Counter = 0;
        }
    }

    #endregion "Reset"

    /// <summary>
    /// PCLK = CLK / 4
    /// </summary>

    #region "Pixel Clock"

    /// Делитель реализуется путем последовательной передачи значения между защелками по кругу
    /// Значение защелок хранится как емкость на затворах FET
    /// Изначально значение защелок не определено (x)
    /// Сигнал сброса (RES) обнуляет первую защелку в цепочке (Latch[0]), когда CLK=1

    // Изначально значение контекста PCLK не определено

    public int? PCLK;
    public int? nPCLK;
    public int?[] PCLK_Latch = new int?[4] {
        Base.GetUndefined(),
        Base.GetUndefined(),
        Base.GetUndefined(),
        Base.GetUndefined() };
    public long PCLK_Counter = 0;

    public void PixelClockLogic ()
    {
        // Схема находится в неопределенном состоянии, потому что CLK логика ещё не сработала
        if ( CLKout == null || NotCLKout == null)
        {
            return;
        }

        if ( CLKout != 0)
        {
            // Если RES ещё не определён, будем считать что он равен Z, то есть не используется
            int resetInternal = 0;
            if ( RES != null )
            {
                resetInternal = (int)RES;
            }

            PCLK_Latch[0] = Base.And((int)PCLK_Latch[3], Base.Not(resetInternal));
            PCLK_Latch[2] = Base.Not((int)PCLK_Latch[1]);
        }

        if ( NotCLKout != 0)
        {
            PCLK_Latch[1] = Base.Not((int)PCLK_Latch[0]);
            PCLK_Latch[3] = Base.Not((int)PCLK_Latch[2]);
        }

        int? prevPclk = PCLK;

        PCLK = Base.Not((int)PCLK_Latch[3]);

        // Обновим глобальный счетчик полных циклов PCLK

        if (PCLK != prevPclk && (PCLK != 0) && prevPclk != null)
        {
            PCLK_Counter++;
        }

        nPCLK = Base.Not((int)PCLK);
    }

    #endregion "Pixel Clock"

    ///
    /// Схема выборки регистров состоит из R/W декодера и RS декодера
    /// 

    #region "PPU Register Select"

    public int? nRDInternal;            // Внутренний сигнал /RD для регистров
    public int? nWRInternal;            // Внутренний сигнал /WR для регистров

    public void RwDecoder ()
    {
        nRDInternal = Base.Not(
            Base.Nor((int)Pads.nDBE, Base.Not((int)Pads.RnW))
            );

        nWRInternal = Base.Not(
            Base.Nor((int)Pads.nDBE, (int)Pads.RnW)
            );
    }

    #endregion "PPU Register Select"

}
