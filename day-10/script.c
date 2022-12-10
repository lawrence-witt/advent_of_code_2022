#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <regex.h>

#define BUFFER_LEN 256

int signal_product(int cycles, int x) {
    if (cycles == 20 || (cycles >= 60 && cycles <= 220 && (cycles - 20) % 40 == 0)) {
        return cycles * x;
    }
    return 0;
}

void assign_pixel(int cycles, int x, char display[6][40]) {
    int row = cycles % 40;
    int col = cycles - (row * 40);
    if (row >= x - 1 && row <= x + 1) {
        display[row][col] = '#';
    } else {
        display[row][col] = '.';
    }
}

void cycle(int * cycles, int x, int * signal_total, char display[6][40]) {
    assign_pixel(*cycles, x, display);
    *cycles = *cycles + 1;
    *signal_total += signal_product(*cycles, x);
}

int main(int argc, char **argv) {
    FILE* file_pointer;
    char buffer[BUFFER_LEN];

    file_pointer = fopen("input.txt", "r");
    if (file_pointer == NULL) {
        return 1;
    }

    char * expr_string = "(-?[0-9]+)";
    regex_t expr;

    if (regcomp(&expr, expr_string, REG_EXTENDED)) {
        printf("Could not compile regular expression\n");
        return 1;
    }
    
    int cycles = 0;
    int x = 1;
    int signal_total = 0;
    char display[6][40];

    while (fgets(buffer, BUFFER_LEN, file_pointer)) {
        buffer[strcspn(buffer, "\n")] = 0;
        regmatch_t groups[1];
        if (regexec(&expr, buffer, 1, groups, 0) == 0) {
            int i = atoi(buffer + groups[0].rm_so);
            cycle(&cycles, x, &signal_total, display);
            cycle(&cycles, x, &signal_total, display);
            x += i;
        } else {
            cycle(&cycles, x, &signal_total, display);
        }
    }

    if (*argv[1] == '1') {
        printf("%i", signal_total);
    }
    
    if (*argv[1] == '2') {
        for (int i = 0; i < 6; i++) {
            for (int j = 0; j < 40; j++) {
                char c = display[i][j];
                putchar(c);
            }
            printf("\n");
        }
    }

    regfree(&expr);
    fclose(file_pointer);
    return 0;
}