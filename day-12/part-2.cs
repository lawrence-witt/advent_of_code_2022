using System;
using System.IO;
using System.Collections.Generic;

namespace Part2 {
    class Node {
        public int height;
        public (int row, int col) coords;
        private Dictionary<string, int> steps = new Dictionary<string, int>();
        private Dictionary<string, bool> visited = new Dictionary<string, bool>();

        public Node(char _height, (int, int) _coords) {
            if (_height == 'S') {
                height = 'a';
            } else if (_height == 'E') {
                height = 'z' + 1;
            } else {
                height = _height;
            }
            coords = _coords;
        }

        public bool IsReachable(int current) {
            return height <= current + 1;
        }

        public void Visit(Node from, string context) {
            if (from == null) {
                steps[context] = 0;
            } else {
                steps[context] = from.GetSteps(context) + 1;
            }
            visited[context] = true;
        }

        public bool IsVisited(string context) {
            if (!visited.ContainsKey(context)) {
                return false;
            }
            return visited[context];
        }

        public bool IsLowPoint() {
            return height == 'a';
        }

        public bool IsEnd() {
            return height == 'z' + 1;
        }

        public int GetSteps(string context) {
            if (!steps.ContainsKey(context)) {
                return 0;
            }
            return steps[context];
        }
    }
    class Script {
        static Node GetNextNeighbour(Node node, Node[,] nodes, string context) {
            var (row, col) = node.coords;
            List<(Node, Node)> pending = new List<(Node, Node)>();
            if (row >= 1) {
                Node top = nodes[row - 1, col];
                if (!top.IsVisited(context) && top.IsReachable(node.height)) {
                    pending.Add((node, top));
                }
            }
            if (row < nodes.GetLength(0) - 1) {
                Node bottom = nodes[row + 1, col];
                if (!bottom.IsVisited(context) && bottom.IsReachable(node.height)) {
                    pending.Add((node, bottom));
                }
            }
            if (col >= 1) {
                Node left = nodes[row, col - 1];
                if (!left.IsVisited(context) && left.IsReachable(node.height)) {
                    pending.Add((node, left));
                }
            }
            if (col < nodes.GetLength(1) - 1) {
                Node right = nodes[row, col + 1];
                if (!right.IsVisited(context) && right.IsReachable(node.height)) {
                    pending.Add((node, right));
                }
            }
            if (pending.Count == 0) {
                return null;
            }
            var (_, next) = GetClosest(pending, context);
            return next;
        }

        static (Node, Node) GetClosest(List<(Node, Node)> nodes, string context) {
            (Node from, Node next) result;
            foreach (var n in nodes) {
                if (result.next == null) {
                    result = n;
                } else if (result.next.GetSteps(context) > n.Item2.GetSteps(context)) {
                    result = n;
                }
            }
            return result;
        }

        static void Main(string[] args) {
            string[] lines = File.ReadAllText("input.txt").Split("\n");
            Node[,] nodes = new Node[lines.Length, lines[0].Length];
            List<(int row, int col)> start_points = new List<(int, int)>();
            for (int i = 0; i < lines.Length; i++) {
                for (int j = 0; j < lines[0].Length; j++) {
                    Node n = new Node(lines[i][j], (i, j));
                    nodes[i,j] = n;
                    if (n.IsLowPoint()) {
                        start_points.Add((i, j));
                    }
                }
            }
            int lowest = int.MaxValue;
            foreach (var s in start_points) {
                string context = $"{s.row} {s.col}";
                Node initial = nodes[s.row, s.col];
                initial.Visit(null, context);
                List<Node> visited = new List<Node>(){initial};
                int result = int.MaxValue;
                while (visited.Count > 0) {
                    List<(Node, Node)> pending = new List<(Node, Node)>();
                    for (int i = 0; i < visited.Count; i++) {
                        Node neighbour = GetNextNeighbour(visited[i], nodes, context);
                        if (neighbour == null) {
                            visited.RemoveAt(i);
                            i--;
                            continue;
                        }
                        pending.Add((visited[i], neighbour));
                    }
                    if (pending.Count == 0) {
                        break;
                    }
                    var (from, next) = GetClosest(pending, context);
                    next.Visit(from, context);
                    if (next.IsEnd()) {
                        result = next.GetSteps(context);
                        break;
                    }
                    visited.Add(next);
                }
                if (result < lowest) {
                    lowest = result;
                }
            }
            Console.WriteLine(lowest);
        }
    }
}