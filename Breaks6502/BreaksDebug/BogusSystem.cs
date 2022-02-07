// A dummy device that uses the 6502 as a processor.
// Contains 64 Kbytes of memory and nothing else.

using System;
using System.Text;
using System.Globalization;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.Collections;
using System.Linq;

using Be.Windows.Forms;

namespace BreaksDebug
{
    public class BogusSystem
    {
        public int Cycle = 0;

        byte CLK = 0;
        IByteProvider mem;

        public class CpuPads
        {
            [Category("Inputs")]
            public byte n_NMI { get; set; }
            [Category("Inputs")]
            public byte n_IRQ { get; set; }
            [Category("Inputs")]
            public byte n_RES { get; set; }
            [Category("Inputs")]
            public byte PHI0 { get; set; }
            [Category("Inputs")]
            public byte RDY { get; set; }
            [Category("Inputs")]
            public byte SO { get; set; }
            [Category("Outputs")]
            public byte PHI1 { get; set; }
            [Category("Outputs")]
            public byte PHI2 { get; set; }
            [Category("Outputs")]
            public byte RnW { get; set; }
            [Category("Outputs")]
            public byte SYNC { get; set; }
            [Category("Address Bus")]
            public UInt16 A { get; set; }
            [Category("Address Bus")]
            public string Addr { get; set; }
            [Category("Data Bus")]
            public byte D { get; set; }
        }

        [StructLayout(LayoutKind.Sequential, Pack=1)]
        unsafe struct CpuPadsRaw
        {
            public byte n_NMI;
            public byte n_IRQ;
            public byte n_RES;
            public byte PHI0;
            public byte RDY;
            public byte SO;
            public byte PHI1;
            public byte PHI2;
            public byte RnW;
            public byte SYNC;
            public UInt16 A;
            public byte D;
        }

        public class CpuDebugInfo_RegsBuses
        {
            [Category("Internal buses")]
            public string SB { get; set; }
            [Category("Internal buses")]
            public string DB { get; set; }
            [Category("Internal buses")]
            public string ADL { get; set; }
            [Category("Internal buses")]
            public string ADH { get; set; }

            [Category("Regs")]
            public string IR { get; set; }
            [Category("Regs")]
            public string PD { get; set; }
            [Category("Regs")]
            public string Y { get; set; }
            [Category("Regs")]
            public string X { get; set; }
            [Category("Regs")]
            public string S { get; set; }
            [Category("Regs")]
            public string AI { get; set; }
            [Category("Regs")]
            public string BI { get; set; }
            [Category("Regs")]
            public string ADD { get; set; }
            [Category("Regs")]
            public string AC { get; set; }
            [Category("Regs")]
            public string PCL { get; set; }
            [Category("Regs")]
            public string PCH { get; set; }
            [Category("Regs")]
            public string PCLS { get; set; }
            [Category("Regs")]
            public string PCHS { get; set; }
            [Category("Regs")]
            public string ABL { get; set; }
            [Category("Regs")]
            public string ABH { get; set; }
            [Category("Regs")]
            public string DL { get; set; }
            [Category("Regs")]
            public string DOR { get; set; }

            [Category("Flags")]
            public byte C_OUT { get; set; }
            [Category("Flags")]
            public byte Z_OUT { get; set; }
            [Category("Flags")]
            public byte I_OUT { get; set; }
            [Category("Flags")]
            public byte D_OUT { get; set; }
            [Category("Flags")]
            public byte B_OUT { get; set; }
            [Category("Flags")]
            public byte V_OUT { get; set; }
            [Category("Flags")]
            public byte N_OUT { get; set; }

            public byte IRForDisasm;
            public byte PDForDisasm;
            public UInt16 PCForUnitTest;
        }

        public class CpuDebugInfo_Internals
        {
            [Category("Prev Ready")]
            public byte n_PRDY { get; set; }
            [Category("Interrupts")]
            public byte n_NMIP { get; set; }
            [Category("Interrupts")]
            public byte n_IRQP { get; set; }
            [Category("Interrupts")]
            public byte RESP { get; set; }
            [Category("Interrupts")]
            public byte BRK6E { get; set; }
            [Category("Interrupts")]
            public byte BRK7 { get; set; }
            [Category("Interrupts")]
            public byte DORES { get; set; }
            [Category("Interrupts")]
            public byte n_DONMI { get; set; }
            [Category("Extra Cycle Counter")]
            public byte n_T2 { get; set; }
            [Category("Extra Cycle Counter")]
            public byte n_T3 { get; set; }
            [Category("Extra Cycle Counter")]
            public byte n_T4 { get; set; }
            [Category("Extra Cycle Counter")]
            public byte n_T5 { get; set; }
            [Category("Dispatcher")]
            public byte T0 { get; set; }
            [Category("Dispatcher")]
            public byte n_T0 { get; set; }
            [Category("Dispatcher")]
            public byte n_T1X { get; set; }
            [Category("Dispatcher")]
            public byte Z_IR { get; set; }
            [Category("Dispatcher")]
            public byte FETCH { get; set; }
            [Category("Dispatcher")]
            public byte n_ready { get; set; }
            [Category("Dispatcher")]
            public byte WR { get; set; }
            [Category("Dispatcher")]
            public byte TRES2 { get; set; }
            [Category("Dispatcher")]
            public byte ACRL1 { get; set; }
            [Category("Dispatcher")]
            public byte ACRL2 { get; set; }
            [Category("Dispatcher")]
            public byte T1 { get; set; }
            [Category("Dispatcher")]
            public byte T5 { get; set; }
            [Category("Dispatcher")]
            public byte T6 { get; set; }
            [Category("Dispatcher")]
            public byte ENDS { get; set; }
            [Category("Dispatcher")]
            public byte ENDX { get; set; }
            [Category("Dispatcher")]
            public byte TRES1 { get; set; }
            [Category("Dispatcher")]
            public byte TRESX { get; set; }
            [Category("Branch Logic")]
            public byte BRFW { get; set; }
            [Category("Branch Logic")]
            public byte n_BRTAKEN { get; set; }
            [Category("ALU Output")]
            public byte ACR { get; set; }
            [Category("ALU Output")]
            public byte AVR { get; set; }
        }

        public class CpuDebugInfo_Decoder
        {
            // Decoder

            [TypeConverter(typeof(ListConverter))]
            [Category("Decoder")]
            public List<string> decoder_out { get; set; } = new List<string>();
        }

        public class CpuDebugInfo_Commands
        {
            // Control commands

            [TypeConverter(typeof(ListConverter))]
            [Category("Control commands")]
            public List<string> commands { get; set; } = new List<string>();
            [Category("Control commands")]
            public byte n_ACIN { get; set; }
            [Category("Control commands")]
            public byte n_DAA { get; set; }
            [Category("Control commands")]
            public byte n_DSA { get; set; }
            [Category("Control commands")]
            public byte n_1PC { get; set; }

            public byte [] cmd = new byte [(int)ControlCommand.Max];
            public bool WR = false;
        }

        public enum ControlCommand
        {
            Y_SB = 0,
            SB_Y,
            X_SB,
            SB_X,
            S_ADL,
            S_SB,
            SB_S,
            S_S,
            NDB_ADD,
            DB_ADD,
            Z_ADD,
            SB_ADD,
            ADL_ADD,
            ANDS,
            EORS,
            ORS,
            SRS,
            SUMS,
            ADD_SB7,
            ADD_SB06,
            ADD_ADL,
            SB_AC,
            AC_SB,
            AC_DB,
            ADH_PCH,
            PCH_PCH,
            PCH_ADH,
            PCH_DB,
            ADL_PCL,
            PCL_PCL,
            PCL_ADL,
            PCL_DB,
            ADH_ABH,
            ADL_ABL,
            Z_ADL0,
            Z_ADL1,
            Z_ADL2,
            Z_ADH0,
            Z_ADH17,
            SB_DB,
            SB_ADH,
            DL_ADL,
            DL_ADH,
            DL_DB,
            P_DB,
            DB_P,
            DBZ_Z,
            DB_N,
            IR5_C,
            DB_C,
            ACR_C,
            IR5_D,
            IR5_I,
            DB_V,
            AVR_V,
            Z_V,
            Max,
        }


        [StructLayout(LayoutKind.Sequential, Pack = 1)]
        unsafe struct CpuDebugInfoRaw
        {
            // Regs & Buses

            public byte SB;
            public byte DB;
            public byte ADL;
            public byte ADH;

            public byte IR;
            public byte PD;
            public byte Y;
            public byte X;
            public byte S;
            public byte AI;
            public byte BI;
            public byte ADD;
            public byte AC;
            public byte PCL;
            public byte PCH;
            public byte PCLS;
            public byte PCHS;
            public byte ABL;
            public byte ABH;
            public byte DL;
            public byte DOR;

            public byte C_OUT;
            public byte Z_OUT;
            public byte I_OUT;
            public byte D_OUT;
            public byte B_OUT;
            public byte V_OUT;
            public byte N_OUT;

            // Internals

            public byte n_PRDY;
            public byte n_NMIP;
            public byte n_IRQP;
            public byte RESP;
            public byte BRK6E;
            public byte BRK7;
            public byte DORES;
            public byte n_DONMI;
            public byte n_T2;
            public byte n_T3;
            public byte n_T4;
            public byte n_T5;
            public byte T0;
            public byte n_T0;
            public byte n_T1X;
            public byte Z_IR;
            public byte FETCH;
            public byte n_ready;
            public byte WR;
            public byte TRES2;
            public byte ACRL1;
            public byte ACRL2;
            public byte T1;
            public byte T5;
            public byte T6;
            public byte ENDS;
            public byte ENDX;
            public byte TRES1;
            public byte TRESX;
            public byte BRFW;
            public byte n_BRTAKEN;
            public byte ACR;
            public byte AVR;

            // Decoder

            public fixed byte decoder_out[130];

            // Control commands

            public fixed byte cmd[(int)ControlCommand.Max];
            public byte n_ACIN;
            public byte n_DAA;
            public byte n_DSA;
            public byte n_1PC;          // From Dispatcher
        }

        public CpuPads cpu_pads = new CpuPads();
        CpuDebugInfoRaw info = new CpuDebugInfoRaw();

        public void Step(bool trace)
        {
            if (trace)
            {
                Console.WriteLine("Step");
            }

            cpu_pads.PHI0 = CLK;

            // Execute M6502Core::sim

            // Reading must be done before the processor simulation, so that data is already on the data bus,
            // and writing must be done after the simulation, because the processor must first put something on the data bus.

            if (cpu_pads.PHI1 == 1)
            {
                // Although all memory operations are performed only during PHI2, a check is made here on PHI1, since the output of PHI2 is not yet set by the simulator.
                MemRead(trace);
            }

            CpuPadsRaw pads = SerializePads (cpu_pads);

            Sim(ref pads, ref info);

            cpu_pads = DeserializePads(pads);

            if (cpu_pads.PHI2 == 1)
            {
                MemWrite(trace);
            }

            // Clockgen

            if (CLK != 0)
            {
                CLK = 0;
                Cycle++;
            }
            else
            {
                CLK = 1;
            }
        }
  
        public void AttatchMemory (IByteProvider prov)
        {
            mem = prov;
        }

        public class MemoryMapping
        {
            public int RamStart = 0;
            public int RamSize = 0x800;
            public int RomStart = 0xc000;
            public int RomSize = 0x4000;
        }

        MemoryMapping memMap = new MemoryMapping();

        public void SetMemoryMapping(MemoryMapping map)
        {
            memMap = map;
        }

        void MemRead(bool trace)
        {
            if (cpu_pads.RnW == 1)
            {
                long address = cpu_pads.A;

                // CPU Read

                if ( (address >= memMap.RamStart && address < (memMap.RamStart + memMap.RamSize)) || 
                    (address >= memMap.RomStart && address < (memMap.RomStart + memMap.RomSize)) )
                {
                    cpu_pads.D = mem.ReadByte(address);
                    if (trace)
                    {
                        Console.WriteLine("CPU Read " + address.ToString("X4") + " " + cpu_pads.D.ToString("X2"));
                    }
                }
                else
                {
                    if (trace)
                    {
                        Console.WriteLine("CPU Read " + address.ToString("X4") + " ignored");
                    }
                }
            }
        }

        void MemWrite(bool trace)
        {
            if (cpu_pads.RnW == 0)
            {
                long address = cpu_pads.A;

                // CPU Write

                if (address >= memMap.RamStart && address < (memMap.RamStart + memMap.RamSize))
                {
                    mem.WriteByte(address, cpu_pads.D);
                    if (trace)
                    {
                        Console.WriteLine("CPU Write " + address.ToString("X4") + " " + cpu_pads.D.ToString("X2"));
                    }
                }
                else
                {
                    if (trace)
                    {
                        Console.WriteLine("CPU Write " + address.ToString("X4") + " ignored");
                    }
                }
            }
        }

        CpuPadsRaw SerializePads (CpuPads pads)
        {
            CpuPadsRaw pads_raw = new CpuPadsRaw();

            pads_raw.n_NMI = pads.n_NMI;
            pads_raw.n_IRQ = pads.n_IRQ;
            pads_raw.n_RES = pads.n_RES;
            pads_raw.PHI0 = pads.PHI0;
            pads_raw.RDY = pads.RDY;
            pads_raw.SO = pads.SO;
            pads_raw.PHI1 = pads.PHI1;
            pads_raw.PHI2 = pads.PHI2;
            pads_raw.RnW = pads.RnW;
            pads_raw.SYNC = pads.SYNC;
            pads_raw.A = pads.A;
            pads_raw.D = pads.D;

            return pads_raw;
        }

        CpuPads DeserializePads(CpuPadsRaw pads_raw)
        {
            CpuPads pads = new CpuPads();

            pads.n_NMI = pads_raw.n_NMI;
            pads.n_IRQ = pads_raw.n_IRQ;
            pads.n_RES = pads_raw.n_RES;
            pads.PHI0 = pads_raw.PHI0;
            pads.RDY = pads_raw.RDY;
            pads.SO = pads_raw.SO;
            pads.PHI1 = pads_raw.PHI1;
            pads.PHI2 = pads_raw.PHI2;
            pads.RnW = pads_raw.RnW;
            pads.SYNC = pads_raw.SYNC;

            pads.A = pads_raw.A;
            pads.Addr = "0x" + pads.A.ToString("X4");
            pads.D = pads_raw.D;

            return pads;
        }

        public CpuDebugInfo_RegsBuses GetRegsBuses()
        {
            CpuDebugInfo_RegsBuses res = new CpuDebugInfo_RegsBuses();

            res.SB = "0x" + info.SB.ToString("X2");
            res.DB = "0x" + info.DB.ToString("X2");
            res.ADL = "0x" + info.ADL.ToString("X2");
            res.ADH = "0x" + info.ADH.ToString("X2");

            res.IR = "0x" + info.IR.ToString("X2");
            res.PD = "0x" + info.PD.ToString("X2");
            res.Y = "0x" + info.Y.ToString("X2");
            res.X = "0x" + info.X.ToString("X2");
            res.S = "0x" + info.S.ToString("X2");
            res.AI = "0x" + info.AI.ToString("X2");
            res.BI = "0x" + info.BI.ToString("X2");
            res.ADD = "0x" + info.ADD.ToString("X2");
            res.AC = "0x" + info.AC.ToString("X2");
            res.PCL = "0x" + info.PCL.ToString("X2");
            res.PCH = "0x" + info.PCH.ToString("X2");
            res.PCLS = "0x" + info.PCLS.ToString("X2");
            res.PCHS = "0x" + info.PCHS.ToString("X2");
            res.ABL = "0x" + info.ABL.ToString("X2");
            res.ABH = "0x" + info.ABH.ToString("X2");
            res.DL = "0x" + info.DL.ToString("X2");
            res.DOR = "0x" + info.DOR.ToString("X2");

            res.C_OUT = info.C_OUT;
            res.Z_OUT = info.Z_OUT;
            res.I_OUT = info.I_OUT;
            res.D_OUT = info.D_OUT;
            res.B_OUT = info.B_OUT;
            res.V_OUT = info.V_OUT;
            res.N_OUT = info.N_OUT;

            res.IRForDisasm = info.IR;
            res.PDForDisasm = info.PD;
            res.PCForUnitTest = (UInt16)(((UInt16)info.PCH << 8) | (UInt16)info.PCL);

            return res;
        }

        public CpuDebugInfo_Internals GetInternals()
        {
            CpuDebugInfo_Internals res = new CpuDebugInfo_Internals();

            res.n_PRDY = info.n_PRDY;
            res.n_NMIP = info.n_NMIP;
            res.n_IRQP = info.n_IRQP;
            res.RESP = info.RESP;
            res.BRK6E = info.BRK6E;
            res.BRK7 = info.BRK7;
            res.DORES = info.DORES;
            res.n_DONMI = info.n_DONMI;
            res.n_T2 = info.n_T2;
            res.n_T3 = info.n_T3;
            res.n_T4 = info.n_T4;
            res.n_T5 = info.n_T5;
            res.T0 = info.T0;
            res.n_T0 = info.n_T0;
            res.n_T1X = info.n_T1X;
            res.Z_IR = info.Z_IR;
            res.FETCH = info.FETCH;
            res.n_ready = info.n_ready;
            res.WR = info.WR;
            res.TRES2 = info.TRES2;
            res.ACRL1 = info.ACRL1;
            res.ACRL2 = info.ACRL2;
            res.T1 = info.T1;
            res.T5 = info.T5;
            res.T6 = info.T6;
            res.ENDS = info.ENDS;
            res.ENDX = info.ENDX;
            res.TRES1 = info.TRES1;
            res.TRESX = info.TRESX;
            res.BRFW = info.BRFW;
            res.n_BRTAKEN = info.n_BRTAKEN;
            res.ACR = info.ACR;
            res.AVR = info.AVR;

            return res;
        }

        public CpuDebugInfo_Decoder GetDecoder()
        {
            CpuDebugInfo_Decoder res = new CpuDebugInfo_Decoder();

            for (int n = 0; n < 130; n++)
            {
                unsafe
                {
                    if (info.decoder_out[n] != 0)
                    {
                        string text = n.ToString() + ": " + DecoderDecoder.GetDecoderOutName(n);
                        res.decoder_out.Add(text);
                    }
                }
            }

            return res;
        }

        public CpuDebugInfo_Commands GetCommands()
        {
            CpuDebugInfo_Commands res = new CpuDebugInfo_Commands();

            for (int n=0; n<(int)ControlCommand.Max; n++)
            {
                unsafe
                {
                    if (info.cmd[n] != 0)
                    {
                        res.commands.Add(((ControlCommand)n).ToString());
                    }
                    res.cmd[n] = info.cmd[n];
                }
            }

            res.n_ACIN = info.n_ACIN;
            res.n_DAA = info.n_DAA;
            res.n_DSA = info.n_DSA;
            res.n_1PC = info.n_1PC;
            res.WR = info.WR != 0 ? true : false;
            
            return res;
        }

        [DllImport("M6502CoreInterop.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern void Sim(ref CpuPadsRaw pads, ref CpuDebugInfoRaw debugInfo);

        // https://stackoverflow.com/questions/32582504/propertygrid-expandable-collection

        public class ListConverter : CollectionConverter
        {
            public override bool GetPropertiesSupported(ITypeDescriptorContext context)
            {
                return true;
            }

            public override PropertyDescriptorCollection GetProperties(ITypeDescriptorContext context, object value, Attribute[] attributes)
            {
                IList list = value as IList;
                if (list == null || list.Count == 0)
                    return base.GetProperties(context, value, attributes);

                var items = new PropertyDescriptorCollection(null);
                for (int i = 0; i < list.Count; i++)
                {
                    object item = list[i];
                    items.Add(new ExpandableCollectionPropertyDescriptor(list, i));
                }
                return items;
            }

            public class ExpandableCollectionPropertyDescriptor : PropertyDescriptor
            {
                private IList collection;
                private readonly int _index;

                public ExpandableCollectionPropertyDescriptor(IList coll, int idx)
                    : base(GetDisplayName(coll, idx), null)
                {
                    collection = coll;
                    _index = idx;
                }

                private static string GetDisplayName(IList list, int index)
                {
                    return "[" + index + "]  " + CSharpName(list[index].GetType());
                }

                private static string CSharpName(Type type)
                {
                    var sb = new StringBuilder();
                    var name = type.Name;
                    if (!type.IsGenericType)
                        return name;
                    sb.Append(name.Substring(0, name.IndexOf('`')));
                    sb.Append("<");
                    sb.Append(string.Join(", ", type.GetGenericArguments().Select(CSharpName)));
                    sb.Append(">");
                    return sb.ToString();
                }

                public override bool CanResetValue(object component)
                {
                    return true;
                }

                public override Type ComponentType
                {
                    get { return this.collection.GetType(); }
                }

                public override object GetValue(object component)
                {
                    return collection[_index];
                }

                public override bool IsReadOnly
                {
                    get { return false; }
                }

                public override string Name
                {
                    get { return _index.ToString(CultureInfo.InvariantCulture); }
                }

                public override Type PropertyType
                {
                    get { return collection[_index].GetType(); }
                }

                public override void ResetValue(object component)
                {
                }

                public override bool ShouldSerializeValue(object component)
                {
                    return true;
                }

                public override void SetValue(object component, object value)
                {
                    collection[_index] = value;
                }
            }
        }

    }

}
