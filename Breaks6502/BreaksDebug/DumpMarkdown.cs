// A utility to dump the state of the CPU on each half-cycle directly to our wiki.

using System.IO;

namespace BreaksDebug
{
    public class MarkdownDump
    {
        public static void ExportStepMarkdown(BogusSystem.CpuDebugInfo_RegsBuses regsBuses,
            BogusSystem.CpuDebugInfo_Internals internals,
            BogusSystem.CpuDebugInfo_Decoder decoderOut,
            BogusSystem.CpuDebugInfo_Commands commands,
            byte PHI1, byte PHI2, 
            DataPathView dataPathView,
            string MarkdownDir, string MarkdownImgDir, string WikiRoot)
        {
            // Generate file name

            var iname = QuickDisasm.Disasm(regsBuses.IRForDisasm).Split(' ')[0].Replace("???", "UB");
            var opcodeHex = regsBuses.IRForDisasm.ToString("X2");
            string name = opcodeHex + "_" + iname;

            string Tx = "";

            if (internals.n_T0 == 0 && internals.n_T1X == 0)
            {
                Tx = "T01";
            }
            else if (internals.n_T0 == 0 && internals.n_T2 == 0)
            {
                Tx = "T02";
            }
            else if (internals.n_T0 == 0)
            {
                Tx = "T0";
            }
            else if (internals.n_T1X == 0)
            {
                Tx = "T1";
            }
            else if (internals.n_T2 == 0)
            {
                Tx = "T2";
            }
            else if (internals.n_T3 == 0)
            {
                Tx = "T3";
            }
            else if (internals.n_T4 == 0)
            {
                Tx = "T4";
            }
            else if (internals.n_T5 == 0)
            {
                Tx = "T5";
            }
            else
            {
                if (internals.T5 != 0)
                {
                    Tx = "T6_RMW";
                }
                else if (internals.T6 != 0)
                {
                    Tx = "T7_RMW";
                }
                else
                {
                    Tx = "TX";
                }
            }

            name += "_" + Tx;

            string Phi = "";

            if (PHI1 != 0)
            {
                Phi = "PHI1";
            }

            if (PHI2 != 0)
            {
                Phi = "PHI2";
            }

            name += "_" + Phi;

            // Markdown

            string md = "";

            md += "## " + iname + " (0x" + opcodeHex + "), " + Tx + " (" + Phi + ")\n\n";

            md += "|Component/Signal|State|\n";
            md += "|---|---|\n";

            // Dispatcher

            md += "|Dispatcher|";
            md += "T0: " + internals.T0 + ", ";
            md += "/T0: " + internals.n_T0 + ", ";
            md += "/T1X: " + internals.n_T1X + ", ";
            md += "0/IR: " + internals.Z_IR + ", ";
            md += "FETCH: " + internals.FETCH + ", ";
            md += "/ready: " + internals.n_ready + ", ";
            md += "WR: " + internals.WR + ", ";
            md += "ACRL1: " + internals.ACRL1 + ", ";
            md += "ACRL2: " + internals.ACRL2 + ", ";
            md += "T5: " + internals.T5 + ", ";
            md += "T6: " + internals.T6 + ", ";
            md += "ENDS: " + internals.ENDS + ", ";
            md += "ENDX: " + internals.ENDX + ", ";
            md += "TRES1: " + internals.TRES1 + ", ";
            md += "TRESX: " + internals.TRESX;
            md += "|\n";

            // Interrupts

            md += "|Interrupts|";
            md += "/NMIP: " + internals.n_NMIP + ", ";
            md += "/IRQP: " + internals.n_IRQP + ", ";
            md += "RESP: " + internals.RESP + ", ";
            md += "BRK6E: " + internals.BRK6E + ", ";
            md += "BRK7: " + internals.BRK7 + ", ";
            md += "DORES: " + internals.DORES + ", ";
            md += "/DONMI: " + internals.n_DONMI;
            md += "|\n";

            // Extra Cycle Counter

            md += "|Extra Cycle Counter|";
            md += "T1: " + internals.T1 + ", ";
            md += "TRES2: " + internals.TRES2 + ", ";
            md += "/T2: " + internals.n_T2 + ", ";
            md += "/T3: " + internals.n_T3 + ", ";
            md += "/T4: " + internals.n_T4 + ", ";
            md += "/T5: " + internals.n_T5;
            md += "|\n";

            // Decoder

            md += "|Decoder|";
            bool first = true;
            foreach (var d in decoderOut.decoder_out)
            {
                if (first)
                {
                    first = false;
                }
                else
                {
                    md += ", ";
                }

                md += d;
            }
            md += "|\n";

            // Commands

            md += "|Commands|";
            first = true;
            foreach (var d in commands.commands)
            {
                if (first)
                {
                    first = false;
                }
                else
                {
                    md += ", ";
                }

                md += d;
            }
            md += "|\n";

            md += "|ALU Carry In|" + (commands.n_ACIN == 0 ? 1 : 0) + "|\n";
            md += "|DAA|" + (commands.n_DAA == 0 ? 1 : 0) + "|\n";
            md += "|DSA|" + (commands.n_DSA == 0 ? 1 : 0) + "|\n";
            md += "|Increment PC|" + (commands.n_1PC == 0 ? 1 : 0) + "|\n";

            // Regs

            md += "|Regs||\n";
            md += "|IR|" + regsBuses.IR + "|\n";
            md += "|PD|" + regsBuses.PD + "|\n";
            md += "|Y|" + regsBuses.Y + "|\n";
            md += "|X|" + regsBuses.X + "|\n";
            md += "|S|" + regsBuses.S + "|\n";
            md += "|AI|" + regsBuses.AI + "|\n";
            md += "|BI|" + regsBuses.BI + "|\n";
            md += "|ADD|" + regsBuses.ADD + "|\n";
            md += "|AC|" + regsBuses.AC + "|\n";
            md += "|PCL|" + regsBuses.PCL + "|\n";
            md += "|PCH|" + regsBuses.PCH + "|\n";
            md += "|ABL|" + regsBuses.ABL + "|\n";
            md += "|ABH|" + regsBuses.ABH + "|\n";
            md += "|DL|" + regsBuses.DL + "|\n";
            md += "|DOR|" + regsBuses.DOR + "|\n";

            // Flags

            md += "|Flags|";
            md += "C: " + regsBuses.C_OUT + ", ";
            md += "Z: " + regsBuses.Z_OUT + ", ";
            md += "I: " + regsBuses.I_OUT + ", ";
            md += "D: " + regsBuses.D_OUT + ", ";
            md += "B: " + regsBuses.B_OUT + ", ";
            md += "V: " + regsBuses.V_OUT + ", ";
            md += "N: " + regsBuses.N_OUT;
            md += "|\n";

            // Buses

            md += "|Buses||\n";
            md += "|SB|" + regsBuses.SB + "|\n";
            md += "|DB|" + regsBuses.DB + "|\n";
            md += "|ADL|" + regsBuses.ADL + "|\n";
            md += "|ADH|" + regsBuses.ADH + "|\n";

            md += "\n";
            md += "!["+ name + "](" + WikiRoot + MarkdownImgDir + "/" + name + ".jpg)\n";

            File.WriteAllText(MarkdownDir + "/" + name + ".md", md);

            // A picture of the connections on the bottom of the processor.

            dataPathView.SaveSceneAsImage(MarkdownDir + "/" + MarkdownImgDir + "/" + name + ".jpg");
        }
    }
}
