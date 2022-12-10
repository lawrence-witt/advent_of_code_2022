#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <regex.h>

#define BUFFER_LEN 256

int main() {
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
    char display[6][40] = {};
    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 40; j++) {
            display[i][j] = 'N';
        }
    }

    while (fgets(buffer, BUFFER_LEN, file_pointer)) {
        buffer[strcspn(buffer, "\n")] = 0;
        regmatch_t groups[1];
        if (regexec(&expr, buffer, 1, groups, 0) == 0) {
            int i = atoi(buffer + groups[0].rm_so);
            int row = cycles % 40;
            int col = cycles - (row * 40);
            if (row >= x - 1 && row <= x + 1) {
                display[row][col] = '#';
            } else {
                display[row][col] = '.';
            }
            cycles++;
            row = cycles % 40;
            col = cycles - (row * 40);
            if (row >= x - 1 && row <= x + 1) {
                display[row][col] = '#';
            } else {
                display[row][col] = '.';
            }
            cycles++;
            x += i;
        } else {
            int row = cycles % 40;
            int col = cycles - (row * 40);
            if (row >= x - 1 && row <= x + 1) {
                display[row][col] = '#';
            } else {
                display[row][col] = '.';
            }
            cycles++;
        }
    }

    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 40; j++) {
            char c = display[i][j];
            putchar(c);
        }
        printf("\n");
    }

    regfree(&expr);
    fclose(file_pointer);
    return 0;
}