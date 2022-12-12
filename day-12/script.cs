using System;
using System.IO;
using System.Collections.Generic;

namespace Script {
    public class Solution {
        static Node GetNeighbour(Node node, int row, int col, Node[,] nodes, string context) {
            if (row >= 0 && col >= 0 && row < nodes.GetLength(0) && col < nodes.GetLength(1)) {
                Node neighbour = nodes[row, col];
                if (!neighbour.IsVisited(context) && neighbour.IsReachable(node.GetHeight())) {
                    return neighbour;
                }
            }
            return null;
        }

        static Node GetNextNeighbour(Node node, Node[,] nodes, string context) {
            var (row, col) = node.GetCoords();
            Node top = GetNeighbour(node, row - 1, col, nodes, context);
            Node bottom = GetNeighbour(node, row + 1, col, nodes, context);
            Node left = GetNeighbour(node, row, col - 1, nodes, context);
            Node right = GetNeighbour(node, row, col + 1, nodes, context);
            List<(Node, Node)> pending = new List<(Node, Node)>{(node, top), (node, bottom), (node, left), (node, right)};
            var result = GetClosest(pending, context);
            return result.Item2;
        }

        static (Node, Node) GetClosest(List<(Node, Node)> nodes, string context) {
            (Node from, Node next) result;
            foreach ((Node from, Node next) n in nodes) {
                if (result.next == null && n.next != null) {
                    result = (n.from, n.next);
                } else if (n.next == null) {
                    continue;
                } else if (result.next.GetSteps(context) > n.next.GetSteps(context)) {
                    result = (n.from, n.next);
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
                    if (args[0] == "1" && lines[i][j] == 'S') {
                        start_points.Add((i, j));
                    } else if (args[0] == "2" && n.IsLowPoint()) {
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