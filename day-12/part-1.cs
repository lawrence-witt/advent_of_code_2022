using System;
using System.IO;
using System.Collections.Generic;

namespace Part1 {
    class Node {
        public char c;
        public int height;
        public (int row, int col) coords;
        private int steps = 0;
        private bool visited = false;
        private Node parent;

        public Node(char _height, (int, int) _coords) {
            c = _height;
            if (_height == 'S') {
                height = 'a' - 1;
                visited = true;
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

        public void Visit(Node from) {
            steps = from.GetSteps() + 1;
            visited = true;
            parent = from;
        }

        public bool IsVisited() {
            return visited;
        }

        public bool IsStart() {
            return height == 'a' - 1;
        }

        public bool IsEnd() {
            return height == 'z' + 1;
        }

        public int GetSteps() {
            return steps;
        }

        public char GetSymbol() {
            if (!IsVisited()) {
                return '.';
            }
            if (parent == null) {
                return 'S';
            }
            if (IsEnd()) {
                return 'E';
            }
            if (parent.coords.row < coords.row) {
                return 'v';
            }
            if (parent.coords.row > coords.row) {
                return '^';
            }
            if (parent.coords.col < coords.col) {
                return '>';
            }
            return '<';
        }
    }
    class Script {
        static Node GetNextNeighbour(Node node, Node[,] nodes) {
            var (row, col) = node.coords;
            List<(Node, Node)> pending = new List<(Node, Node)>();
            if (row >= 1) {
                Node top = nodes[row - 1, col];
                if (!top.IsVisited() && top.IsReachable(node.height)) {
                    pending.Add((node, top));
                }
            }
            if (row < nodes.GetLength(0) - 1) {
                Node bottom = nodes[row + 1, col];
                if (!bottom.IsVisited() && bottom.IsReachable(node.height)) {
                    pending.Add((node, bottom));
                }
            }
            if (col >= 1) {
                Node left = nodes[row, col - 1];
                if (!left.IsVisited() && left.IsReachable(node.height)) {
                    pending.Add((node, left));
                }
            }
            if (col < nodes.GetLength(1) - 1) {
                Node right = nodes[row, col + 1];
                if (!right.IsVisited() && right.IsReachable(node.height)) {
                    pending.Add((node, right));
                }
            }
            if (pending.Count == 0) {
                return null;
            }
            var (_, next) = GetClosest(pending);
            return next;
        }

        static (Node, Node) GetClosest(List<(Node, Node)> nodes) {
            (Node from, Node next) result;
            foreach (var n in nodes) {
                if (result.next == null) {
                    result = n;
                } else if (result.next.GetSteps() > n.Item2.GetSteps()) {
                    result = n;
                }
            }
            return result;
        }

        static void Main(string[] args) {
            string[] lines = File.ReadAllText("input.txt").Split("\n");
            Node[,] nodes = new Node[lines.Length, lines[0].Length];
            (int row, int col) start = (0, 0);
            for (int i = 0; i < lines.Length; i++) {
                for (int j = 0; j < lines[0].Length; j++) {
                    Node n = new Node(lines[i][j], (i, j));
                    nodes[i,j] = n;
                    if (n.IsStart()) {
                        start = (i, j);
                    }
                }
            }
            List<Node> visited = new List<Node>(){nodes[start.Item1, start.Item2]};
            int result = 0;
            while (visited.Count > 0) {
                List<(Node, Node)> pending = new List<(Node, Node)>();
                for (int i = 0; i < visited.Count; i++) {
                    Node neighbour = GetNextNeighbour(visited[i], nodes);
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
                var (from, next) = GetClosest(pending);
                next.Visit(from);
                if (next.IsEnd()) {
                    result = next.GetSteps();
                    break;
                }
                visited.Add(next);
            }
            Console.WriteLine(result);
        }
    }
}