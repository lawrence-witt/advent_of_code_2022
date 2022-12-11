from pathlib import Path
import re
import operator
from monkey import Monkey

def operation_factory(operator, operand):
    return lambda x: operator(x, x if operand == 'old' else int(operand))

def division_factory(divisor, m1, m2):
    return lambda x: m1 if x % divisor == 0 else m2

file = Path('input.txt').read_text()
ops = {"+": operator.add, "*": operator.mul}

monkeys = []

for obj in file.split("\n\n"):
    fields = obj.split("\n")
    items = list(map(lambda x: int(x), re.findall(r"(\d+)", fields[1])))
    op_list = re.findall(r"([*|+])\s(\d+|old)", fields[2])
    operation = operation_factory(ops[op_list[0][0]], op_list[0][1])
    divisor = int(re.search(r"(\d+)", fields[3]).group(1))
    m1 = int(re.search(r"(\d+)", fields[4]).group(1))
    m2 = int(re.search(r"(\d+)", fields[5]).group(1))
    test = division_factory(divisor, m1, m2)
    monkeys.append(Monkey(items, operation, test))

for i in range(20):
    for j in range(len(monkeys)):
        monkeys[j].round(monkeys)

monkeys.sort(reverse=True, key=lambda x: x.inspections)

print(monkeys[0].inspections * monkeys[1].inspections)