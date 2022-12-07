require_relative "utils"

root = Directory.new("/")
$pointer = root
total = 0;

def conditional_sum(dir)
    sum = dir.get_sum
    if sum <= 100000
        return sum
    end
    return 0
end

File.readlines('input.txt').each do |line|
    process_line(line) { 
        total += conditional_sum($pointer)
    }
end

total += conditional_sum($pointer)

puts(total)