import operator

class Monkey:
    def __init__(self, items, operation, test):
        self.items = items
        self.operation = operation
        self.test = test
        self.inspections = 0

    def throw(self, item):
        self.items.append(item)

    def round(self, monkeys, lcm=None):
        while len(self.items) > 0:
            self.inspections += 1
            self.items[0] = self.operation(self.items[0])
            if lcm:
                self.items[0] %= lcm
            else:
                self.items[0] = operator.floordiv(self.items[0], 3)
            target = self.test(self.items[0])
            monkeys[target].throw(self.items.pop(0))