/// Simple class to generate 6502 N-Flag circuit as graph

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GraphFlow
{
    class NFlagGeneratorClass
    {

        public static Graph GenerateNFlag ()
        {
            Graph nflag = new Graph("6502 N-Flag");

            // Nodes

            nflag.nodes.Add(new Node(nflag, 0, "DB/N"));
            nflag.nodes.Add(new Node(nflag, 1, "/DB7"));
            nflag.nodes.Add(new Node(nflag, 2, "PHI1"));
            nflag.nodes.Add(new Node(nflag, 3, "PHI2"));
            nflag.nodes.Add(new Node(nflag, 4, "/N_OUT"));
            
            nflag.nodes.Add(new Node(nflag, 5, "nfet1"));
            nflag.nodes.Add(new Node(nflag, 6, "0"));
            nflag.nodes.Add(new Node(nflag, 7, "out1"));

            nflag.nodes.Add(new Node(nflag, 8, "nfet4"));
            nflag.nodes.Add(new Node(nflag, 9, "0"));
            nflag.nodes.Add(new Node(nflag, 10, "out4"));

            nflag.nodes.Add(new Node(nflag, 11, "nfet5"));
            nflag.nodes.Add(new Node(nflag, 12, "in5"));
            nflag.nodes.Add(new Node(nflag, 13, "out5"));

            nflag.nodes.Add(new Node(nflag, 14, "nfet2"));
            nflag.nodes.Add(new Node(nflag, 15, "in2"));
            nflag.nodes.Add(new Node(nflag, 16, "out2"));

            nflag.nodes.Add(new Node(nflag, 17, "nfet3"));
            nflag.nodes.Add(new Node(nflag, 18, "0"));
            nflag.nodes.Add(new Node(nflag, 19, "out3"));

            nflag.nodes.Add(new Node(nflag, 20, "nfet6"));
            nflag.nodes.Add(new Node(nflag, 21, "in6"));
            nflag.nodes.Add(new Node(nflag, 22, "out6"));

            nflag.nodes.Add(new Node(nflag, 23, "nfet7"));
            nflag.nodes.Add(new Node(nflag, 24, "in7"));
            nflag.nodes.Add(new Node(nflag, 25, "out7"));

            nflag.nodes.Add(new Node(nflag, 26, "nfet8"));
            nflag.nodes.Add(new Node(nflag, 27, "0"));
            nflag.nodes.Add(new Node(nflag, 28, "out8"));

            nflag.nodes.Add(new Node(nflag, 29, "v4"));
            nflag.nodes.Add(new Node(nflag, 30, "v1"));
            nflag.nodes.Add(new Node(nflag, 31, "v3"));
            nflag.nodes.Add(new Node(nflag, 32, "1"));
            nflag.nodes.Add(new Node(nflag, 33, "v5"));
            nflag.nodes.Add(new Node(nflag, 34, "1"));
            nflag.nodes.Add(new Node(nflag, 35, "v2"));
            nflag.nodes.Add(new Node(nflag, 36, "1"));

            // Edges

            nflag.edges.Add(new Edge(nflag, 0, 5, 7));
            nflag.edges.Add(new Edge(nflag, 1, 6, 5));
            nflag.edges.Add(new Edge(nflag, 2, 8, 10));
            nflag.edges.Add(new Edge(nflag, 3, 9, 8));
            nflag.edges.Add(new Edge(nflag, 4, 11, 13));
            nflag.edges.Add(new Edge(nflag, 5, 12, 11));
            nflag.edges.Add(new Edge(nflag, 6, 14, 16));
            nflag.edges.Add(new Edge(nflag, 7, 15, 14));
            nflag.edges.Add(new Edge(nflag, 8, 17, 19));
            nflag.edges.Add(new Edge(nflag, 9, 18, 17));
            nflag.edges.Add(new Edge(nflag, 10, 20, 22));
            nflag.edges.Add(new Edge(nflag, 11, 21, 20));
            nflag.edges.Add(new Edge(nflag, 12, 23, 25));
            nflag.edges.Add(new Edge(nflag, 13, 24, 23));
            nflag.edges.Add(new Edge(nflag, 14, 26, 28));
            nflag.edges.Add(new Edge(nflag, 15, 27, 26));
            nflag.edges.Add(new Edge(nflag, 16, 22, 17, "g"));
            nflag.edges.Add(new Edge(nflag, 17, 3, 20, "g"));
            nflag.edges.Add(new Edge(nflag, 18, 28, 29));
            nflag.edges.Add(new Edge(nflag, 19, 29, 21));
            nflag.edges.Add(new Edge(nflag, 20, 10, 12));
            nflag.edges.Add(new Edge(nflag, 21, 0, 30));
            nflag.edges.Add(new Edge(nflag, 22, 30, 5, "g"));
            nflag.edges.Add(new Edge(nflag, 23, 30, 11, "g"));
            nflag.edges.Add(new Edge(nflag, 24, 1, 8, "g"));
            nflag.edges.Add(new Edge(nflag, 25, 2, 23, "g"));
            nflag.edges.Add(new Edge(nflag, 26, 25, 26, "g"));
            nflag.edges.Add(new Edge(nflag, 27, 13, 31));
            nflag.edges.Add(new Edge(nflag, 28, 31, 24));
            nflag.edges.Add(new Edge(nflag, 29, 29, 33));
            nflag.edges.Add(new Edge(nflag, 30, 33, 4));
            nflag.edges.Add(new Edge(nflag, 31, 32, 33));
            nflag.edges.Add(new Edge(nflag, 32, 34, 35));
            nflag.edges.Add(new Edge(nflag, 33, 35, 14, "g"));
            nflag.edges.Add(new Edge(nflag, 34, 7, 35));
            nflag.edges.Add(new Edge(nflag, 35, 36, 31));
            nflag.edges.Add(new Edge(nflag, 36, 16, 31));
            nflag.edges.Add(new Edge(nflag, 37, 19, 15));

            return nflag;
        }

    }
}
