class File
    attr_accessor :name
    attr_accessor :size

    def initialize(name, size)
        @name = name
        @size = size
    end
end

class Directory
    attr_accessor :name
    attr_accessor :parent
    attr_accessor :dirs
    attr_accessor :files

    def initialize(name, parent=nil)
        @name = name
        @parent = parent
        @dirs = Hash.new
        @files = Hash.new
        @sum = 0
    end

    def get_sum()
        if @sum != 0
            return @sum
        end
        @dirs.each { |key,dir| 
            @sum += dir.get_sum
        }
        @files.each { |key, file|
            @sum += file.size
        }
        return @sum
    end
end

def process_line(line, &callback)
    if match = line.match(/^\$\scd\s(.+)$/)
        cmd = match.captures[0];
        if cmd == "/"
            # no-op
        elsif cmd == ".."
            callback.call()
            $pointer = $pointer.parent
        else
            $pointer = $pointer.dirs[cmd]
        end
    end
    if match = line.match(/^dir\s(.+)$/)
        dir = match.captures[0]
        $pointer.dirs[dir] = Directory.new(dir, $pointer)
    end
    if match = line.match(/^(\d+)\s(.+)$/)
        file = match.captures[1]
        $pointer.files[file] = File.new(file, Integer(match.captures[0]))
    end
end