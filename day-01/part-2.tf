locals {
    reduced = [for i in split("\n\n", file("./input.txt")): sum([for j in split("\n", i): tonumber(j)])]
    first = max(local.reduced...)
    first_filtered = [for i in local.reduced: i if i != local.first]
    second = max(local.first_filtered...)
    second_filtered = [for i in local.first_filtered: i if i != local.second]
    third = max(local.second_filtered...)
}

output "part-2" {
    value = sum([local.first, local.second, local.third])
}