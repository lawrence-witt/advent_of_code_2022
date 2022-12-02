locals {
    result = max([for i in split("\n\n", file("./input.txt")): sum([for j in split("\n", i): tonumber(j)])]...)
}

output "part-1" {
    value = local.result
}