package part1

import scala.io.Source
import util.control.Breaks._
import solution.*

object Part1 {
    def main(args: Array[String]) = {
        val source = Source.fromFile("input.txt")
        var index = 0
        var score = 0
        var left = ""
        for (line <- source.getLines())
            breakable {
                if (line == "") {
                    left = ""
                    break
                }
                if (left == "") {
                    left = line
                    break
                }
                index += 1
                solve(left, line, 0) match
                    case Result.Correct => score += index
                    case _ => break
                left = ""
            }
        println(score)
    }
}