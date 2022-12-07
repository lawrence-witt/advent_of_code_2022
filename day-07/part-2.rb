require_relative "utils"

DISK_SPACE = 70000000
REQUIRED_SPACE = 30000000

root = Directory.new("/")
pointer = root
sized = Array.new

def insert_sized(size, sized)
    prev_length = sized.length
    for i in 0..prev_length-1
        if size < sized[i]
            sized.insert(i, size)
            break
        end
    end
    if prev_length == sized.length
        sized.push(size)
    end
end

File.readlines('input.txt').each do |line|
    if match = line.match(/^\$\scd\s(.+)$/)
        cmd = match.captures[0];
        if cmd == "/"
            # no-op
        elsif cmd == ".."
            insert_sized(pointer.get_sum, sized)
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

insert_sized(pointer.get_sum, sized)

TARGET_SPACE = REQUIRED_SPACE - (DISK_SPACE - root.get_sum)

for i in 0..sized.length-1
    if sized[i] > TARGET_SPACE
        puts(sized[i])
        break
    end
end