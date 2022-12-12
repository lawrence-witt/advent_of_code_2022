using System.Collections.Generic;

namespace Script {
    public class Node {
        private int height;
        private (int row, int col) coords;
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

        public void Visit(Node from, string context) {
            if (from == null) {
                steps[context] = 0;
            } else {
                steps[context] = from.GetSteps(context) + 1;
            }
            visited[context] = true;
        }
        
        public bool IsReachable(int current) {
            return height <= current + 1;
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

        public int GetHeight() {
            return height;
        }

        public (int, int) GetCoords() {
            return coords;
        }

        public int GetSteps(string context) {
            if (!steps.ContainsKey(context)) {
                return 0;
            }
            return steps[context];
        }
    }
}