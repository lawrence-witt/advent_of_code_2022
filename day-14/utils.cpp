#include <fstream>
#include <map>
#include <unordered_map>
#include <regex>
#include "utils.h"

using rti = std::regex_token_iterator<std::string::iterator>;
using coords_vec = std::vector<coord>;

input get_input() {
    std::ifstream file("input.txt");
    std::regex expr("(\\d+,\\d+)");
    rti rend;
    coords_map c_map;
    int highest_y = 0;

    if (!file.is_open()) {
        return std::make_pair(highest_y, c_map);
    }

    std::string line;
    while (std::getline(file, line)) {
        rti match (line.begin(), line.end(), expr);
        coords_vec c_vec;
        while (match != rend) {
            std::string coord = *match++;
            int ci = coord.find(",");
            c_vec.push_back(std::make_pair(
                std::stoi(coord.substr(0, ci).c_str()), 
                std::stoi(coord.substr(ci + 1, coord.length()).c_str())
            ));
        }
        for(coords_vec::size_type i = 0; i != c_vec.size() - 1; i++) {
            int x_start = std::min(c_vec[i].first, c_vec[i+1].first);
            int x_end = std::max(c_vec[i].first, c_vec[i+1].first);
            int y_start = std::min(c_vec[i].second, c_vec[i+1].second);
            int y_end = std::max(c_vec[i].second, c_vec[i+1].second);
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

    return std::make_pair(highest_y, c_map);
}

look_result look_right(coord c, coords_map* c_map, look_result (*look_down)(coord, coords_map*, int), int floor) {
    coord next_coord = std::make_pair(c.first + 1, c.second + 1);
    if ((*c_map).count(next_coord.first) && (*c_map)[next_coord.first].count(next_coord.second)) {
        return std::make_pair(true, c);
    } else {
        return look_down(next_coord, c_map, floor);
    }
}

look_result look_left(coord c, coords_map* c_map, look_result (*look_down)(coord, coords_map*, int), int floor) {
    coord next_coord = std::make_pair(c.first - 1, c.second + 1);
    if ((*c_map).count(next_coord.first) && (*c_map)[next_coord.first].count(next_coord.second)) {
        return look_right(c, c_map, look_down, floor);
    } else {
        return look_down(next_coord, c_map, floor);
    }
}

look_result look_down(coord c, coords_map* c_map, int floor) {
    std::map<int, bool> y_points = (*c_map)[c.first];
    int next_y = -1;
    for (const auto &p : y_points) {
        if (floor > 0 && p.first == c.second) {
            return std::make_pair(false, c);
        } else if (p.first - 1 == c.second) {
            return look_left(c, c_map, &look_down, floor);
        } else if (p.first - 1 > c.second) {
            next_y = p.first - 1;
            break;
        }
    }
    if (next_y != -1) {
        return look_down(std::make_pair(c.first, next_y), c_map, floor);
    }
    if (floor > 0) {
        return std::make_pair(true, std::make_pair(c.first, floor - 1));
    } else {
        return std::make_pair(false, c);
    }
}