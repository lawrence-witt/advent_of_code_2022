from pathlib import Path
import sys
import re
import operator
import math
from monkey import Monkey

def operation_factory(operator, operand):
    return lambda x: operator(x, x if operand == 'old' else int(operand))

def division_factory(divisor, m1, m2):
    return lambda x: m1 if x % divisor == 0 else m2

def parse_digits(string):
    return int(re.search(r"(\d+)", string).group(1))

file = Path('input.txt').read_text()
ops = {"+": operator.add, "*": operator.mul}

monkeys = []
divisors = []

for obj in file.split("\n\n"):
    fields = obj.split("\n")
    items = list(map(lambda x: int(x), re.findall(r"(\d+)", fields[1])))
    op_list = re.findall(r"([*|+])\s(\d+|old)", fields[2])
    operation = operation_factory(ops[op_list[0][0]], op_list[0][1])
    divisor = parse_digits(fields[3])
    test = division_factory(divisor, parse_digits(fields[4]), parse_digits(fields[5]))
    monkeys.append(Monkey(items, operation, test))
    divisors.append(divisor)

rounds = 20 if sys.argv[1] == "1" else 10000
lcm = None if sys.argv[1] == "1" else math.lcm(*divisors)

for i in range(rounds):
    for m in monkeys:
        m.round(monkeys, lcm)

monkeys.sort(reverse=True, key=lambda x: x.inspections)

print(monkeys[0].inspections * monkeys[1].inspections)