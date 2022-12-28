import 'dart:io';

class Entry {
  bool simple = false;
  List<Entry> subList = [];
  int value = 0;

  Entry(this.simple, this.subList, this.value);

  String toString() { 
    if (simple) {return "$value";} else {return "$subList";}
  }
}

void challenge() {
  List<String> input = readInput();
  var entries = parseInput(input);
  var result1 = solvePart1(entries);
  print("Result Part 1: $result1");
  var result2 = solvePart2(entries);
  print("Result Part 2: $result2");
}

///
/// Using BubbleSort cause honestly it's simple enough and works well enough for input size
///
int solvePart2(List<Entry> entries) {

  var divider1 = Entry(false, [Entry(false, [Entry(true, [], 2)], 0)] ,0);
  var divider2 = Entry(false, [Entry(false, [Entry(true, [], 6)], 0)] ,0);

  entries.add(divider1);
  entries.add(divider2);

  for (int i = 0; i < entries.length - 1; i++) {
    for (int j = 0; j < entries.length - i - 1; j++) {
      if (compareLists(entries[j].subList, entries[j + 1].subList) == 0) {
        var temp = entries[j];
        entries[j] = entries[j + 1];
        entries[j+1] = temp;
      }
    }
  }

  int index = 1;
  int result = 1;
  for (var entry in entries) {
    //print(entry);

    if(entry.toString() == "[[2]]" || entry.toString() == "[[6]]") {
      result *= index; 
    }

    index++;
  }

  return result;
}

int solvePart1(List<Entry> entries) {
  int index = 1;
  int result = 0;

  for (int i = 0; i < entries.length; i += 2) {
    //print("Comparing Following Entries: ");
    //print(entries[i]);
    //print(entries[i+1]);
    int equal = compareLists(entries[i].subList, entries[i+1].subList);
    //print("Checks have given $equal\n\n");
    if(equal == 1) {result += index;}
    index++;
  }

  return result;
}

///
/// 0 -> Wrong Order
/// 1 -> Correct Order
/// -1 -> Not decideable yet
///
int compareLists(List<Entry> lhs, List<Entry> rhs) {
  //print("Comparing $lhs and $rhs");
  if (lhs.isEmpty && rhs.isEmpty) {
    return -1;
  } else if (lhs.isEmpty && rhs.isNotEmpty) {
    return 1;
  } else if (lhs.isNotEmpty && rhs.isEmpty) {
    return 0;
  }

  Entry left = lhs[0];
  Entry right = rhs[0];

  int result = -1;

  if (left.simple && right.simple) {
    result = compareSimple(left, right);
  } else if (left.simple && !right.simple) {
    result = compareLists([left], right.subList);
  } else if (!left.simple && right.simple) {
    result = compareLists(left.subList, [right]);
  } else {
    result = compareLists(left.subList, right.subList);
  }

  if (result != -1) {
    return result;
  } else {
    return compareLists(lhs.sublist(1), rhs.sublist(1));
  }
}

int compareSimple(Entry lhs, Entry rhs) {
  if (lhs.value < rhs.value) {
    return 1;
  } else if (lhs.value > rhs.value) {
    return 0;
  } else {
    return -1;
  }
} 

List<Entry> parseInput(List<String> input) {
  List<Entry> entries = [];

  for (var line in input) {
    if (line.isNotEmpty) {
      entries.add(parseLine(line));
    }
  }

  return entries;
} 

Entry parseLine(String line) {
  var topLevel = parse(line)[0];
  return topLevel;
}

///
/// Really ugly solution, Regex would probs be way easier
/// But also something in me wants me to try it this way.
///
List parse(String line) {
  line = line.substring(1);
  Entry entry = Entry(false, [], 0);
  String buffer = "";

  //print("Entering parse with line: $line");

  for (var i = 0; i < line.length; i++) {
    switch (line[i]) {
      case '[':
        var subList = parse(line.substring(i));
        i += (subList[1] as int) + 1;
        entry.subList.add(subList[0]);
        break;
      case ']':
        if (buffer.isNotEmpty) {
          entry.subList.add(Entry(true, [], int.parse(buffer)));
          buffer = "";
        }
        return [entry, i];
      case ',':
        if (buffer.isNotEmpty) {
          entry.subList.add(Entry(true, [], int.parse(buffer)));
          buffer = "";
        }
        break;
      default:
        buffer += line[i];
        break;
    }
  }

  //print("Returning from parse with entry: $entry");
  return [entry, -1];
}

List<String> readInput() {
  List<String> input = [];
  var path = "input.txt";
  input = File(path).readAsLinesSync();
  return input;
}
