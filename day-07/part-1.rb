require_relative "utils"

root = Directory.new("/")
pointer = root
total = 0;

def conditional_sum(dir)
    sum = dir.get_sum
    if sum <= 100000
        return sum
    end
    return 0
end

File.readlines('input.txt').each do |line|
    if match = line.match(/^\$\scd\s(.+)$/)
        cmd = match.captures[0];
        if cmd == "/"
            # no-op
        elsif cmd == ".."
            total += conditional_sum(pointer)
            pointer = pointer.parent
        else
            pointer = pointer.dirs[cmd]
        end
    end
    if match = line.match(/^dir\s(.+)$/)
        dir = match.captures[0]
        pointer.dirs[dir] = Directory.new(dir, pointer)
    end
    if match = line.match(/^(\d+)\s(.+)$/)
        file = match.captures[1]
        pointer.files[file] = File.new(file, Integer(match.captures[0]))
    end
end

total += conditional_sum(pointer)

puts(total)