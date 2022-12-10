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
    int total = 0;

    while (fgets(buffer, BUFFER_LEN, file_pointer)) {
        buffer[strcspn(buffer, "\n")] = 0;
        regmatch_t groups[1];
        if (regexec(&expr, buffer, 1, groups, 0) == 0) {
            int i = atoi(buffer + groups[0].rm_so);
            cycles++;
            total += signal_product(cycles, x);
            cycles++;
            total += signal_product(cycles, x);
            x += i;
        } else {
            cycles++;
            total += signal_product(cycles, x);
        }
    }

    printf("%i", total);

    regfree(&expr);
    fclose(file_pointer);
    return 0;
}