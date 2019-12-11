/// Basic graph framework

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Drawing;
using System.Globalization;

using System.Xml;
using CanvasControl;

namespace GraphFlow
{

    public class Node
    {
        private int id { get; set; } = -1;
        public string name { get; set; } = "";
        public Graph graph;
        public bool Visited { get; set; } = false;
        public CanvasItem Item = null;    // Associate with someting to draw

        private int? NewValue = null;
        public int? Value
        {
            get { return NewValue; }
            set
            {
                OldValue = NewValue;
                NewValue = value;

                if (Item != null)
                {
                    if (value != null)
                    {
                        Item.BorderColor = (value == 0) ? Color.ForestGreen : Color.Chartreuse;      // 0 / 1
                    }
                    else
                    {
                        Item.BorderColor = Color.DodgerBlue;  // z
                    }
                }
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
                    Console.Write(" {0}", edge.name == "" ? "<empty>" : edge.name);
                }
            }

            List<Edge> outputs = Outputs();

            if (outputs.Count != 0)
            {
                Console.Write(", outputs:");

                foreach (var edge in outputs)
                {
                    Console.Write(" {0}", edge.name == "" ? "<empty>" : edge.name);
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
            List<Edge> outputs = new List<Edge>();

            foreach (var edge in graph.edges)
            {
                if (edge.source == this)
                {
                    outputs.Add(edge);
                }
            }

            return outputs;
        }

        public void Propagate()
        {
            // TODO: Slice propagation onto Node instance sub-classes (Node::Fet::Propagate, Node::Power::Propagate etc.)
            if (name == "1")
            {
                // Power

                Value = 1;
            }
            else if (name == "0")
            {
                // Ground

                Value = 0;
            }
            else if (name.Contains("nfet") || name.Contains("pfet"))
            {
                // Fets

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
                    throw new Exception("Specify source to fet");
                }

                if (gate == null)
                {
                    throw new Exception("Specify gate to fet");
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
                    // Keep value as D-latch
                    // TODO: Add decay parameter?

                    Value = Value;
                }
            }
            else
            {
                // Vias (connection)

                int? value = null;
                List<Edge> inputs = Inputs();

                if (inputs.Count() == 0)
                {
                    // Do not propagate disconnected inputs

                    if (Value == null)
                        return;

                    // Get value from input pad

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

#if DEBUG
            Console.WriteLine("Propagated node {0} {1}, value={2}, oldValue={3}", id, name, Value, OldValue);
#endif

            if (Value != null )
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

        public Node Clone(Graph _graph)
        {
            Node node = new Node(_graph);

            node.name = name;
            node.SetId(GetId());
            node.Value = Value;
            node.OldValue = OldValue;
            node.Item = null;

            return node;
        }

    }

    public class Edge
    {
        public string name { get; set; } = "";
        public Node source { get; set; } = null;
        public Node dest { get; set; } = null;
        public int sourceId { get; set; } = -1;
        public int destId { get; set; } = -1;

        public Graph graph;
        public CanvasItem Item = null;    // Associate with someting to draw

        private int? NewValue = null;
        public int? Value
        {
            get { return NewValue; }
            set
            {
                OldValue = NewValue;
                NewValue = value;

                if (Item != null)
                {
                    if (value != null)
                    {
                        Item.FrontColor = (value == 0) ? Color.ForestGreen : Color.Chartreuse;      // 0 / 1
                    }
                    else
                    {
                        Item.FrontColor = Color.DodgerBlue;  // z
                    }
                }
            }
        }  // Associated value
        public int? OldValue = null;    // Used to keep track of propagation changes

        public Edge(Graph _graph)
        {
            graph = _graph;
        }

        private void EdgeCtor(Graph _graph, int _sourceId, int _destId, string _name="")
        {
            graph = _graph;
            Node sourceNode = null;
            Node destNode = null;

            sourceId = _sourceId;
            destId = _destId;

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
        }

        public Edge(Graph _graph, int sourceId, int destId)
        {
            EdgeCtor(_graph, sourceId, destId);
        }

        public Edge(Graph _graph, int sourceId, int destId, string _name)
        {
            EdgeCtor(_graph, sourceId, destId, _name);
        }

        public void Dump()
        {
            Console.WriteLine("{0}: {1}({2}) -> {3}({4})", 
                name == "" ? "<empty>" : name,
                source.name, source.GetId(),
                dest.name, dest.GetId());
        }

        public Edge Clone(Graph _graph)
        {
            Edge edge = new Edge(_graph, sourceId, destId);

            edge.name = name;
            edge.Value = Value;
            edge.OldValue = OldValue;
            edge.Item = null;

            return edge;
        }
    }

    public class Graph
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

                    Node node = new Node(this, id, GetYedNodeName(entity));

                    node.Item = GetYedNodeShape(entity, node);
                    node.Item.Text = node.name;
                    node.Item.UserData = node;

                    nodes.Add(node);
                }
            }

            // Enumerate graph for edges

            foreach (XmlNode entity in graph)
            {
                if (entity.Name == "edge")
                {
                    int source = Convert.ToInt32(entity.Attributes["source"].Value.Substring(1));
                    int target = Convert.ToInt32(entity.Attributes["target"].Value.Substring(1));

                    Edge edge = new Edge(this, source, target, GetYedEdgeName(entity));

                    edge.Item = GetYedEdgeShape(entity, edge);
                    edge.Item.Text = edge.name;
                    edge.Item.UserData = edge;

                    edges.Add(edge);
                }
            }

            Reset();
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

        private CanvasItem GetYedNodeShape(XmlNode parent, Node node)
        {
            PointF pos = new PointF(0,0);
            int width = 100;
            int height = 100;
            Color color = Color.Gold;

            bool found = false;
            string type = "rectangle";

            foreach (XmlNode xmlNode in parent)
            {
                if (xmlNode.Name == "data")
                {
                    if (xmlNode.Attributes["key"].Value == "d6")
                    {
                        foreach (XmlNode inner in xmlNode)
                        {
                            if (inner.Name == "y:ShapeNode")
                            {
                                foreach (XmlNode props in inner)
                                {
                                    if (props.Name == "y:Geometry")
                                    {
                                        width = (int)float.Parse(props.Attributes["width"].Value, CultureInfo.InvariantCulture);
                                        height = (int)float.Parse(props.Attributes["height"].Value, CultureInfo.InvariantCulture);
                                        float x = float.Parse(props.Attributes["x"].Value, CultureInfo.InvariantCulture);
                                        float y = float.Parse(props.Attributes["y"].Value, CultureInfo.InvariantCulture);

                                        pos = new PointF(x, y);

                                        found = true;
                                    }

                                    if (props.Name == "y:Fill")
                                    {
                                        color = StringToColor(props.Attributes["color"].Value);
                                    }

                                    if (props.Name == "y:Shape")
                                    {
                                        type = props.Attributes["type"].Value;
                                    }
                                }
                            }
                        }

                    }
                }
            }

            if (found)
            {
                CanvasItem item;

                switch (type)
                {
                    case "ellipse":
                        item = new CanvasPoint(pos, width, color);
                        break;

                    default:
                        item = new CanvasRect(pos, width, height, color);
                        break;
                }

                item.BorderWidth = 2;

                return item;
            }

            return null;
        }

        public static Color StringToColor(string text)
        {
            if (text[0] == '#')
            {
                char[] rchars = { text[1], text[2] };
                int r = Convert.ToInt32(new string(rchars), 16);

                char[] gchars = { text[3], text[4] };
                int g = Convert.ToInt32(new string(gchars), 16);

                char[] bchars = { text[5], text[6] };
                int b = Convert.ToInt32(new string(bchars), 16);

                return Color.FromArgb(255, r, g, b);
            }
            else return Color.Black;
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

                        if (innerNode.Name != "y:PolyLineEdge")
                        {
                            throw new Exception("Wrong edge format!");
                        }

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

        private CanvasItem GetYedEdgeShape(XmlNode parent, Edge edge)
        {
            List<PointF> points = new List<PointF>();

            // Add start node center as polyline start points

            Node startNode = edge.source;

            CanvasItem startItem = startNode.Item;

            float sx = startItem.Pos.X;
            float sy = startItem.Pos.Y;

            if (startItem is CanvasRect)
            {
                sx += startItem.Width / 2;
                sy += startItem.Height / 2;
            }

            points.Add(new PointF(sx, sy));

            // Add path

            foreach (XmlNode node in parent)
            {
                if (node.Name == "data")
                {
                    if (node.Attributes["key"].Value == "d10")
                    {
                        XmlNode innerNode = node.ChildNodes[0];

                        if (innerNode.Name != "y:PolyLineEdge")
                        {
                            throw new Exception("Wrong edge format!");
                        }

                        foreach (XmlNode inner in innerNode)
                        {
                            if (inner.Name == "y:Path")
                            {
                                foreach (XmlNode point in inner)
                                {
                                    float x = float.Parse(point.Attributes["x"].Value, CultureInfo.InvariantCulture) - startItem.Width / 2;
                                    float y = float.Parse(point.Attributes["y"].Value, CultureInfo.InvariantCulture) - startItem.Height / 2;

                                    if (startItem is CanvasRect)
                                    {
                                        x += startItem.Width / 2;
                                        y += startItem.Height / 2;
                                    }

                                    points.Add(new PointF(x, y));
                                }
                            }
                        }

                    }
                }
            }

            // Add end node center as polyline end point

            Node destNode = edge.dest;

            CanvasItem destItem = destNode.Item;

            float dx = destItem.Pos.X;
            float dy = destItem.Pos.Y;

            if (destItem is CanvasRect)
            {
                dx += destItem.Width / 2;
                dy += destItem.Height / 2;
            }

            points.Add(new PointF(dx, dy));

            return new CanvasPolyLine(points, 1, Color.Black);
        }

        /// <summary>
        /// Keep walking graph until not stabilized.
        /// </summary>

        public virtual void Walk()
        {
            List<Node> inputNodes = GetInputNodes();

            GraphWalkPrepare();

            int timeOut = 100;      // Should be enough to abort propagation since of auto-generation effects
            int walkCounter = 1;

            while (timeOut-- != 0)
            {
#if DEBUG
                Console.WriteLine("Walk: {0}", walkCounter);
#endif

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
#if DEBUG
                            Console.WriteLine("Node {0} {1} pending", node.GetId(), node.name);
#endif
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

#if DEBUG
            Console.WriteLine("Completed in {0} iterations", walkCounter);
#endif
        }

        private void GraphWalkPrepare()
        {
            foreach (var edge in edges)
            {
                // Do not clear floating gate value

                if (edge.name.Contains("g"))
                {
                    if (edge.dest.name.Contains("nfet") || edge.dest.name.Contains("pfet"))
                    {
                        List<Edge> sourceInputs = edge.source.Inputs();

                        if (sourceInputs.Count == 1)
                        {
                            string sourceSourceName = sourceInputs[0].source.name;

                            if (sourceInputs[0].Value == null)
                            {
                                continue;
                            }
                        }
                    }
                }

                edge.Value = null;
                edge.OldValue = null;
            }

            foreach (var node in nodes)
            {
                node.Visited = false;

                if ( node.Inputs().Count() == 0)
                {
                    // Do not touch input pads, except power/ground

                    if (node.name == "1" || node.name == "0" )
                    {
                        node.Value = null;
                    }
                }
                else
                {
                    node.Value = null;
                }

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
        public List<Node> GetInputNodes (bool excludePowerGround = false)
        {
            List<Node> list = new List<Node>();

            foreach (var node in nodes)
            {
                if ( node.Inputs().Count == 0 )
                {
                    if (excludePowerGround)
                    {
                        if (node.name == "0" || node.name == "1")
                            continue;
                    }

                    list.Add(node);
                }
            }

            return list;
        }

        /// <summary>
        /// Get all outputs pads
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

        /// <summary>
        /// Reset graph state
        /// </summary>

        public void Reset()
        {
            foreach(var node in nodes)
            {
                node.Value = 0;
                node.OldValue = 0;
            }
            foreach(var edge in edges)
            {
                edge.Value = 0;
                edge.OldValue = 0;
            }
        }

        /// <summary>
        /// Clone graph
        /// </summary>
        /// <returns></returns>
        public Graph Clone()
        {
            Graph graph = new Graph(name);

            foreach (var node in nodes)
            {
                graph.nodes.Add(node.Clone(graph));
            }

            foreach (var edge in edges)
            {
                graph.edges.Add(edge.Clone(graph));
            }

            return graph;
        }

        /// <summary>
        /// Resolve Xrefs
        /// </summary>
        /// <param name="existing"></param>

        public void ResolveXrefs (List<Graph> existing)
        {
            // Existing graphs nodes

            foreach ( var g in existing)
            {
                bool again = false;

                do
                {
                    again = false;

                    foreach (Node node in g.nodes)
                    {
                        if (node.name == name)
                        {
                            LinkGraphNode(this, node);
                            node.name = "_" + node.name + "_";
                            again = true;
                            break;
                        }
                    }
                } while (again);
            }

            // This graph nodes

            foreach (Node node in nodes)
            {
                foreach (var g in existing)
                {
                    if ( node.name == g.name)
                    {
                        LinkGraphNode(g, node);
                        break;
                    }
                }
            }
        }

        private void LinkGraphNode (Graph sourceGraph, Node targetNode)
        {
            Console.WriteLine("Link graph {0} with node {1}", sourceGraph.name, targetNode.name);

            Graph subGraph = targetNode.graph.Add(sourceGraph);

            // Inputs

            List<Node> inputPads = subGraph.GetInputNodes(true);
            List<Edge> inputEdges = targetNode.Inputs();

            if (inputPads.Count == 1 && inputEdges.Count == 1)
            {
                inputEdges[0].dest = inputPads[0];
            }
            else
            {
                foreach (Edge edge in inputEdges)
                {
                    if (edge.name == "")
                    {
                        throw new Exception("Edge name empty!");
                    }

                    foreach (Node node in inputPads)
                    {
                        if (edge.name == node.name)
                        {
                            edge.dest = node;
                        }
                    }
                }
            }

            // Outputs

            List<Node> outputPads = subGraph.GetOutputNodes();
            List<Edge> outputEdges = targetNode.Outputs();

            if (outputPads.Count == 1 && outputEdges.Count == 1)
            {
                outputEdges[0].source = outputPads[0];
            }
            else
            {
                foreach (Edge edge in outputEdges)
                {
                    if (edge.name == "")
                    {
                        throw new Exception("Edge name empty!");
                    }

                    foreach (Node node in outputPads)
                    {
                        if (edge.name == node.name)
                        {
                            edge.source = node;
                        }
                    }
                }
            }

        }

        /// <summary>
        /// Concatenate another graph to this.
        /// </summary>
        /// <param name="graph"></param>
        /// <returns>Concatenated Subgraph</returns>

        public Graph Add(Graph graph)
        {
            Graph subGraph = new Graph(graph.name);

            int maxId = nodes.Max(x => x.GetId()) + 1;

            foreach ( Node node in graph.nodes)
            {
                Node clone = new Node(this, maxId + node.GetId(), node.name);
                nodes.Add(clone);
                subGraph.nodes.Add(clone);
            }

            foreach (Edge edge in graph.edges)
            {
                Edge clone = new Edge(this, maxId + edge.sourceId, maxId + edge.destId, edge.name);
                edges.Add(clone);
                subGraph.edges.Add(clone);
            }

            return subGraph;
        }

    }

}
