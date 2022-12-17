import scala.io.Source

@main def aoc_day4: Unit =
  // Get input.txt line by line
  val input = readInput()

  // Solution to Task 1
  val solution1 = evaluateInput1(input)
  println("Solution Part 1: " + solution1)

  // Solution to Task 2
  val solution2 = evaluateInput2(input)
  println("Solution Part 2: " + solution2)

/** Goes through input line, computing the solution for each and summing them
 *
 * @param input List of input lines as strings
 * @return Number of input entries for which one range fully includes the other
 */
def evaluateInput1(input:List[String]):Int = input match {
  case Nil => 0
  case x :: xs => evaluateLine1(x) + evaluateInput1(xs)
}

/** For two ranges in format a-b,c-d evaluates if one fully includes the other
 *
 * @param line Two ranges in format a-b,c-d with a,b,c,d being Integers
 * @return 1 if one range fully includes the other, 0 otherwise
 */
def evaluateLine1(line:String) : Int =
  val pattern = "([0-9]+)(-)([0-9]+)(,)([0-9]+)(-)([0-9]+)".r
  val pattern(elf_a_low, _, elf_a_high, _, elf_b_low, _, elf_b_high) = line
  if (elf_a_low.toInt >= elf_b_low.toInt && elf_a_high.toInt <= elf_b_high.toInt)
    1
  else if (elf_a_low.toInt <= elf_b_low.toInt && elf_a_high.toInt >= elf_b_high.toInt)
    1
  else
    0

/** Goes through input line, computing the solution for each and summing them
 *
 * @param input List of input lines as strings
 * @return Number of input entries for which one range overlaps with the other
 */
def evaluateInput2(input:List[String]):Int = input match {
  case Nil => 0
  case x :: xs => evaluateLine2(x) + evaluateInput2(xs)
}

/** For two ranges in format a-b,c-d evaluates if they overlap
 *
 * @param line Two ranges in format a-b,c-d with a,b,c,d being Integers
 * @return 1 if one range fully includes the other, 0 otherwise
 */
def evaluateLine2(line:String) : Int =
  val pattern = "([0-9]+)(-)([0-9]+)(,)([0-9]+)(-)([0-9]+)".r
  val pattern(elf_a_low, _, elf_a_high, _, elf_b_low, _, elf_b_high) = line

  // Absolute horror, but I need to be quick right now
  if (elf_a_low.toInt to  elf_a_high.toInt contains elf_b_high.toInt)
    1
  else if (elf_a_low.toInt to  elf_a_high.toInt contains elf_b_low.toInt)
    1  
  else if (elf_b_low.toInt to  elf_b_high.toInt contains elf_a_high.toInt)
    1
  else if (elf_b_low.toInt to  elf_b_high.toInt contains elf_a_low.toInt)
    1
  else
    0

def readInput(): List[String] =
  val filename = "input.txt"
  Source.fromFile(filename).getLines.toList

