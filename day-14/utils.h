#ifndef UTILS
#define UTILS

#include <fstream>
#include <map>
#include <unordered_map>

using coords_map = std::unordered_map<int, std::map<int, bool> >;

struct Coord {int x; int y;};
struct Input {int highest_y; coords_map map;};
struct Output {bool proceed; Coord coord;};

Input get_input();
Output look_down(Coord, coords_map*, int);

#endif