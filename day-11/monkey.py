import math

class Monkey:
    def __init__(self, items, operation, test):
        self.items = items
        self.operation = operation
        self.test = test
        self.inspections = 0

    def throw(self, item):
        self.items.append(item)

    def inspect(self):
        self.inspections += 1
        self.items[0] = math.floor(self.operation(self.items[0]) / 3)

    def round(self, monkeys):
        while len(self.items) > 0:
            self.inspect()
            target = self.test(self.items[0])
            monkeys[target].throw(self.items.pop(0))