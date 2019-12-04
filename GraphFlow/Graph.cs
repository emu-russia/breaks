/// Basic graph framework

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Xml;

namespace GraphFlow
{

    class Node
    {
        private int id { get; set; } = -1;
        public string name { get; set; } = "";
        public Graph graph;
        public bool Visited { get; set; } = false;

        private int? NewValue = null;
        public int? Value
        {
            get { return NewValue; }
            set
            {
                OldValue = NewValue;
                NewValue = value;
            }
        }  // Associated value
        public int? OldValue = null;    // Used to keep track of propagation changes

        public Node(Graph _graph)
        {
            graph = _graph;
        }

        private void CheckId(int _id)
        {
            foreach (var node in graph.nodes)
            {
                if (node.GetId() == _id)
                {
                    throw new Exception("Node ID " + _id.ToString() + " already exists");
                }
            }
        }

        public Node(Graph _graph, int _id)
        {
            graph = _graph;
            SetId(_id);
        }

        public Node(Graph _graph, int _id, string _name)
        {
            graph = _graph;
            SetId(_id);
            name = _name;
        }

        public void SetId(int _id)
        {
            CheckId(_id);
            id = _id;
        }

        public int GetId()
        {
            return id;
        }

        public void Dump()
        {
            Console.Write("{0}: {1}", id, name);

            List<Edge> inputs = Inputs();

            if (inputs.Count != 0)
            {
                Console.Write(", inputs:");

                foreach (var edge in inputs)
                {
                    Console.Write(" {0}", edge.GetId().ToString());
                }
            }

            List<Edge> outputs = Outputs();

            if (outputs.Count != 0)
            {
                Console.Write(", outputs:");

                foreach (var edge in outputs)
                {
                    Console.Write(" {0}", edge.GetId().ToString());
                }
            }

            Console.WriteLine("");
        }

        public List<Edge> Inputs()
        {
            List<Edge> inputs = new List<Edge>();

            foreach (var edge in graph.edges)
            {
                if (edge.dest == this)
                {
                    inputs.Add(edge);
                }
            }

            return inputs;
        }

        public List<Edge> Outputs()
        {
            List<Edge> inputs = new List<Edge>();

            foreach (var edge in graph.edges)
            {
                if (edge.source == this)
                {
                    inputs.Add(edge);
                }
            }

            return inputs;
        }

        public void Propagate()
        {
            if (name == "1")
            {
                Value = 1;
            }
            else if (name == "0")
            {
                Value = 0;
            }
            else if (name.Contains("nfet") || name.Contains("pfet"))
            {
                List<Edge> inputs = Inputs();

                Edge source = null;
                Edge gate = null;

                foreach (var edge in inputs)
                {
                    if (edge.name.Contains("g"))
                    {
                        gate = edge;
                    }
                    else
                    {
                        if (source == null)
                        {
                            source = edge;
                        }
                        else
                        {
                            throw new Exception("fet with multiple sources is prohibited");
                        }
                    }
                }

                if (source == null)
                {
                    throw new Exception("Specifiy source to fet");
                }

                if (gate == null)
                {
                    throw new Exception("Specifiy gate to fet");
                }

                // Check gate value

                if (gate.Value != null)
                {
                    if ( name[0] == 'n')
                    {
                        Value = gate.Value != 0 ? source.Value : null;
                    }
                    else
                    {
                        Value = gate.Value == 0 ? source.Value : null;
                    }
                }
                else
                {
                    // Imitate gate capacity (keep value as D-latch)

                    Value = Value;
                }
            }
            else
            {
                int? value = null;
                List<Edge> inputs = Inputs();

                if (inputs.Count() == 0)
                {
                    value = Value;
                }

                // Enumerate inputs until ground wins

                foreach (var edge in inputs)
                {
                    if (edge.Value != null)
                    {
                        value = edge.Value;
                    }

                    if (value == 0)
                        break;
                }

                Value = value;
            }

            Visited = true;

            Console.WriteLine("Propagated node {0} {1}, value={2}, oldValue={3}", id, name, Value, OldValue);

            if (Value != null)
            {
                List<Edge> outputs = Outputs();

                foreach (var edge in outputs)
                {
                    edge.Value = Value;
                    if (!edge.dest.Visited || edge.dest.Value != edge.Value)
                    {
                        edge.dest.Propagate();
                    }
                }
            }
        }

    }

    class Edge
    {
        private int id { get; set; } = -1;
        public string name { get; set; } = "";
        public Node source { get; set; } = null;
        public Node dest { get; set; } = null;
        public Graph graph;

        private int? NewValue = null;
        public int? Value
        {
            get { return NewValue; }
            set
            {
                OldValue = NewValue;
                NewValue = value;
            }
        }  // Associated value
        public int? OldValue = null;    // Used to keep track of propagation changes

        public Edge(Graph _graph)
        {
            graph = _graph;
        }

        private void CheckId(int _id)
        {
            foreach (var edge in graph.edges)
            {
                if (edge.GetId() == _id)
                {
                    throw new Exception("Edge ID " + _id.ToString() + " already exists");
                }
            }
        }

        private void EdgeCtor(Graph _graph, int _id, int sourceId, int destId, string _name="")
        {
            graph = _graph;
            Node sourceNode = null;
            Node destNode = null;

            foreach (var node in graph.nodes)
            {
                if (node.GetId() == sourceId && sourceNode == null)
                    sourceNode = node;
                if (node.GetId() == destId && destNode == null)
                    destNode = node;
            }

            if (sourceNode == null)
            {
                throw new Exception("Source Node " + sourceId.ToString() + " doesn't exists");
            }

            if (destNode == null)
            {
                throw new Exception("Dest Node " + destId.ToString() + " doesn't exists");
            }

            source = sourceNode;
            dest = destNode;
            name = _name;
            SetId(_id);
        }

        public Edge(Graph _graph, int _id, int sourceId, int destId)
        {
            EdgeCtor(_graph, _id, sourceId, destId);
        }

        public Edge(Graph _graph, int _id, int sourceId, int destId, string _name)
        {
            EdgeCtor(_graph, _id, sourceId, destId, _name);
        }

        public void SetId(int _id)
        {
            CheckId(_id);
            id = _id;
        }

        public int GetId()
        {
            return id;
        }

        public void Dump()
        {
            Console.WriteLine("{0} {1}: {2}({3}) -> {4}({5})", id, name, 
                source.GetId(), source.name, 
                dest.GetId(), dest.name);
        }
    }

    class Graph
    {
        public string name { get; set; } = "Graph " + Guid.NewGuid().ToString();
        public List<Node> nodes { get; set; } = new List<Node>();
        public List<Edge> edges { get; set; } = new List<Edge>();

        public Graph()
        {}

        public Graph(string _name)
        {
            name = _name;
        }

        /// <summary>
        /// Load graph from Yed graphml
        /// </summary>
        /// <param name="text"></param>
        public void FromGraphML (string text)
        {
            nodes.Clear();
            edges.Clear();

            XmlDocument doc = new XmlDocument();
            doc.LoadXml(text);

            // Find graph root 

            XmlNode graph = null;

            foreach (XmlNode node in doc.DocumentElement.ChildNodes)
            {
                if ( node.Name == "graph")
                {
                    graph = node;
                    break;
                }
            }

            if ( graph == null)
            {
                throw new Exception("Invalid format");
            }

            // Enumerate graph for nodes

            foreach (XmlNode entity in graph)
            {
                if ( entity.Name == "node")
                {
                    int id = Convert.ToInt32(entity.Attributes["id"].Value.Substring(1));

                    nodes.Add(new Node(this, id, GetYedNodeName(entity)));
                }
            }

            // Enumerate graph for edges

            foreach (XmlNode entity in graph)
            {
                if (entity.Name == "edge")
                {
                    int id = Convert.ToInt32(entity.Attributes["id"].Value.Substring(1));
                    int source = Convert.ToInt32(entity.Attributes["source"].Value.Substring(1));
                    int target = Convert.ToInt32(entity.Attributes["target"].Value.Substring(1));

                    edges.Add(new Edge(this, id, source, target, GetYedEdgeName(entity)));
                }
            }

        }

        private string GetYedNodeName (XmlNode parent)
        {
            foreach (XmlNode node in parent)
            {
                if ( node.Name == "data")
                {
                    if ( node.Attributes["key"].Value == "d6")
                    {
                        foreach (XmlNode inner in node)
                        {
                            if (inner.Name == "y:ShapeNode")
                            {
                                return inner.InnerText;
                            }
                        }

                    }
                }
            }
            return "";
        }

        private string GetYedEdgeName(XmlNode parent)
        {
            foreach (XmlNode node in parent)
            {
                if (node.Name == "data")
                {
                    if (node.Attributes["key"].Value == "d10")
                    {
                        XmlNode innerNode = node.ChildNodes[0];

                        foreach (XmlNode inner in innerNode)
                        {
                            if (inner.Name == "y:EdgeLabel")
                            {
                                return inner.InnerText;
                            }
                        }

                    }
                }
            }
            return "";
        }

        /// <summary>
        /// Keep walking graph until not stabilized.
        /// </summary>

        public virtual void Walk()
        {
            List<Node> inputNodes = GetInputNodes();

            ResetGraphWalk();

            int timeOut = 100;      // Should be enough to abort propagation since of auto-generation effects
            int walkCounter = 1;

            while (timeOut-- != 0)
            {
                Console.WriteLine("Walk: {0}", walkCounter);

                // Propagate inputs

                foreach (var node in inputNodes)
                {
                    node.Propagate();
                }

                // Check if need to propagate again

                bool again = false;

                foreach (var node in nodes)
                {
                    if (node.Value != null && node.OldValue != null && node.Value != node.OldValue)
                    {
                        if (node.Outputs().Count != 0)
                        {
                            Console.WriteLine("Node {0} {1} pending", node.GetId(), node.name);
                            again = true;
                        }
                    }
                }

                if (!again)
                    break;      // Stabilized

                walkCounter++;
            }

            if (walkCounter >= 100)
            {
                throw new Exception("Auto-Generation detected!");
            }

            Console.WriteLine("Completed in {0} iterations", walkCounter);
        }

        private void ResetGraphWalk()
        {
            foreach (var node in nodes)
            {
                node.Visited = false;
                node.OldValue = null;
            }
        }

        public void Dump()
        {
            Console.WriteLine("Graph: " + name);

            Console.WriteLine("Nodes:");
            foreach (var node in nodes)
                node.Dump();

            Console.WriteLine("Edges:");
            foreach (var edge in edges)
                edge.Dump();
        }

        public void DumpNodeValues()
        {
            Console.WriteLine("Graph: " + name);

            Console.WriteLine("Node values:");
            foreach (var node in nodes)
            {
                Console.WriteLine("node {0} {1} = {2}", node.GetId(), node.name, node.Value);
            }
        }

        public Node GetNodeByName (string name)
        {
            foreach (var node in nodes)
            {
                if (node.name == name)
                    return node;
            }
            return null;
        }

        /// <summary>
        /// Get all input pads
        /// </summary>
        /// <returns></returns>
        public List<Node> GetInputNodes ()
        {
            List<Node> list = new List<Node>();

            foreach (var node in nodes)
            {
                if ( node.Inputs().Count == 0 )
                {
                    list.Add(node);
                }
            }

            return list;
        }

        /// <summary>
        /// Get all output pads
        /// </summary>
        /// <returns></returns>
        public List<Node> GetOutputNodes()
        {
            List<Node> list = new List<Node>();

            foreach (var node in nodes)
            {
                if (node.Outputs().Count == 0)
                {
                    list.Add(node);
                }
            }

            return list;
        }

    }

}
