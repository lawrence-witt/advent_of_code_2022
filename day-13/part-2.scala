import scala.io.Source
import util.control.Breaks._

enum Result:
    case Correct, Incorrect, Equal

object Part2 {
    def subList(source: String): String = {
        val start = source.indexOf('[')
        var depth = 0
        var i = start + 1
        while (i < source.length()) {
            val c = source(i)
            if (c == '[') {
                depth += 1
            } else if (c == ']') {
                if (depth == 0) {
                    return source.slice(start + 1, i)
                }
                depth -= 1
            }
            i += 1
        }
        return ""
    }

    def truncList(source: String): String = {
        val start = source.indexOf('[')
        var depth = 0
        var i = start + 1
        while (i < source.length()) {
            val c = source(i)
            if (c == '[') {
                depth += 1
            } else if (c == ']') {
                if (depth == 0) {
                    return s"${source.slice(0, start)}${source.slice(i + 1, source.length())}"
                }
                depth -= 1
            }
            i += 1
        }
        return ""
    }

    def truncInt(source: String, offset: Int): (Int, String) = {
        val expr = "(\\d+)"
        val slice = source.slice(offset, source.length())
        expr.r.findFirstIn(slice) match
            case Some(i) => (i.toInt, s"${source.slice(0, offset)}${slice.replaceFirst(expr, "")}")
            case None => (0, source)
    }

    def encloseInt(source: String, offset: Int): String = {
        val expr = "(\\d+)"
        val slice = source.slice(offset, source.length())
        expr.r.findFirstIn(slice) match
            case Some(i) => s"${source.slice(0, offset)}${slice.replaceFirst(expr, s"[$i]")}"
            case None => source
    }

    def toInt(s: String): Option[Int] = {
        try {
            Some(s.toInt)
        } catch {
            case e: Exception => None
        }
    }

    def solve(left: String, right: String, index: Int): Result = {
        val isLeftEnd = left.length() <= index
        val isRightEnd = right.length() <= index
        if (isLeftEnd && isRightEnd) {
            return Result.Equal
        } else if (isLeftEnd && !isRightEnd) {
            return Result.Correct
        } else if (!isLeftEnd && isRightEnd) {
            return Result.Incorrect
        }
        val firstLeft = left(index)
        val firstRight = right(index)
        if (firstLeft == ',' && firstRight == ',') {
            return solve(left, right, index + 1)
        } else if (firstLeft == '[' && firstRight == '[') {
            val leftMatch = subList(left)
            val rightMatch = subList(right)
            val subResult = solve(leftMatch, rightMatch, 0)
            subResult match
                case Result.Correct => return subResult
                case Result.Incorrect => return subResult
                case Result.Equal => return solve(truncList(left), truncList(right), index)
        } else if (firstLeft == '[') {
            return solve(left, encloseInt(right, index), index)
        } else if (firstRight == '[') {
            return solve(encloseInt(left, index), right, index)
        } else {
            val (leftInt, truncLeft) = truncInt(left, index)
            val (rightInt, truncRight) = truncInt(right, index)
            if (leftInt == rightInt) {
                return solve(truncLeft, truncRight, index)
            } else if (leftInt > rightInt) {
                return Result.Incorrect
            } else {
                return Result.Correct
            }
        }
        return Result.Equal
    }

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
            val result = solve(a, b, 0)
            result match
                case Result.Incorrect => false
                case _ => true
        })
        for (i <- 0 until sorted.length)
            breakable {
                val s = sorted(i)
                s match
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