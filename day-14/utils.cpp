#include <fstream>
#include <map>
#include <unordered_map>
#include <regex>
#include "utils.h"

using rti = std::regex_token_iterator<std::string::iterator>;
using coords_vec = std::vector<Coord>;

Input get_input() {
    std::ifstream file("input.txt");
    std::regex expr("(\\d+,\\d+)");
    rti rend;
    coords_map c_map;
    int highest_y = 0;

    if (!file.is_open()) {
        return Input{highest_y, c_map};
    }

    std::string line;
    while (std::getline(file, line)) {
        rti match (line.begin(), line.end(), expr);
        coords_vec c_vec;
        while (match != rend) {
            std::string coord = *match++;
            int ci = coord.find(",");
            c_vec.push_back(Coord{
                std::stoi(coord.substr(0, ci).c_str()), 
                std::stoi(coord.substr(ci + 1, coord.length()).c_str())
            });
        }
        for(coords_vec::size_type i = 0; i != c_vec.size() - 1; i++) {
            int x_start = std::min(c_vec[i].x, c_vec[i+1].x);
            int x_end = std::max(c_vec[i].x, c_vec[i+1].x);
            int y_start = std::min(c_vec[i].y, c_vec[i+1].y);
            int y_end = std::max(c_vec[i].y, c_vec[i+1].y);
            for(int i = x_start; i <= x_end; i++) {
                for (int j = y_start; j <= y_end; j++) {
                    c_map[i][j] = true;
                    if (j > highest_y) {
                        highest_y = j;
                    }
                }
            }
        }
    }

    return Input{highest_y, c_map};
}

Output look_right(Coord c, coords_map* c_map, Output (*look_down)(Coord, coords_map*, int), int floor) {
    Coord next_coord = Coord{c.x + 1, c.y + 1};
    if ((*c_map).count(next_coord.x) && (*c_map)[next_coord.x].count(next_coord.y)) {
        return Output{true, c};
    } else {
        return look_down(next_coord, c_map, floor);
    }
}

Output look_left(Coord c, coords_map* c_map, Output (*look_down)(Coord, coords_map*, int), int floor) {
    Coord next_coord = Coord{c.x - 1, c.y + 1};
    if ((*c_map).count(next_coord.x) && (*c_map)[next_coord.x].count(next_coord.y)) {
        return look_right(c, c_map, look_down, floor);
    } else {
        return look_down(next_coord, c_map, floor);
    }
}

Output look_down(Coord c, coords_map* c_map, int floor) {
    for (const auto &y_kv : (*c_map)[c.x]) {
        if (floor > 0 && y_kv.first == c.y) {
            return Output{false, c};
        } else if (y_kv.first - 1 == c.y) {
            return look_left(c, c_map, &look_down, floor);
        } else if (y_kv.first - 1 > c.y) {
            return look_down(Coord{c.x, y_kv.first - 1}, c_map, floor);
        }
    }
    if (floor > 0) {
        return Output{true, Coord{c.x, floor - 1}};
    } else {
        return Output{false, c};
    }
}