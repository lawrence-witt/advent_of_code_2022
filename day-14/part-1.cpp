#include <iostream>
#include "utils.h"

int main() {
    input i = get_input();
    look_result l;
    int total = 0;
    while((l = look_down(std::make_pair(500, 0), &i.second, 0)).first) {
        i.second[l.second.first][l.second.second] = true;
        total += 1;
    }
    std::cout << total;
    return 0;
}
