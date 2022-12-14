#ifndef UTILS
#define UTILS

#include <fstream>
#include <map>
#include <unordered_map>

using coord = std::pair<int, int>;
using coords_map = std::unordered_map<int, std::map<int, bool> >;
using input = std::pair<int, coords_map>;
using look_result = std::pair<bool, coord>;

input get_input();
look_result look_down(coord, coords_map*, int);

#endif