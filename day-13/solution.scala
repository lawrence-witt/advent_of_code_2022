package solution

enum Result:
    case Correct, Incorrect, Equal

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
        case None => throw new Exception("Expected to recieve an Int")
}

def encloseInt(source: String, offset: Int): String = {
    val expr = "(\\d+)"
    val slice = source.slice(offset, source.length())
    expr.r.findFirstIn(slice) match
        case Some(i) => s"${source.slice(0, offset)}${slice.replaceFirst(expr, s"[$i]")}"
        case None => source
}

def solveSub(left: String, right: String, index: Int): Result = {
    val result = solve(subList(left), subList(right), 0)
    result match
        case Result.Equal => solve(truncList(left), truncList(right), index)
        case _ => result
}

def solveInt(left: String, right: String, index: Int): Result = {
    (truncInt(left, index), truncInt(right, index)) match
        case ((li, lt), (ri, rt)) if (li == ri) => solve(lt, rt, index)
        case ((li, _), (ri, _)) if (li > ri) => Result.Incorrect
        case _ => Result.Correct
}

def solve(left: String, right: String, index: Int): Result = {
    (left.length() <= index, right.length() <= index) match
        case (true, true) => return Result.Equal
        case (true, false) => return Result.Correct
        case (false, true) => return Result.Incorrect
        case _ =>
    (left(index), right(index)) match
        case (',', ',') => return solve(left, right, index + 1)
        case ('[', '[') => return solveSub(left, right, index)
        case ('[', r) => return solve(left, encloseInt(right, index), index)
        case (l, '[') => return solve(encloseInt(left, index), right, index)
        case (l, r) => return solveInt(left, right, index)
}