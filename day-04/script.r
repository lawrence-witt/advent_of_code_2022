args = commandArgs(trailingOnly=TRUE)
con = file("input.txt", "r")
count = 0
while (TRUE) {
    line = readLines(con, n = 1)
    if (length(line) == 0) {
        break
    }
    values = as.list(regmatches(line, regexec("(\\d+)-(\\d+),(\\d+)-(\\d+)", line))[[1]])
    a_1 = strtoi(values[2])
    a_2 = strtoi(values[3])
    b_1 = strtoi(values[4])
    b_2 = strtoi(values[5])
    if (args[1] == "1" && ((a_1 >= b_1 && a_2 <= b_2) || (b_1 >= a_1 && b_2 <= a_2))) {
        count = count + 1
    } else if (args[1] == "2" && a_2 >= b_1 && a_1 <= b_2) {
        count = count + 1
    }
}
print(count)
close(con)