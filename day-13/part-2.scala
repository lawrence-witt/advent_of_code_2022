package part2

import scala.io.Source
import util.control.Breaks._
import solution.*

object Part2 {
    def main(args: Array[String]) = {
        val source = Source.fromFile("input.txt")
        var lines: List[String] = List("[[2]]", "[[6]]")
        var result = 1;
        for (line <- source.getLines())
            breakable {
                if (line == "") {
                    break
                }
                lines = line :: lines
            }
        val sorted = lines.sortWith((a: String, b: String) => {
            solve(a, b, 0) match
                case Result.Incorrect => false
                case _ => true
        })
        for (i <- 0 until sorted.length)
            breakable {
                sorted(i) match
                    case "[[2]]" => result *= (i + 1)
                    case "[[6]]" => {
                        result *= (i + 1)
                        break
                    }
                    case _ =>
            }
        println(result)
    }
}