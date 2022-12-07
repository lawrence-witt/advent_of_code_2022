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