#include <iostream>
#include "utils.h"

int main() {
    Input i = get_input();
    Output o;
    int total = 0;
    while((o = look_down(Coord{500, 0}, &i.map, 0)).proceed) {
        i.map[o.coord.x][o.coord.y] = true;
        total += 1;
    }
    std::cout << total;
    return 0;
}
