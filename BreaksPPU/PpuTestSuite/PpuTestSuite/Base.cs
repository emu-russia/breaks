// Базовые логические операции

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

public class Base
{
    public static int Not(int n)
    {
        return ~(n & 1) & 1;
    }

    public static int Or(int a, int b)
    {
        return (a | b) & 1;
    }

    public static int Nor(int a, int b)
    {
        return ~(a | b) & 1;
    }

    public static int And(int a, int b)
    {
        return (a & b) & 1;
    }

    public static int Nand(int a, int b)
    {
        return ~(a & b) & 1;
    }

    public static int Toggle(int n)
    {
        n &= 1;
        n ^= 1;
        return n & 1;
    }

}
